module Generate.Phantom.Emit.Attributes exposing (..)


import Attr
import Cem
import Char
import Dict
import Docs
import Elm
import Generate.Phantom.Model as M exposing (Brand, Comp, EnumSpec, KindField, Marker(..), ResolvedSlot, SlotContent(..))
import Json.Encode as Encode
import Naming

import Generate.Phantom.Emit.AttrsRow exposing (..)
import Generate.Phantom.Emit.Shared exposing (..)


-- ATTRIBUTES MODULE


attributesModule : Brand -> Elm.File
attributesModule brand =
    let
        lib =
            brand.lib

        -- Exposed global setter names: the brand globals plus the companion
        -- setters `classList` / `styleList`, which SHARE their partner's
        -- capability row (so they are extra setters, not extra capability
        -- fields). The pairs mirror elm/html exactly:
        --
        --   class : String                     classList : List (String, Bool)
        --   style : String -> String           styleList : List (String, String)
        --
        -- `style` is the elm 0.19 two-argument form (one declaration) and
        -- `styleList` the 0.18 form (many). Both emit `Ir.styles`, so
        -- declarations MERGE across setters the way classes do, instead of the
        -- last `style` attribute clobbering the rest.
        -- `allGlobals`, not `brand.globals`: this list feeds `exposeBlock` AND
        -- `docsBlock`, so an open global missing here is DECLARED but never EXPOSED —
        -- private to its own module, unreachable from any consumer, and invisible in
        -- elm-typed-html's own build (nothing there imports it). It surfaces as a
        -- mystery "I don't recognize this name" in a downstream brand instead.
        globalNames =
            List.map .elmName (allGlobals brand)
                ++ companionOf "class" "classList"
                ++ companionOf "style" "styleList"

        companionOf global companion =
            if isGlobalName brand global then
                [ companion ]

            else
                []

        globalDoc g =
            case g.elmName of
                "slot" ->
                    "The global `slot` attribute (named-slot placement by hand)."

                "class" ->
                    "The global `class` attribute. Repeats ACCUMULATE: `[ class \"a\", class \"b\" ]` renders `class=\"a b\"`."

                "style" ->
                    "One inline-style declaration (the `elm/html` 0.19 shape). Declarations MERGE across every `style` / `styleList` on the element, last-wins per property."

                _ ->
                    "The global `" ++ g.htmlName ++ "` attribute."

        globals =
            brand.globals
                |> List.concatMap
                    (\g ->
                        case g.elmName of
                            "style" ->
                                -- Two arguments, and `Ir.styles` rather than a
                                -- pre-joined attribute string: the IR merges
                                -- declarations per property, which a whole
                                -- cssText blob cannot participate in.
                                [ ""
                                , ""
                                , doc (globalDoc g)
                                , "style : String -> String -> Attr { c | style : Supported } msg"
                                , "style property value_ ="
                                , "    Ir.styles [ ( property, value_ ) ]"
                                , ""
                                , ""
                                , doc "Inline-style declarations as a `( property, value )` list (the `elm/html` 0.18 shape). Merges exactly as `style` does."
                                , "styleList : List ( String, String ) -> Attr { c | style : Supported } msg"
                                , "styleList ="
                                , "    Ir.styles"
                                ]

                            "class" ->
                                [ ""
                                , ""
                                , doc (globalDoc g)
                                , "class : String -> Attr { c | class : Supported } msg"
                                , "class ="
                                , "    Ir.attribute \"class\""
                                , ""
                                , ""
                                , doc "The classes whose flag is `True`, space-joined. Accumulates with every other `class` / `classList` on the element."
                                , "classList : List ( String, Bool ) -> Attr { c | class : Supported } msg"
                                , "classList pairs ="
                                , "    Ir.attribute \"class\" (String.join \" \" (List.map Tuple.first (List.filter Tuple.second pairs)))"
                                ]

                            _ ->
                                -- Every other global is emitted by the SAME two
                                -- setter emitters the shared vocabulary uses, keyed
                                -- off its `_globals` type: `Bool` globals get the
                                -- present/absent body, `Int`/`Float` the stringified
                                -- one, enum globals the `Value <Row>` one. Routing
                                -- them through a bespoke switch here is how they all
                                -- ended up `String -> Attr` in the first place.
                                case ( isEnumSpec g, unionFor brand g.elmName ) of
                                    ( True, Just union ) ->
                                        enumSetterDecl False (globalDoc g) g.htmlName union

                                    _ ->
                                        plainSetterDecl False (globalDoc g) g
                    )

        -- The `"row": "open"` globals, through the SAME two emitters with the row flag
        -- flipped. Same routing (enum vs plain), same doc source, same bodies — so an
        -- open global cannot disagree with a closed one about how it reaches the DOM,
        -- only about which elements admit it.
        --
        -- `class` and `style` need no special-case here (unlike the closed block
        -- above): both are closed, per the spec's Non-goals, so the bespoke
        -- `classList`/`styleList` companions never reach this path. Opening either
        -- later means teaching this block their two-argument / companion shapes.
        openGlobalDecls =
            brand.openGlobals
                |> List.concatMap
                    (\g ->
                        case ( isEnumSpec g, unionFor brand g.elmName ) of
                            ( True, Just union ) ->
                                enumSetterDecl True (globalDoc g) g.htmlName union

                            _ ->
                                plainSetterDecl True (globalDoc g) g
                    )

        -- An ENUM GLOBAL lives in `brand.unions` (that is where `<Lib>.Values` mints
        -- its row and tokens) but its setter is emitted by the globals block above,
        -- so it must not be emitted a second time here.
        enumAttrs =
            brand.unions
                |> List.filter (\u -> not (isGlobalName brand u.elmName))

        plainAttrs =
            brand.sharedAttrs
                |> List.filter
                    (\a ->
                        -- An attr that is an ENUM on any component gets ONLY the
                        -- union setter — a second plain setter under the same name
                        -- would clash (e.g. `autocomplete` is enum on form,
                        -- free-string on input).
                        not (isEnumSpec a)
                            && not (List.any (\e -> e.elmName == a.elmName) brand.unions)
                    )

        plainSetter a =
            plainSetterDecl False (controlledDoc brand a) a

        -- The `default*` companions: one per controlled attribute the brand actually
        -- declares somewhere. They live HERE, in the shared vocabulary, alongside the
        -- live-property setters they mirror; the home / per-component modules re-export
        -- them through `reExportBlock`.
        companions =
            companionsFor brand (brandSuppressed brand) plainAttrs

        companionNames =
            companions |> List.map (\( _, n, _ ) -> n)

        companionDecls =
            companions |> List.concatMap (\( c, n, a ) -> companionDecl brand c n a)

        -- The `_variants` ergonomic setters (`stepAsNumber`, `coordsAsInts`), beside the
        -- base setters whose capability row they share. Re-exported by the home /
        -- per-component modules through `reExportBlock`, exactly like the companions.
        variants =
            variantsFor brand plainAttrs

        variantNames =
            variants |> List.map (\( v, _ ) -> v.name)

        variantDecls =
            variants |> List.concatMap (\( v, a ) -> variantDecl v a)

        -- The scalar/free-string setter, with its doc string passed IN: the shared
        -- vocabulary derives it from the CEM description (`Attr.docString`), a global
        -- from `globalDoc`. Everything below the doc line — signature and body — is
        -- shared, so a global can never disagree with a shared attr of the same type
        -- about how it reaches the DOM.
        plainSetterDecl rowOpen docText a =
            let
                -- The ONE line the `row` axis changes. `"c"` admits the setter onto
                -- every element structurally; the refinement admits it only onto
                -- elements whose closed `Attrs` alias declares the field. Argument
                -- type, body and doc are identical either way, which is what makes a
                -- closed entry's output byte-identical to before the axis existed.
                rowType =
                    if rowOpen then
                        "c"

                    else
                        "{ c | " ++ a.capName ++ " : Supported }"

                body =
                    if emitsAsProperty a then
                        -- Controlled attribute → DOM property so it updates
                        -- after user input (NB2c).
                        [ a.elmName ++ " value_ ="
                        , "    Ir.property \"" ++ Attr.propertyName a ++ "\" (" ++ propEncoder a.type_ ++ ")"
                        ]

                    else
                        case ( a.type_, a.reactiveProp ) of
                            ( Attr.ABool, _ ) ->
                                -- Boolean → attribute present/absent (NEVER a JS
                                -- property nor `classList []`): web components
                                -- observe attributes, and the false branch must
                                -- not clobber a sibling `class` (NB2a/NB2b).
                                --
                                -- The false branch is `Ir.none` — genuinely
                                -- nothing. It used to be
                                -- `Html.Attributes.style "" ""`, which is a real
                                -- STYLE fact: visible to `Test.Html.Query`, and
                                -- enough to force a style-bucket diff on every
                                -- node carrying a false boolean.
                                [ a.elmName ++ " value_ ="
                                , "    if value_ then"
                                , "        Ir.attribute \"" ++ a.htmlName ++ "\" \"\""
                                , ""
                                , "    else"
                                , "        Ir.none"
                                ]

                            ( Attr.ANumber, _ ) ->
                                -- Non-controlled number → attribute (serializes to
                                -- SSR; reflects to the property when the CEM links
                                -- one via fieldName). Was Ir.property when
                                -- fieldName-backed, which left it invisible to
                                -- server-rendered markup (#41).
                                [ a.elmName ++ " value_ ="
                                , "    Ir.attribute \"" ++ a.htmlName ++ "\" (String.fromFloat value_)"
                                ]

                            ( Attr.AInt, _ ) ->
                                [ a.elmName ++ " value_ ="
                                , "    Ir.attribute \"" ++ a.htmlName ++ "\" (String.fromInt value_)"
                                ]

                            _ ->
                                [ a.elmName ++ " ="
                                , "    Ir.attribute \"" ++ a.htmlName ++ "\""
                                ]
            in
            [ ""
            , ""
            , doc docText
            , a.elmName ++ " : " ++ setterInputType a ++ " -> Attr " ++ rowType ++ " msg"
            ]
                ++ body

        enumSetter e =
            let
                matchingAttr =
                    brand.sharedAttrs
                        |> List.filter (\a -> a.elmName == e.elmName)
                        |> List.head

                htmlName =
                    matchingAttr
                        |> Maybe.map .htmlName
                        |> Maybe.withDefault e.elmName

                docText =
                    matchingAttr
                        |> Maybe.map Attr.docString
                        |> Maybe.withDefault ("Set the `" ++ e.elmName ++ "` value.")
            in
            enumSetterDecl False docText htmlName e

        -- The `Value <Row>` setter, with its doc string and DOM attribute name passed
        -- IN (the globals block has both to hand; `enumSetter` recovers them from the
        -- shared vocabulary).
        enumSetterDecl rowOpen docText htmlName e =
            let
                rowType =
                    if rowOpen then
                        "c"

                    else
                        "{ c | " ++ e.elmName ++ " : Supported }"
            in
            [ ""
            , ""
            , doc docText
            , e.elmName ++ " : Value " ++ lib ++ ".Values." ++ e.aliasName ++ " -> Attr " ++ rowType ++ " msg"
            , e.elmName ++ " value_ ="
            , "    Ir.attribute \"" ++ htmlName ++ "\" (HtmlIr.Value.toString value_)"
            ]

        -- Any setter emitted as a DOM property needs `Json.Encode`. Globals are never
        -- controlled form props (`value`/`checked`/`selected` are not global), so only
        -- the shared vocabulary and its `_variants` can pull this import in.
        needsEncode =
            (plainAttrs |> List.any emitsAsProperty)
                || (variants |> List.any (\( _, a ) -> emitsAsProperty a))

        -- A brand whose ONLY enums are globals has an empty `enumAttrs` and still needs
        -- these two imports, or the emitted module does not compile.
        -- The "no, this is not missing" paragraph. Every name here IS declared by the
        -- manifest and IS real HTML; what it has no setter for is `elm/virtual-dom`,
        -- which rewrites or ignores the name on the way to the DOM. A setter would
        -- type-check, render, raise no error and do something else — so the surface
        -- omits it, and this note says which kernel function is responsible so the
        -- next reader does not "fix" the gap by adding one back.
        --
        -- Empty for a brand with nothing blocked, which keeps every existing brand's
        -- bytes unchanged. See `Attr.kernelBlockedReason` and `Model.Brand.kernelBlocked`.
        kernelBlockedNote =
            if List.isEmpty brand.kernelBlocked then
                []

            else
                [ ""
                , "**Deliberately absent.** These attributes are declared by the manifest and"
                , "are real HTML, but `elm/virtual-dom` cannot write them, so this library does"
                , "not pretend to: a setter would compile, render, and silently do something"
                , "else. None of them is reachable from Elm at all — reach for a port or a"
                , "custom element instead of restoring a setter here."
                , ""
                ]
                    ++ (brand.kernelBlocked
                            |> List.map (\( name, reason ) -> "  - `" ++ name ++ "` — " ++ reason ++ ".")
                       )

        -- Portmanteau attribute nullaries: `<attr><ValuePascal>` for every (enum attr,
        -- token) pair that is not already claimed by a plain name. The `taken` set
        -- mirrors `guardAttributesModule`'s `allPairs` (minus portmanteaus, which are
        -- computed from it — same logic, same drop rule).
        attrPortmanteauTaken =
            globalNames
                ++ (plainAttrs |> List.map .elmName)
                ++ companionNames
                ++ variantNames
                ++ (enumAttrs |> List.map .elmName)

        attrPortmanteauList =
            enumAttrPortmanteaus brand attrPortmanteauTaken

        attrPortmanteauNames =
            attrPortmanteauList |> List.map .name

        attrPortmanteauDecls =
            attrPortmanteauList
                |> List.concatMap
                    (\p ->
                        [ ""
                        , ""
                        , doc
                            ("Set the `"
                                ++ p.htmlName
                                ++ "` attribute to `\""
                                ++ p.tokenValue
                                ++ "\"`. Portmanteau of `"
                                ++ p.capName
                                ++ "` + `"
                                ++ p.tokenValue
                                ++ "` — for IDE discovery and single-import ergonomics."
                            )
                        , p.name ++ " : Attr { c | " ++ p.capName ++ " : Supported } msg"
                        , p.name ++ " ="
                        , "    Ir.attribute \"" ++ p.htmlName ++ "\" \"" ++ p.tokenValue ++ "\""
                        ]
                    )

        needsValues =
            not (List.isEmpty enumAttrs) || hasEnumGlobal brand

        imports =
            List.concat
                [ [ "import HtmlIr.Attribute exposing (Attr)"
                  , "import HtmlIr.Internal as Ir"
                  , "import HtmlIr.Kind exposing (Supported)"
                  ]
                , if needsEncode then
                    [ "import Json.Encode" ]

                  else
                    []
                , if needsValues then
                    [ "import HtmlIr.Value exposing (Value)"
                    , "import " ++ lib ++ ".Values"
                    ]

                  else
                    []
                ]
                |> List.sort
    in
    file [ lib, "Attributes" ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ lib ++ ".Attributes exposing"
                  , exposeBlock
                        [ globalNames
                        , plainAttrs |> List.map .elmName
                        , companionNames
                        , variantNames
                        , enumAttrs |> List.map .elmName
                        , attrPortmanteauNames
                        ]
                  , ""
                  , "{-| The canonical shared attribute vocabulary. Every setter is an open"
                  , "producer (`{ c | attr : Supported }`); each element's closed `Attrs` row"
                  , "decides admittance. Enum setters here close over the library-wide UNION of"
                  , "values — cross-component misuse is caught by elm-review; reach for the"
                  , "per-component setters (`" ++ lib ++ ".<Component>.<attr>`) for compile-tight narrowing."
                  , ""
                  , "Portmanteau setters (`variantRainbow`, `shapeRounded`, …) are nullary"
                  , "aliases that pre-apply one enum token. They exist for IDE discovery:"
                  , "type `variant` and autocomplete lists every value inline. Each claims"
                  , "the same capability row as its base enum setter, so admittance is identical."
                  ]
                , kernelBlockedNote
                , [ ""
                  , docsBlock
                        [ globalNames
                        , plainAttrs |> List.map .elmName
                        , companionNames
                        , variantNames
                        , enumAttrs |> List.map .elmName
                        , attrPortmanteauNames
                        ]
                  , ""
                  , "-}"
                  , ""
                  ]
                , imports
                , globals

                -- Spliced HERE, beside `globals`, because this `List.concat` IS the
                -- emitted file text. `openGlobalDecls` left computed-but-unreferenced
                -- would be dropped with no error from any tool in the chain — the
                -- generator would exit 0, `<Lib>.Attributes` would compile, and the
                -- setter would simply not exist.
                , openGlobalDecls
                , plainAttrs |> List.concatMap plainSetter
                , companionDecls
                , variantDecls
                , enumAttrs |> List.concatMap enumSetter
                , attrPortmanteauDecls
                , [ "" ]
                ]
            )
        )



