module IRTest exposing (suite)

{-| Unit tests for the real attribute IR and naming logic (Attr/Naming),
which the generator now uses for classification and identifier generation.

These import and exercise the actual modules (unlike the now-deleted
GenerationTest, which reimplemented logic in the test file and never
imported Generate — see finding 9,
docs/reviews/2026-08-17-thermonuclear-workspace-review.md Theme 5).

-}

import Attr exposing (AttrType(..))
import Cem
import Expect
import Naming
import Test exposing (Test, describe, test)


attr : String -> Attr.AttrType
attr typeText =
    Attr.classify
        { name = "x"
        , description = Nothing
        , type_ = Just { text = typeText, aliasName = Nothing }
        , default = Nothing
        , fieldName = Nothing
        , typeOverride = Nothing
        , elmNameOverride = Nothing
        , global = False
        }


{-| Classify an attribute carrying a config `typeOverride`; `cemText` is the CEM
`type.text` the override is expected to win over (or `Nothing` for an untyped one).
-}
overridden : Maybe String -> Cem.AttrTypeOverride -> AttrType
overridden cemText override =
    Attr.classify
        { name = "x"
        , description = Nothing
        , type_ = Maybe.map (\t -> { text = t, aliasName = Nothing }) cemText
        , default = Nothing
        , fieldName = Nothing
        , typeOverride = Just override
        , elmNameOverride = Nothing
        , global = False
        }


{-| An `AttrSpec` for `name`, in `form`, optionally carrying a CEM `fieldName`
(which is what `Attr.propertyName` reads, so it is how the PROPERTY-path cases
get a DOM name that differs from the HTML one).
-}
spec : Attr.AttrForm -> Maybe String -> String -> Attr.AttrSpec
spec form fieldName name =
    let
        base =
            Attr.fromCem
                { name = name
                , description = Nothing
                , type_ = Just { text = "string", aliasName = Nothing }
                , default = Nothing
                , fieldName = fieldName
                , typeOverride = Nothing
                , elmNameOverride = Nothing
                , global = False
                }
    in
    { base | attrForm = form }


contentAttr : String -> Attr.AttrSpec
contentAttr =
    spec Attr.AsAttribute Nothing


domProperty : String -> Attr.AttrSpec
domProperty =
    spec Attr.AsProperty Nothing


suite : Test
suite =
    describe "Attribute IR + Naming"
        [ describe "Attr.classify"
            [ test "boolean -> ABool" <|
                \_ -> attr "boolean" |> Expect.equal ABool
            , test "nullable boolean -> ABool" <|
                \_ -> attr "boolean | undefined" |> Expect.equal ABool
            , test "number -> ANumber" <|
                \_ -> attr "number" |> Expect.equal ANumber
            , test "plain string -> AString" <|
                \_ -> attr "string" |> Expect.equal AString
            , test "string union (all primitives) -> AString" <|
                \_ -> attr "string | undefined" |> Expect.equal AString
            , test "literal union -> AEnum (sorted, quotes stripped)" <|
                \_ -> attr "'primary' | 'success' | 'danger'" |> Expect.equal (AEnum [ "danger", "primary", "success" ])
            , test "multi-word quoted literals are kept, not dropped for containing a space (issue #16)" <|
                \_ -> attr "'end center' | 'start'" |> Expect.equal (AEnum [ "end center", "start" ])
            , test "unquoted type-name union members are still rejected (not treated as literals)" <|
                \_ -> attr "SomeType | OtherType" |> Expect.equal AString
            , test "single quoted literal is an enum of one value (issue #17)" <|
                \_ -> attr "'only'" |> Expect.equal (AEnum [ "only" ])
            , test "nullable single literal is an enum of the surviving value (issue #17)" <|
                \_ -> attr "'small' | undefined" |> Expect.equal (AEnum [ "small" ])
            , test "literals mixed with an element/type member keep the literals (issue #22)" <|
                \_ -> attr "'small' | 'large' | HTMLElement" |> Expect.equal (AEnum [ "large", "small" ])
            , test "a quoted literal whose content is non-expressible is dropped individually, not the whole enum (issue #22)" <|
                \_ -> attr "'ok' | '(e: Event) => void'" |> Expect.equal (AEnum [ "ok" ])
            , test "function type -> ASkip (getSymbol regression)" <|
                \_ ->
                    case attr "(value: number) => string" of
                        ASkip _ ->
                            Expect.pass

                        other ->
                            Expect.fail ("expected ASkip, got " ++ Debug.toString other)
            , test "HTMLElement -> ASkip" <|
                \_ ->
                    case attr "HTMLElement" of
                        ASkip _ ->
                            Expect.pass

                        other ->
                            Expect.fail ("expected ASkip, got " ++ Debug.toString other)
            , test "no type -> AString" <|
                \_ ->
                    Attr.classify { name = "x", description = Nothing, type_ = Nothing, default = Nothing, fieldName = Nothing, typeOverride = Nothing, elmNameOverride = Nothing, global = False }
                        |> Expect.equal AString
            , test "integer-literal union -> AInt (HeadingLevel 1..6)" <|
                \_ -> attr "1 | 2 | 3 | 4 | 5 | 6" |> Expect.equal AInt
            , test "integer-literal union -> AInt (IconWeight 100..700)" <|
                \_ -> attr "100 | 200 | 300 | 400 | 500 | 600 | 700" |> Expect.equal AInt
            , test "integer-literal union starting at zero -> AInt (ElevationLevel 0..5)" <|
                \_ -> attr "0 | 1 | 2 | 3 | 4 | 5" |> Expect.equal AInt
            , test "nullable integer-literal union -> AInt (undefined stripped)" <|
                \_ -> attr "1 | 2 | 3 | undefined" |> Expect.equal AInt
            , test "a lone number stays ANumber, not AInt (opticalSize)" <|
                \_ -> attr "number" |> Expect.equal ANumber
            , test "a string-literal union is unaffected by AInt (stays AEnum)" <|
                \_ -> attr "'low' | 'medium' | 'high'" |> Expect.equal (AEnum [ "high", "low", "medium" ])
            ]

        -- The `integer` spelling. This is the classifier EVERY brand shares, so the
        -- spelling is pinned here rather than only in one brand's golden output.
        --
        -- The bug it fixes: `AInt` used to be reachable only from an integer-LITERAL
        -- union, so an unbounded integer value space had no spelling and was typed
        -- `number`. `Float -> Attr` serializes with `String.fromFloat`, whose range
        -- includes `"NaN"`, `"Infinity"`, `"1e+21"` and `"2.5"` — all four rejected by
        -- HTML's integer parsers, which then fall back to the attribute default, so
        -- `colspan="2.5"` silently renders as `colspan=1`. Eleven attributes over 31
        -- element/attribute pairs in elm-typed-html shipped that way.
        --
        -- The two spellings must stay DISCRIMINATING in both directions: `<meter high>`
        -- really is a float and must not become an `Int`, and `<td colspan>` really is
        -- an integer and must not stay a `Float`.
        , describe "Attr.classify — the `integer` spelling (Float-for-integer bug)"
            [ test "integer -> AInt" <|
                \_ -> attr "integer" |> Expect.equal AInt
            , test "number stays ANumber — the spellings are not interchangeable" <|
                \_ -> attr "number" |> Expect.equal ANumber
            , test "nullable integer -> AInt (undefined stripped, like every scalar)" <|
                \_ -> attr "integer | undefined" |> Expect.equal AInt
            , test "the spelling is case- and whitespace-insensitive, like boolean/number" <|
                \_ -> attr "  Integer " |> Expect.equal AInt
            , -- Only the WHOLE type text, never a substring. `native-manifest-gen`'s
              -- earlier substring matching on the WHATWG value cell is what mistyped
              -- `coords`, `step` and `datetime`; the CEM-side spelling must not
              -- reintroduce it one layer down.
              test "a type text merely CONTAINING `integer` is not an integer" <|
                \_ -> attr "integers" |> Expect.equal AString
            , test "a prose value cell is not an integer either (that is typing.mjs's job)" <|
                \_ -> attr "Valid non-negative integer" |> Expect.equal AString
            , -- An `integer` member of a literal union is as unspellable as a `number`
              -- one: `HtmlIr.Value`'s row is over string tokens and has no numeric
              -- member. `AEnumNum` is the honest, visible degradation; `AEnum [ "auto" ]`
              -- would silently drop the integer half.
              test "a literal union with an integer member -> AEnumNum, not AEnum" <|
                \_ -> attr "'auto' | integer" |> Expect.equal (AEnumNum [ "auto" ])
            , test "…matching how a `number` member is treated" <|
                \_ -> attr "'all' | number" |> Expect.equal (AEnumNum [ "all" ])
            , -- The emitted signature, so a change to `setterType` cannot quietly
              -- widen these back to `Float`.
              test "AInt's emitted setter type is Int" <|
                \_ -> Attr.setterType AInt |> Expect.equal "Int"
            , test "ANumber's emitted setter type is still Float" <|
                \_ -> Attr.setterType ANumber |> Expect.equal "Float"
            ]
        , describe "Attr.classify with a config typeOverride (R12)"
            [ test "scalar int override forces AInt regardless of CEM text" <|
                \_ -> overridden (Just "number") (Cem.OverrideScalar "int") |> Expect.equal AInt
            , test "scalar float override forces ANumber" <|
                \_ -> overridden Nothing (Cem.OverrideScalar "float") |> Expect.equal ANumber
            , test "scalar bool override forces ABool even over a string CEM type" <|
                \_ -> overridden (Just "string") (Cem.OverrideScalar "bool") |> Expect.equal ABool
            , test "scalar string override forces AString" <|
                \_ -> overridden (Just "boolean") (Cem.OverrideScalar "string") |> Expect.equal AString
            , -- An all-identity override IS an `AEnum` — same information, and the
              -- variant the whole phantom pipeline already knew how to emit. It used
              -- to produce `AEnumMap`, which nothing in the phantom emitters matched,
              -- so the override silently degraded to a plain `String` setter with no
              -- union row and no `<Lib>.Values` tokens. A downstream brand's
              -- `disable-pagination`, constrained to three values in config, shipped
              -- as `String -> Attr` with nothing to show for the constraint.
              test "all-identity enum override normalizes to AEnum (sorted)" <|
                \_ ->
                    overridden Nothing (Cem.OverrideEnum [ ( "b", "b" ), ( "a", "a" ) ])
                        |> Expect.equal (AEnum [ "a", "b" ])
            , -- Sorted, so it compares `==` to the same value-set classified off a CEM
              -- `type.text` or declared in `_globals`. K2's global collapse is that `==`.
              test "all-identity enum override compares equal to the CEM-classified set" <|
                \_ ->
                    overridden (Just "string") (Cem.OverrideEnum [ ( "rtl", "rtl" ), ( "ltr", "ltr" ) ])
                        |> Expect.equal (attr "'ltr' | 'rtl'")
            , test "token->value enum override keeps distinct token and value (issue #96)" <|
                \_ ->
                    overridden Nothing (Cem.OverrideEnum [ ( "never", "false" ), ( "always", "true" ), ( "auto", "auto" ) ])
                        |> Expect.equal (AEnumMap [ ( "never", "false" ), ( "always", "true" ), ( "auto", "auto" ) ])
            , -- One differing pair is enough: the map form exists for that pair, and
              -- normalizing here would lose it.
              test "a single differing pair keeps the whole override an AEnumMap" <|
                \_ ->
                    overridden Nothing (Cem.OverrideEnum [ ( "auto", "auto" ), ( "always", "true" ) ])
                        |> Expect.equal (AEnumMap [ ( "auto", "auto" ), ( "always", "true" ) ])
            , test "override wins even when the CEM leaves the attribute untyped" <|
                \_ -> overridden Nothing (Cem.OverrideScalar "bool") |> Expect.equal ABool
            ]
        , describe "Attr.kernelBlocked — names elm/virtual-dom rewrites or ignores"
            -- The FORM is load-bearing: `VirtualDom.attribute` runs
            -- `_VirtualDom_noOnOrFormAction` and `VirtualDom.property` runs
            -- `_VirtualDom_noInnerHtmlOrFormAction`, and the two guard different names.
            -- Every expectation below is a fact about elm/virtual-dom 1.0.5; see
            -- `Attr.kernelBlockedReason` for the kernel source behind each.
            [ describe "the content-attribute path (`_VirtualDom_noOnOrFormAction`, /^(on|formAction$)/i)"
                [ test "`formaction` is blocked — the `i` flag makes ^formAction$ match HTML's lowercase spelling" <|
                    \_ -> Attr.kernelBlocked (contentAttr "formaction") |> Expect.equal True
                , test "an `on`-prefixed name is blocked (the future-proofing guard)" <|
                    \_ -> Attr.kernelBlocked (contentAttr "onbeforetoggle") |> Expect.equal True
                , test "the prefix test is case-insensitive, like the regex's `i` flag" <|
                    \_ -> Attr.kernelBlocked (contentAttr "OnBeforeToggle") |> Expect.equal True
                , test "an INNOCENT `on`-prefixed name is blocked too — `^on` has no word boundary, so the kernel really does rewrite `once` to `data-once`" <|
                    \_ -> Attr.kernelBlocked (contentAttr "once") |> Expect.equal True
                , test "a name merely starting with `o` is NOT blocked (the guard is the kernel's regex, not a wider one)" <|
                    \_ -> Attr.kernelBlocked (contentAttr "open") |> Expect.equal False
                , test "`form` is NOT blocked — ^formAction$ is anchored, so the prefix alone does not match" <|
                    \_ -> Attr.kernelBlocked (contentAttr "form") |> Expect.equal False
                , test "`formtarget` is NOT blocked — same anchor; only `formaction` itself is" <|
                    \_ -> Attr.kernelBlocked (contentAttr "formtarget") |> Expect.equal False
                , test "`innerhtml` is NOT blocked as a CONTENT attribute — that guard is on the property path only, and HTML has no such attribute for the kernel to rewrite" <|
                    \_ -> Attr.kernelBlocked (contentAttr "innerhtml") |> Expect.equal False
                , test "an ordinary attribute is untouched" <|
                    \_ -> Attr.kernelBlocked (contentAttr "href") |> Expect.equal False
                ]
            , describe "the property path (`_VirtualDom_noInnerHtmlOrFormAction`)"
                [ test "the exact key `innerHTML` is blocked" <|
                    \_ -> Attr.kernelBlocked (domProperty "innerHTML") |> Expect.equal True
                , test "the exact key `outerHTML` is blocked" <|
                    \_ -> Attr.kernelBlocked (domProperty "outerHTML") |> Expect.equal True
                , test "a near-miss spelling is blocked too: it escapes the kernel's case-SENSITIVE test only to become an inert expando" <|
                    \_ -> Attr.kernelBlocked (domProperty "innerHtml") |> Expect.equal True
                , test "the exact key `formAction` is blocked" <|
                    \_ -> Attr.kernelBlocked (domProperty "formAction") |> Expect.equal True
                , test "lowercase `formaction` as a property is blocked — no element observes it" <|
                    \_ -> Attr.kernelBlocked (domProperty "formaction") |> Expect.equal True
                , test "the DOM name comes from `fieldName` when the CEM declared one" <|
                    \_ ->
                        Attr.kernelBlocked (spec Attr.AsProperty (Just "innerHTML") "inner-html")
                            |> Expect.equal True
                , test "…and that spec's HTML name alone would NOT be blocked, so the guard really is reading the property name" <|
                    \_ -> Attr.kernelBlocked (contentAttr "inner-html") |> Expect.equal False
                , test "an `on`-prefixed PROPERTY is NOT blocked: `VirtualDom.property` never runs `noOnOrFormAction`, and blocking it would invent a failure the kernel does not have" <|
                    \_ -> Attr.kernelBlocked (domProperty "once") |> Expect.equal False
                , test "an ordinary property is untouched" <|
                    \_ -> Attr.kernelBlocked (domProperty "value") |> Expect.equal False
                ]
            , describe "`is` — blocked by `createElement`, not by a name rewrite"
                [ test "blocked as a content attribute" <|
                    \_ -> Attr.kernelBlocked (contentAttr "is") |> Expect.equal True
                , test "blocked as a property too — there is no `is` IDL attribute" <|
                    \_ -> Attr.kernelBlocked (domProperty "is") |> Expect.equal True
                , test "`ismap` is NOT blocked — `is` is an equality, not a prefix" <|
                    \_ -> Attr.kernelBlocked (contentAttr "ismap") |> Expect.equal False
                ]
            , describe "the reason names the kernel code responsible, so a reader can verify it"
                -- Not decoration. The whole omit-rather-than-fail policy rests on the
                -- report being actionable, and a report that does not name the kernel
                -- function is an invitation to "restore the missing setter".
                [ test "`formaction` names `_VirtualDom_noOnOrFormAction`" <|
                    \_ ->
                        Attr.kernelBlockedReason (contentAttr "formaction")
                            |> Maybe.map (String.contains "_VirtualDom_noOnOrFormAction")
                            |> Expect.equal (Just True)
                , test "`innerHTML` names `_VirtualDom_noInnerHtmlOrFormAction`" <|
                    \_ ->
                        Attr.kernelBlockedReason (domProperty "innerHTML")
                            |> Maybe.map (String.contains "_VirtualDom_noInnerHtmlOrFormAction")
                            |> Expect.equal (Just True)
                , test "`is` names the `createElement` call site instead, because no rewrite is involved" <|
                    \_ ->
                        Attr.kernelBlockedReason (contentAttr "is")
                            |> Maybe.map (String.contains "createElement")
                            |> Expect.equal (Just True)
                , test "an expressible attribute has no reason at all" <|
                    \_ -> Attr.kernelBlockedReason (contentAttr "href") |> Expect.equal Nothing
                ]
            ]
        , describe "Naming.camel"
            [ test "kebab to camel" <|
                \_ -> Naming.camel "arrow-padding" |> Expect.equal "arrowPadding"
            , test "single word lowercased" <|
                \_ -> Naming.camel "Variant" |> Expect.equal "variant"
            ]
        , describe "Naming.pascal"
            [ test "kebab to pascal" <|
                \_ -> Naming.pascal "sl-button" |> Expect.equal "SlButton"
            ]
        , describe "Naming.constructor"
            [ test "simple value" <|
                \_ -> Naming.constructor "primary" |> Expect.equal "Primary"
            , test "hyphenated value" <|
                \_ -> Naming.constructor "top-start" |> Expect.equal "TopStart"
            , test "underscore-prefixed value" <|
                \_ -> Naming.constructor "_blank" |> Expect.equal "Blank"
            , test "leading digit gets prefixed" <|
                \_ -> Naming.constructor "2x" |> Expect.equal "V2x"
            , test "slashed mime-like value" <|
                \_ -> Naming.constructor "multipart/form-data" |> Expect.equal "MultipartFormData"
            ]
        ]
