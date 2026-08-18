module Cem.RequireFormFieldLabel exposing (rule)

{-| Flag a form-field wrapping a control that has no accessible name.

A form control needs an **accessible name** so assistive technology can announce
it. In the elm-cem/m3e model, `m3e-form-field` (`<root>.FormField`) is a styled
container around a form control; the accessible name is supplied by the control,
not the container. This rule flags a `FormField` call whose control is, as far as
static Elm analysis can tell, definitely un-named.


## What counts as "accessibly named" (any one suffices)

The rule treats a form-field's control as accessibly named when it can see, in
the call's Elm structure, any of:

1.  a **`slot="label"` child** — a `<root>.FormField.label …` element in the
    content list (the floating-label slot; the preferred idiom);
2.  an **`aria-label`/`aria-labelledby`** on the control — `<root>.Aria.label`
    (any `*.Aria.label`/`.labelledby`), the flat barrel `<root>.ariaLabel`, or the
    raw `attribute "aria-label" …` escape hatch — or that same aria setter on the
    form-field's own attribute list;
3.  an **`id`** on the control — because a `<label for="…">` elsewhere in the DOM
    can associate with it. The rule cannot see that `<label>` element (it may live
    anywhere), so a set `id` is taken as evidence of an intended `for`/`id`
    association and suppresses the warning.

Anything else it cannot resolve statically (a dynamic attrs/content list, a
control produced by a helper, a `List.map`, a wrapped/native child it does not
recognise) leaves it **silent** — the advisory posture shared by the
accessible-name attribute rule (`Cem.MissingRequiredAttribute`). It only reports
when it can positively see a control that has none of the three signals.


## Scope & limitations (static Elm analysis only)

  - **Only the Standard/barrel facet** (`<root>.Component.FormField.component …`,
    `<root>.formField …`) is checked. The `build`/pipeline (`Build`) facet is not
    analysed.
  - A `<label for>` is **never verified** — only proxied by the control's `id`
    (point 3). A field labelled solely by an external `<label for>` on a control
    whose `id` is set dynamically is not resolvable and is left alone.
  - A form-field wrapped in an implicit `<label>…control…</label>` ancestor is
    invisible from the call site; such a field is left alone if its content is
    otherwise unresolved, and could in principle be mis-flagged only if its
    control is an inline, fully-resolved, id-less, aria-less component literal.
    This is why the rule is **opt-in** (not in `Cem.all`).

The upshot: false **negatives** (a genuinely un-named field left unflagged) are
accepted freely; false **positives** are engineered out — the rule reports only
the high-confidence case of an inline control literal with no discoverable name.

@docs rule

-}

import Cem.Facts exposing (Facet(..), Fact)
import Cem.Internal.Facts as Facts
import Cem.Internal.Lookup exposing (isCallTo)
import Dict exposing (Dict)
import Elm.Syntax.Declaration as Declaration
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Review.ModuleNameLookupTable as Lookup exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)


{-| Build from the generated facts. `config.componentNoun` is the `fact.component`
value that identifies the form-field in YOUR brand's facts (elm-cem's noun for
the tag that plays the form-field role — `"formField"` for `m3e-form-field`);
the rest of the rule is fully fact-driven (label slot setter name from
`slotRewrites`, module/namespace from the fact itself). This package holds no
brand's noun hardcoded — the consumer's own ReviewConfig supplies it, same
pattern as `Cem.fences`'s `brandRoots`/`seamModules` or
`Cem.redundantElementEscape`'s `seamEscapes`.
-}
rule : { componentNoun : String } -> List Fact -> Rule
rule config facts =
    Rule.newModuleRuleSchemaUsingContextCreator "RequireFormFieldLabel" (initContext facts)
        |> Rule.withDeclarationEnterVisitor declarationEnterVisitor
        |> Rule.withExpressionEnterVisitor (expressionVisitor config)
        |> Rule.fromModuleRuleSchema


type alias Context =
    { lookup : ModuleNameLookupTable
    , factsIndex : Dict String Fact
    , namespaces : List (List String)
    , scope : Dict String (Node Expression)
    }


initContext : List Fact -> Rule.ContextCreator () Context
initContext facts =
    Rule.initContextCreator
        (\lookup () ->
            { lookup = lookup
            , factsIndex = Facts.buildIndex facts
            , namespaces = Facts.namespaces facts
            , scope = Dict.empty
            }
        )
        |> Rule.withModuleNameLookupTable


declarationEnterVisitor : Node Declaration.Declaration -> Context -> ( List (Error {}), Context )
declarationEnterVisitor node context =
    case Node.value node of
        Declaration.FunctionDeclaration { declaration } ->
            case Node.value (Node.value declaration).expression of
                Expression.LetExpression { declarations } ->
                    let
                        scope =
                            List.foldl
                                (\dec acc ->
                                    case Node.value dec of
                                        Expression.LetFunction fn ->
                                            let
                                                fnDecl =
                                                    Node.value fn.declaration
                                            in
                                            Dict.insert (Node.value fnDecl.name) fnDecl.expression acc

                                        _ ->
                                            acc
                                )
                                Dict.empty
                                declarations
                    in
                    ( [], { context | scope = scope } )

                _ ->
                    ( [], { context | scope = Dict.empty } )

        _ ->
            ( [], context )


expressionVisitor : { componentNoun : String } -> Node Expression -> Context -> ( List (Error {}), Context )
expressionVisitor config node context =
    case Node.value node of
        Expression.Application (fnNode :: args) ->
            case Facts.callSite context.namespaces context.lookup fnNode of
                Just site ->
                    case Facts.find site context.factsIndex of
                        Just fact ->
                            ( checkCall config context site fact fnNode args, context )

                        Nothing ->
                            ( [], context )

                Nothing ->
                    ( [], context )

        _ ->
            ( [], context )



-- CHECK


checkCall : { componentNoun : String } -> Context -> Facts.CallSite -> Fact -> Node Expression -> List (Node Expression) -> List (Error {})
checkCall config context site fact fnNode args =
    if fact.component /= config.componentNoun || site.facet /= Standard then
        []

    else
        let
            attrsTrace =
                traceArg context (List.head args)

            contentTrace =
                traceArg context (args |> List.drop 1 |> List.head)
        in
        if attrsTrace.unresolved then
            -- An aria-label could hide in an unresolved form-field attrs list.
            []

        else if List.any (isAriaOrIdSetter context fact) attrsTrace.known then
            -- aria-label/aria-labelledby on the form-field host itself.
            []

        else if contentTrace.unresolved then
            -- A label slot or control could hide in an unresolved content list
            -- (this is the `Seam.field …` opaque-helper case).
            []

        else if List.any (isLabelSlotChild context fact) contentTrace.known then
            -- slot="label" child present.
            []

        else
            let
                states =
                    List.filterMap (classifyChild context fact) contentTrace.known
            in
            if List.member Named states || List.member Unknown states then
                -- A named control, or a control we could not fully inspect.
                []

            else if List.member Unnamed states then
                [ report fact fnNode ]

            else
                -- No control to name.
                []


traceArg : Context -> Maybe (Node Expression) -> Facts.TracedList
traceArg context maybeNode =
    case maybeNode of
        Just node ->
            Facts.tracedList context.lookup context.scope node

        Nothing ->
            { known = [], unresolved = True }



-- CONTROL CLASSIFICATION


type ControlState
    = Named
    | Unnamed
    | Unknown


{-| Classify a content-list child. Returns `Nothing` for a NAMED-slot child
(`prefix`/`hint`/`error`/… — not a control, and not an accessible name), or a
`ControlState` for a DEFAULT-slot (unnamed) child.
-}
classifyChild : Context -> Fact -> Node Expression -> Maybe ControlState
classifyChild context fact element =
    if Facts.fillsDefaultSlot context.namespaces context.lookup (Facts.namedSlotSetters fact) fact.component element then
        Just (classifyDefaultChild context fact element)

    else
        Nothing


classifyDefaultChild : Context -> Fact -> Node Expression -> ControlState
classifyDefaultChild context fact element =
    case Node.value element of
        Expression.ParenthesizedExpression inner ->
            classifyDefaultChild context fact inner

        _ ->
            classifyDefaultChildUnwrapped context fact element


classifyDefaultChildUnwrapped : Context -> Fact -> Node Expression -> ControlState
classifyDefaultChildUnwrapped context fact element =
    case unwrapDefaultChild context fact element of
        Just inner ->
            classifyDefaultChild context fact inner

        Nothing ->
            case Node.value element of
                Expression.Application (headNode :: rest) ->
                    if isResolvedControl context headNode then
                        case rest of
                            attrsNode :: _ ->
                                let
                                    attrsTrace =
                                        Facts.tracedList context.lookup context.scope attrsNode
                                in
                                if attrsTrace.unresolved then
                                    Unknown

                                else if List.any (isAriaOrIdSetter context fact) attrsTrace.known then
                                    Named

                                else
                                    Unnamed

                            [] ->
                                Unknown

                    else
                        -- A native/wrapped/helper child we do not recognise as a
                        -- control: it may itself carry or wrap the accessible
                        -- name, so we must not flag.
                        Unknown

                _ ->
                    Unknown


{-| Unwrap the form-field's own default-slot setter (`<root>.FormField.child x`)
to the wrapped control `x`. Recognised by resolving to the form-field's module
with a name that is neither `component` nor one of its named-slot setters (those don't
reach here — they fail `fillsDefaultSlot`).
-}
unwrapDefaultChild : Context -> Fact -> Node Expression -> Maybe (Node Expression)
unwrapDefaultChild context fact element =
    case Node.value element of
        Expression.Application (headNode :: [ inner ]) ->
            case Node.value headNode of
                Expression.FunctionOrValue _ name ->
                    if name /= "component" && Lookup.moduleNameFor context.lookup headNode == Just (formFieldModule fact) then
                        Just inner

                    else
                        Nothing

                _ ->
                    Nothing

        _ ->
            Nothing


{-| Does a node resolve to some component's top-layer constructor (any facet /
namespace in the facts)? Used to confirm a default-slot child is an inspectable
control literal.
-}
isResolvedControl : Context -> Node Expression -> Bool
isResolvedControl context headNode =
    Facts.callSite context.namespaces context.lookup headNode /= Nothing



-- LABEL SLOT


{-| Is a content child the form-field's `slot="label"` setter — per-component
(`<root>.FormField.label …`) or its generalized barrel form (`<root>.slotLabel …`)?
-}
isLabelSlotChild : Context -> Fact -> Node Expression -> Bool
isLabelSlotChild context fact element =
    case labelSetterName fact of
        Just labelName ->
            let
                perComponent setterNode =
                    isCallTo context (formFieldModule fact) labelName setterNode

                barrel setterNode =
                    case Facts.barrelSlotSetter fact "label" of
                        Just barrelName ->
                            isCallTo context (Facts.factNamespaceParts fact) barrelName setterNode

                        Nothing ->
                            False

                isLabel setterNode =
                    perComponent setterNode || barrel setterNode
            in
            case Node.value element of
                Expression.Application (setterNode :: _) ->
                    isLabel setterNode

                Expression.FunctionOrValue _ _ ->
                    isLabel element

                _ ->
                    False

        Nothing ->
            False


labelSetterName : Fact -> Maybe String
labelSetterName fact =
    fact.slotRewrites
        |> List.filter (\( slot, _ ) -> slot == "label")
        |> List.head
        |> Maybe.map Tuple.second



-- ARIA / ID SATISFIERS


{-| An attrs-list element that supplies an accessible name: an aria-label /
aria-labelledby setter (any facet), or an `id` (proxy for an external
`<label for>` association).
-}
isAriaOrIdSetter : Context -> Fact -> Node Expression -> Bool
isAriaOrIdSetter context fact element =
    case Node.value element of
        Expression.Application (setterNode :: setterArgs) ->
            ariaAxisCall context setterNode
                || isCallTo context (Facts.factNamespaceParts fact) (Facts.ariaBarrelName "label") setterNode
                || isCallTo context (Facts.factNamespaceParts fact) (Facts.ariaBarrelName "labelledby") setterNode
                || isIdCall setterNode
                || isRawNamingAttr setterNode setterArgs

        _ ->
            False


{-| A call to `label`/`labelledby` resolved to any module whose LAST segment is
`Aria` (brand-agnostic aria axis, e.g. `<root>.Aria.label`, `TypedHtml.Aria.label`).
-}
ariaAxisCall : Context -> Node Expression -> Bool
ariaAxisCall context setterNode =
    case Node.value setterNode of
        Expression.FunctionOrValue _ name ->
            (name == "label" || name == "labelledby")
                && (case Lookup.moduleNameFor context.lookup setterNode of
                        Just moduleName ->
                            List.head (List.reverse moduleName) == Just "Aria"

                        Nothing ->
                            False
                   )

        _ ->
            False


isIdCall : Node Expression -> Bool
isIdCall setterNode =
    case Node.value setterNode of
        Expression.FunctionOrValue _ name ->
            name == "id"

        _ ->
            False


isRawNamingAttr : Node Expression -> List (Node Expression) -> Bool
isRawNamingAttr setterNode setterArgs =
    case Node.value setterNode of
        Expression.FunctionOrValue _ "attribute" ->
            case setterArgs of
                arg0 :: _ ->
                    case Node.value arg0 of
                        Expression.Literal literal ->
                            literal == "aria-label" || literal == "aria-labelledby" || literal == "id"

                        _ ->
                            False

                [] ->
                    False

        _ ->
            False



-- SHARED


formFieldModule : Fact -> List String
formFieldModule fact =
    Facts.factNamespaceParts fact ++ [ Facts.factComponentSegment fact ]



-- REPORT


report : Fact -> Node Expression -> Error {}
report fact fnNode =
    Rule.error
        { message =
            "Form field `" ++ fact.component ++ "` wraps a control with no accessible name"
        , details =
            [ "This `"
                ++ fact.component
                ++ "` contains a control, but nothing in this call gives that control an accessible name. A form control needs an accessible name so assistive technology can announce it."
            , "Provide one of: a `"
                ++ labelHint fact
                ++ " [...]` slot child, an `aria-label` on the control (e.g. `"
                ++ Facts.factNamespace fact
                ++ ".Aria.label \"...\"`), or an `id` on the control that a `<label for=\"...\">` associates with."
            ]
        }
        (Node.range fnNode)


labelHint : Fact -> String
labelHint fact =
    Facts.factNamespace fact
        ++ "."
        ++ Facts.factComponentSegment fact
        ++ "."
        ++ (labelSetterName fact |> Maybe.withDefault "label")
