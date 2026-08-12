module NoRedundantElementEscape exposing (rule)

{-| **The typed-Element escape-reflex backstop** (companion to
`NoRedundantElementForge`).

Where `NoRedundantElementForge` catches a blessed adapter _re-forging_ a plain
tag the typed producer layer already provides, this rule catches the mirror-image
reflex on the **consumer** side: wrapping something that is **already a typed
`Element`** in a render/escape hatch, which throws away the slot-admittance
type-checking the typed layer exists to give.

The reflex is "drop to plain `Html`": a consumer reaches for `<Lib>.toHtml`,
`<Lib>.Unsafe.coerce`/`coerceAll`/`fromHtml`, or a configured `Seam.*` escape and
feeds it a value that a **known family producer** already returned as a typed
`Element` —

    toHtml (M3e.button [ … ] [ … ])
    Unsafe.coerce (M3e.heading …)

A design pass showed heterogeneous typed composition already works (a `button`
`Element` can be a child of a `card` `Element` directly), so these escapes are
usually redundant _and_ lossy: the escape's result is a bare `Html msg` (or a
re-branded phantom row) whose slot admittance the compiler no longer checks.

**Facts-driven and namespace-agnostic**, exactly like `NoRedundantElementForge`:
the "known family producer" set is the same generated `List Cem.Facts.Fact` the
other facts-driven rules consume. An escape's argument is flagged only when it is
a **direct call whose head resolves (via `Cem.Internal.Facts.callSite`) to a fact
in that covered set** — i.e. the argument is provably an already-typed `Element`.

    config =
        [ NoRedundantElementEscape.rule
            { seamEscapes = [ "Seam.fromHtml", "Seam.toElement" ] }
            (M3e.Review.Facts.facts ++ TypedHtml.Review.Facts.facts)
        ]

**Detection** (expression traversal, like `NoSeamOutsideAllowedModules`): flag an
application `escape arg` (in prefix, `escape <| arg`, or `arg |> escape` form)
when

  - _the head is an escape_ —
      - `toHtml` resolving to any module under a facts namespace
        (`<Lib>`, `<Lib>.Html`, …);
      - `coerce`/`coerceAll`/`fromHtml` resolving to `<Lib>.Unsafe`;
      - any of the fully-qualified `seamEscapes` names (`"Seam.fromHtml"`);
  - _and the argument is a known family producer_ — a direct call
    (`M3e.button …`, `M3e.Button.view …`, a barrel or Record shorthand) whose
    head `callSite`-resolves to a fact in the passed facts.

**Three further redundancies on the raw-tag side**, all keyed on the covered-tag
set the facts enumerate (`Facts.htmlTagOf`, exactly like `NoRedundantElementForge`)
so nothing is hardcoded:

  - `Unsafe.fromHtml (Html.a …)` / `Unsafe.fromHtml (Html.node "header" …)` — an
    **Html-accepting** escape (`<Lib>.Unsafe.fromHtml` or a configured
    `seamEscapes` name) fed a hand-written raw tag the typed producer layer
    already provides. `toHtml`/`coerce` are deliberately excluded: they take an
    `Element`, so a raw `Html` argument there cannot occur in code that compiles.
  - `Unsafe.customElement "a" …` — the blessed custom-element forge pointed at a
    tag that is not custom at all. This is `NoRedundantElementForge`'s check
    moved onto the blessed escape, which that rule cannot see (it is gated on
    `import HtmlIr.Internal`).
  - `Unsafe.customElement (Html.node "avt-snackbar")` — `customElement` takes a
    tag NAME; an argument that is provably an element expression (its head
    resolves to `Html.*` or to a known family producer) is a mis-shaped call.
    Note this is also a type error, so the compiler catches it in any module that
    is actually built; the rule only reaches it earlier, and in code that does
    not compile yet.

**Precision — what it must NOT flag:**

  - `toHtml (Html.div [] [])` — `toHtml` is not an Html-accepting escape, so a
    raw-tag argument to it is left alone;
  - `Unsafe.fromHtml (Html.node "compass-passkey" …)` / `Unsafe.customElement
    "model-viewer" …` — a genuine custom element: the tag is not in the covered
    set, so the escape is legitimate;
  - `toHtml html` where `html` is a caller-supplied `Html msg` — a bare variable,
    not a producer application;
  - `Unsafe.customElement tagName …` — a dynamic tag: not a literal, and not
    provably an element either, so silent;
  - an escape of a non-producer helper (`toHtml (viewThing …)`, `Unsafe.coerce
    (M3e.text "hi")` when `text` is not a component fact) — unresolvable or not a
    known producer, so silent.

The "known producer" and "covered tag" gates do the precision work: only an
argument the facts prove is already available typed trips the rule, so a
legitimate escape is silent for free.

**Advisory, no autofix.** Removing the escape changes the expression's type
(`Html msg` → `Element …`, or one phantom row → another), which propagates to
whatever consumes the result; that needs human judgment. So the rule only points
at the typed path.

@docs rule

-}

import Cem.Facts exposing (Fact)
import Cem.Internal.Facts as Facts
import Dict exposing (Dict)
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Range exposing (Range)
import Review.ModuleNameLookupTable as Lookup exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)


{-| Build the rule from the escape config and the generated facts.

  - `seamEscapes` — fully-qualified names of the seam module's `Html`-escape
    functions (e.g. `[ "Seam.fromHtml", "Seam.toElement" ]`). A `Seam.*` escape
    is flagged only when named here, so a legitimate typed-to-typed Seam coercion
    (`Seam.asButton`) is left alone unless you list it. The `toHtml` and
    `Unsafe.*` escapes are derived from the facts' namespaces and need no config.
  - the `List Fact` — the same generated facts the other facts-driven rules
    consume; concatenate several libraries' facts to cover them all.

-}
rule : { seamEscapes : List String } -> List Fact -> Rule
rule config facts =
    let
        parsedSeamEscapes : List ( ModuleName, String )
        parsedSeamEscapes =
            List.map parseQualified config.seamEscapes
    in
    Rule.newModuleRuleSchemaUsingContextCreator "NoRedundantElementEscape"
        (initContext parsedSeamEscapes
            (Facts.buildIndex facts)
            (Facts.namespaces facts)
            (coveredTags facts)
        )
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


{-| The HTML tags the typed producer layer covers, each mapped to the producer
that provides it (`"a"` → `"TypedHtml.a"`, `"main"` → `"TypedHtml.main_"`).
Derived from the facts via `Facts.htmlTagOf`, which reverses the generator's
reserved-word escaping, so the key is the tag a raw call writes and the value is
the Elm name to reach for.
-}
coveredTags : List Fact -> Dict String String
coveredTags facts =
    facts
        |> List.concatMap
            (\fact ->
                let
                    tag =
                        Facts.htmlTagOf fact

                    producer =
                        Facts.factNamespace fact ++ "." ++ fact.component
                in
                -- Both spellings map to the same producer: the tag as a raw
                -- `Html.node "main"` literal writes it, and the reserved-word
                -- escape as `Html.main_` names it.
                [ ( tag, producer ), ( Facts.safeValue tag, producer ) ]
            )
        |> Dict.fromList


{-| Split a dotted name into (module, value): `"Seam.fromHtml"` → `(["Seam"], "fromHtml")`.
-}
parseQualified : String -> ( ModuleName, String )
parseQualified dotted =
    case List.reverse (String.split "." dotted) of
        name :: revModule ->
            ( List.reverse revModule, name )

        [] ->
            ( [], dotted )



-- CONTEXT


type alias Context =
    { lookup : ModuleNameLookupTable
    , seamEscapes : List ( ModuleName, String )
    , index : Dict String Fact
    , namespaces : List (List String)
    , coveredTags : Dict String String
    }


initContext : List ( ModuleName, String ) -> Dict String Fact -> List (List String) -> Dict String String -> Rule.ContextCreator () Context
initContext seamEscapes index namespaces tags =
    Rule.initContextCreator
        (\lookup () ->
            { lookup = lookup
            , seamEscapes = seamEscapes
            , index = index
            , namespaces = namespaces
            , coveredTags = tags
            }
        )
        |> Rule.withModuleNameLookupTable



-- TRAVERSAL


{-| An `escape arg` application in any of the three surface forms — prefix
(`escape (producer …)`), `escape <| producer …`, or `producer … |> escape` — is
flagged when the head is an escape and the argument is a known producer.
-}
expressionVisitor : Node Expression -> Context -> ( List (Error {}), Context )
expressionVisitor node context =
    let
        errors =
            case Node.value node of
                Expression.Application (head :: arg :: _) ->
                    tryFlag context head arg

                Expression.OperatorApplication "<|" _ head arg ->
                    tryFlag context head arg

                Expression.OperatorApplication "|>" _ arg head ->
                    tryFlag context head arg

                _ ->
                    []
    in
    ( errors, context )


{-| Emit an error for the first redundancy `head arg` exhibits: an escape of an
already-typed producer, an Html-accepting escape of a covered raw tag, or a
`customElement` forge that is redundant or mis-shaped.
-}
tryFlag : Context -> Node Expression -> Node Expression -> List (Error {})
tryFlag context head arg =
    [ typedProducerEscape context head arg
    , rawTagEscape context head arg
    , customElementForge context head arg
    ]
        |> List.filterMap identity
        |> List.take 1


{-| `escape (<root>.button …)` — the escape wraps an argument the facts prove is
already a typed `Element`.
-}
typedProducerEscape : Context -> Node Expression -> Node Expression -> Maybe (Error {})
typedProducerEscape context head arg =
    case ( escapeLabel context head, knownProducer context arg ) of
        ( Just label, Just noun ) ->
            Just (escapeError label noun (Node.range head))

        _ ->
            Nothing


{-| `Unsafe.fromHtml (Html.a …)` — an Html-accepting escape wrapping a raw tag
the typed producer layer already provides.
-}
rawTagEscape : Context -> Node Expression -> Node Expression -> Maybe (Error {})
rawTagEscape context head arg =
    case htmlAcceptingEscape context head of
        Just label ->
            rawHtmlTag context arg
                |> Maybe.andThen (\tag -> Maybe.map (Tuple.pair tag) (Dict.get tag context.coveredTags))
                |> Maybe.map (\( tag, producer ) -> rawTagError label tag producer (Node.range head))

        Nothing ->
            Nothing


{-| `<Lib>.Unsafe.customElement …` — redundant when the tag is a covered literal,
mis-shaped when the argument is provably an element rather than a tag name.
-}
customElementForge : Context -> Node Expression -> Node Expression -> Maybe (Error {})
customElementForge context head arg =
    if not (isCustomElement context head) then
        Nothing

    else
        case Node.value (unwrap arg) of
            Expression.Literal tag ->
                Dict.get tag context.coveredTags
                    |> Maybe.map (\producer -> customElementTagError (qualifiedHead context head) tag producer (Node.range head))

            _ ->
                if isElementExpression context arg then
                    Just (customElementShapeError (qualifiedHead context head) (Node.range head))

                else
                    Nothing


{-| Is `head` `customElement` under `<Lib>.Unsafe`?
-}
isCustomElement : Context -> Node Expression -> Bool
isCustomElement context head =
    case Node.value head of
        Expression.FunctionOrValue _ "customElement" ->
            Facts.remainderUnder context.namespaces context.lookup head == Just [ "Unsafe" ]

        _ ->
            False


{-| The escapes that ACCEPT raw `Html` — `<Lib>.Unsafe.fromHtml` and the
configured `seamEscapes`. `toHtml`/`coerce` take an `Element`, so a raw-tag
argument to them cannot occur in compiling code and is not this rule's business.
-}
htmlAcceptingEscape : Context -> Node Expression -> Maybe String
htmlAcceptingEscape context head =
    case Node.value head of
        Expression.FunctionOrValue _ name ->
            case Lookup.moduleNameFor context.lookup head of
                Just moduleName ->
                    if List.member ( moduleName, name ) context.seamEscapes then
                        Just (qualified moduleName name)

                    else if name == "fromHtml" && Facts.remainderUnder context.namespaces context.lookup head == Just [ "Unsafe" ] then
                        Just (qualified moduleName name)

                    else
                        Nothing

                Nothing ->
                    Nothing

        _ ->
            Nothing


{-| The HTML tag a raw `elm/html` call writes, if it is statically knowable:
`Html.a …` → `"a"`, `Html.node "header" …` → `"header"`. A dynamic
`Html.node tagName …` is unresolvable and yields `Nothing`.
-}
rawHtmlTag : Context -> Node Expression -> Maybe String
rawHtmlTag context arg =
    case Node.value (unwrap arg) of
        Expression.Application (rawHead :: rawArgs) ->
            case ( Node.value rawHead, Lookup.moduleNameFor context.lookup rawHead ) of
                ( Expression.FunctionOrValue _ "node", Just [ "Html" ] ) ->
                    List.head rawArgs |> Maybe.andThen literalString

                ( Expression.FunctionOrValue _ name, Just [ "Html" ] ) ->
                    Just name

                _ ->
                    Nothing

        _ ->
            Nothing


{-| Is `arg` provably an ELEMENT expression rather than a tag name — a raw
`Html.*` call or a known family producer? Used only to catch a `customElement`
applied to the wrong kind of thing; anything unresolvable stays silent.
-}
isElementExpression : Context -> Node Expression -> Bool
isElementExpression context arg =
    rawHtmlTag context arg /= Nothing || knownProducer context arg /= Nothing


literalString : Node Expression -> Maybe String
literalString node =
    case Node.value node of
        Expression.Literal value ->
            Just value

        _ ->
            Nothing


unwrap : Node Expression -> Node Expression
unwrap node =
    case Node.value node of
        Expression.ParenthesizedExpression inner ->
            unwrap inner

        _ ->
            node


qualifiedHead : Context -> Node Expression -> String
qualifiedHead context head =
    case ( Node.value head, Lookup.moduleNameFor context.lookup head ) of
        ( Expression.FunctionOrValue _ name, Just moduleName ) ->
            qualified moduleName name

        ( Expression.FunctionOrValue _ name, Nothing ) ->
            name

        _ ->
            ""



-- ESCAPE HEAD


{-| If `head` is an escape function, the human-readable escape name for the
message; otherwise `Nothing`.
-}
escapeLabel : Context -> Node Expression -> Maybe String
escapeLabel context head =
    case Node.value head of
        Expression.FunctionOrValue _ name ->
            case Lookup.moduleNameFor context.lookup head of
                Just moduleName ->
                    if List.member ( moduleName, name ) context.seamEscapes then
                        Just (qualified moduleName name)

                    else if isRenderEscape context head name then
                        Just (qualified moduleName name)

                    else
                        Nothing

                Nothing ->
                    Nothing

        _ ->
            Nothing


{-| Is `head` a facts-derived render escape — `toHtml` under any facts namespace,
or `coerce`/`coerceAll`/`fromHtml` under `<Lib>.Unsafe`?
-}
isRenderEscape : Context -> Node Expression -> String -> Bool
isRenderEscape context head name =
    case Facts.remainderUnder context.namespaces context.lookup head of
        Just remainder ->
            case name of
                "toHtml" ->
                    True

                "coerce" ->
                    remainder == [ "Unsafe" ]

                "coerceAll" ->
                    remainder == [ "Unsafe" ]

                "fromHtml" ->
                    remainder == [ "Unsafe" ]

                _ ->
                    False

        Nothing ->
            False


qualified : ModuleName -> String -> String
qualified moduleName name =
    String.join "." (moduleName ++ [ name ])



-- PRODUCER ARGUMENT


{-| If `arg` is a direct call to a known family producer, its component noun;
otherwise `Nothing`. Unwraps parentheses. A producer is an `Application` whose
head `callSite`-resolves to a fact in the covered index — the proof that the
argument is already a typed `Element`.
-}
knownProducer : Context -> Node Expression -> Maybe String
knownProducer context arg =
    case Node.value arg of
        Expression.ParenthesizedExpression inner ->
            knownProducer context inner

        Expression.Application (fnNode :: _) ->
            producerNoun context fnNode

        _ ->
            Nothing


producerNoun : Context -> Node Expression -> Maybe String
producerNoun context fnNode =
    case Facts.callSite context.namespaces context.lookup fnNode of
        Just site ->
            case Facts.find site context.index of
                Just _ ->
                    Just site.noun

                Nothing ->
                    Nothing

        Nothing ->
            Nothing



-- ERROR


rawTagError : String -> String -> String -> Range -> Error {}
rawTagError escapeName tag producer range =
    Rule.error
        { message = "Redundant escape: `" ++ escapeName ++ "` wraps a hand-written `<" ++ tag ++ ">` that `" ++ producer ++ "` already provides"
        , details =
            [ "`" ++ producer ++ "` produces `<" ++ tag ++ ">` as a typed `Element` with a closed, element-natural attribute row and a checked content model. Writing the tag by hand and lifting it through `" ++ escapeName ++ "` re-implements that producer with FREE rows, so the compiler checks neither the attributes nor where the result may be slotted."
            , "Use `" ++ producer ++ "` and reserve `" ++ escapeName ++ "` for `Html` the typed layer cannot produce — a custom element with no generated producer, or a caller-supplied `Html msg`. Retargeting is left to you (no autofix): the raw attribute list has to be translated to the typed setters, which surfaces attributes that were silently accepted on the wrong element."
            ]
        }
        range


customElementTagError : String -> String -> String -> Range -> Error {}
customElementTagError escapeName tag producer range =
    Rule.error
        { message = "Redundant escape: `" ++ escapeName ++ "` forges `<" ++ tag ++ ">`, which `" ++ producer ++ "` already provides"
        , details =
            [ "`" ++ escapeName ++ "` exists for a tag this library has NO generated producer for. `<" ++ tag ++ ">` is not such a tag: `" ++ producer ++ "` provides it as a typed `Element`, so forging it here discards the closed attribute row and the checked content model for nothing."
            , "Use `" ++ producer ++ "` and keep `" ++ escapeName ++ "` for genuine custom elements. Retargeting is left to you (no autofix): narrowing the free row to the typed one surfaces real type errors that need a human decision."
            ]
        }
        range


customElementShapeError : String -> Range -> Error {}
customElementShapeError escapeName range =
    Rule.error
        { message = "`" ++ escapeName ++ "` takes a tag NAME, but is applied to an element expression"
        , details =
            [ "`" ++ escapeName ++ "` has the shape `String -> List Attr -> List Element -> Element`: its first argument is the raw tag name of a custom element. Here it is applied to something that produces an element (a raw `Html.*` call or a known component producer), so the attributes and children that follow are being handed to the wrong function."
            , "Pass the tag name as a string literal (`" ++ escapeName ++ " \"my-element\" [] []`). Note the compiler rejects this call too, so this is a fast-feedback duplicate of a type error rather than a silent defect — you will see it whether or not this rule runs."
            ]
        }
        range


escapeError : String -> String -> Range -> Error {}
escapeError escapeName producerNoun_ range =
    Rule.error
        { message = "Redundant escape: `" ++ escapeName ++ "` wraps the already-typed `" ++ producerNoun_ ++ "` Element"
        , details =
            [ "`" ++ producerNoun_ ++ "` already returns a typed `Element` whose slot admittance the compiler checks. Applying `" ++ escapeName ++ "` to it drops to plain `Html` (or re-brands the phantom row), discarding exactly that checking — the reflexive \"drop to plain Html\" escape. A design pass showed heterogeneous typed composition already works, so this escape is usually redundant."
            , "Compose the typed `Element` directly — typed children of different components compose heterogeneously — and reserve `" ++ escapeName ++ "` for genuine `Html` the typed layer cannot produce (e.g. `Html.node`, or a caller-supplied `Html msg`). Retargeting is left to you (no autofix): removing the escape changes the expression's type, which propagates to whatever consumes the result and needs a human decision."
            ]
        }
        range
