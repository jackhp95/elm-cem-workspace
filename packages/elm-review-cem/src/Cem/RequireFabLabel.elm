module Cem.RequireFabLabel exposing (rule)

{-| Flag a FAB (`m3e-fab` / `<root>.Fab`) that has no accessible name.

A FAB needs an **accessible name** so assistive technology can announce it. In
the elm-cem/m3e model a FAB is named either by its **extended label** (the
`slot="label"` child, `<root>.Fab.label …`) or by an `aria-label`. The library
recently made `aria-label` **optional** on Fab at the type level (an extended FAB
with a visible label does not need one), so the "must have an accessible name"
guarantee now lives in this lint rule instead of the type system — the same split
as form-field controls (`Cem.RequireFormFieldLabel`). This rule flags a `Fab`
call that is, as far as static Elm analysis can tell, definitely un-named.


## What counts as "accessibly named" (any one suffices)

The rule treats a FAB as accessibly named when it can see, in the call's Elm
structure, any of:

1.  a **`slot="label"` child** — a `<root>.Fab.label …` element in the content
    list (the extended-FAB label; the analogue of FormField's `label` slot);
2.  an **`aria-label`/`aria-labelledby`** on the FAB — `<root>.Aria.label` (any
    `*.Aria.label`/`.labelledby`), the flat barrel `<root>.ariaLabel`, or the raw
    `attribute "aria-label" …` escape hatch — in the FAB's attribute list;
3.  an **`id`** on the FAB — because a `<label for="…">` elsewhere in the DOM can
    associate with it. The rule cannot see that `<label>` element (it may live
    anywhere), so a set `id` is taken as evidence of an intended `for`/`id`
    association and suppresses the warning.

Anything else it cannot resolve statically (a dynamic attrs/content list, a
label produced by a helper, a `List.map`, a wrapped/native child it does not
recognise) leaves it **silent** — the advisory posture shared by
`Cem.RequireFormFieldLabel` and `Cem.MissingRequiredAttribute`. It only reports
when it can positively see a FAB that has none of the three signals.


## Scope & limitations (static Elm analysis only)

  - **Only the Standard/barrel facet** (`<root>.Component.Fab.component …`, `<root>.fab …`) is
    checked. The `build`/pipeline (`Build`) and record (`Record`) facets are not
    analysed.
  - A `<label for>` is **never verified** — only proxied by the FAB's `id`
    (point 3). A FAB labelled solely by an external `<label for>` on a FAB whose
    `id` is set dynamically is not resolvable and is left alone.

The upshot: false **negatives** (a genuinely un-named FAB left unflagged) are
accepted freely; false **positives** are engineered out — the rule reports only
the high-confidence case of an inline FAB literal with no discoverable name.

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


{-| Build from the generated facts. The rule recognises the FAB component by its
elm-cem-generated noun (`fab`, from the `m3e-fab` tag) and reads the `label` slot
setter name from that fact's `slotRewrites`.
-}
rule : List Fact -> Rule
rule facts =
    Rule.newModuleRuleSchemaUsingContextCreator "RequireFabLabel" (initContext facts)
        |> Rule.withDeclarationEnterVisitor declarationEnterVisitor
        |> Rule.withExpressionEnterVisitor expressionVisitor
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


expressionVisitor : Node Expression -> Context -> ( List (Error {}), Context )
expressionVisitor node context =
    case Node.value node of
        Expression.Application (fnNode :: args) ->
            case Facts.callSite context.namespaces context.lookup fnNode of
                Just site ->
                    case Facts.find site context.factsIndex of
                        Just fact ->
                            ( checkCall context site fact fnNode args, context )

                        Nothing ->
                            ( [], context )

                Nothing ->
                    ( [], context )

        _ ->
            ( [], context )



-- CHECK


{-| The elm-cem noun for `m3e-fab`. Kept as the single recognition point so the
semantic anchor is greppable; the rest of the rule is fact-driven.
-}
fabNoun : String
fabNoun =
    "fab"


checkCall : Context -> Facts.CallSite -> Fact -> Node Expression -> List (Node Expression) -> List (Error {})
checkCall context site fact fnNode args =
    if fact.component /= fabNoun || site.facet /= Standard then
        []

    else
        let
            attrsTrace =
                traceArg context (List.head args)

            contentTrace =
                traceArg context (args |> List.drop 1 |> List.head)
        in
        if attrsTrace.unresolved then
            -- An aria-label / id could hide in an unresolved attrs list.
            []

        else if List.any (isAriaOrIdSetter context fact) attrsTrace.known then
            -- aria-label/aria-labelledby/id on the FAB itself.
            []

        else if contentTrace.unresolved then
            -- A label slot could hide in an unresolved content list.
            []

        else if List.any (isLabelSlotChild context fact) contentTrace.known then
            -- slot="label" child present (the extended-FAB label).
            []

        else if List.any (childCouldHideLabel context) contentTrace.known then
            -- A helper-produced / native / unresolved child could itself be (or
            -- wrap) the label slot: we must not flag.
            []

        else
            [ report fact fnNode ]


traceArg : Context -> Maybe (Node Expression) -> Facts.TracedList
traceArg context maybeNode =
    case maybeNode of
        Just node ->
            Facts.tracedList context.lookup context.scope node

        Nothing ->
            { known = [], unresolved = True }



-- CONTENT CHILDREN


{-| Could this content child be, or wrap, the FAB's label slot? True unless the
child is an inline, fully-resolved component literal (e.g. the required icon),
which is definitely not a hidden label. A bare reference, a helper call, or an
unrecognised native wrapper could produce a `<root>.Fab.label …`, so it keeps the
rule silent — the advisory posture.
-}
childCouldHideLabel : Context -> Node Expression -> Bool
childCouldHideLabel context element =
    case Node.value element of
        Expression.ParenthesizedExpression inner ->
            childCouldHideLabel context inner

        Expression.Application (headNode :: _) ->
            not (isResolvedControl context headNode)

        Expression.FunctionOrValue _ _ ->
            not (isResolvedControl context element)

        _ ->
            True


{-| Does a node resolve to some component's top-layer constructor (any facet /
namespace in the facts)? Used to confirm a content child is an inspectable
component literal rather than a helper-produced value.
-}
isResolvedControl : Context -> Node Expression -> Bool
isResolvedControl context headNode =
    Facts.callSite context.namespaces context.lookup headNode /= Nothing



-- LABEL SLOT


{-| Is a content child the FAB's `slot="label"` setter — per-component
(`<root>.Fab.label …`) or its generalized barrel form (`<root>.slotLabel …`)?
-}
isLabelSlotChild : Context -> Fact -> Node Expression -> Bool
isLabelSlotChild context fact element =
    case labelSetterName fact of
        Just labelName ->
            let
                perComponent setterNode =
                    isCallTo context (fabModule fact) labelName setterNode

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


fabModule : Fact -> List String
fabModule fact =
    Facts.factNamespaceParts fact ++ [ Facts.factComponentSegment fact ]



-- REPORT


report : Fact -> Node Expression -> Error {}
report fact fnNode =
    Rule.error
        { message =
            "FAB `" ++ fact.component ++ "` has no accessible name"
        , details =
            [ "This `"
                ++ fact.component
                ++ "` has no discoverable accessible name, so assistive technology cannot announce it. A FAB needs an accessible name — from its extended label or an `aria-label`."
            , "Provide one of: a `"
                ++ labelHint fact
                ++ " [...]` slot child (the extended-FAB label), an `aria-label` on the FAB (e.g. `"
                ++ Facts.factNamespace fact
                ++ ".Aria.label \"...\"`), or an `id` on the FAB that a `<label for=\"...\">` associates with."
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
