module Cem.ValidSlotKind exposing (Unresolved(..), rule, ruleWith)

{-| Codegen-aware, **correctness** rule: a child placed in a top-layer content
list must be a kind the enclosing component's slot actually accepts.

This backstops the guarantee the phantom `Content` wrapper used to give once the
top layer drops it (ADR 15). Three shapes are checked on
`<root>.Component.<Comp>.component` calls:

  - **Raw default children** — a component call sitting directly in the content
    list (e.g. `M3e.Component.Card.component [] [ M3e.iconButton [] [] ]`) targets the default
    slot. Its kind (the component noun, `iconButton`) must be in that slot's
    `slotKinds`.
  - **Named-slot setters** — a `<root>.<Comp>.<setter>` call in the content list
    (e.g. `M3e.Card.actions (M3e.iconButton [] [])`) targets the slot the setter
    names. The slot must be one the component declares (`slotRewrites`), and the
    wrapped child's kind must be in that slot's `slotKinds`.
  - **Loose barrel placers** — a `<root>.slot<Name> child` call in the content
    list (e.g. `M3e.Component.Button.component [] [ M3e.slotIcon (M3e.icon [] []) ]`) uses the
    Design-C shared slot placer. The placer is recognised by its barrel-root
    module + `"slot"` prefix; it resolves to the parent's raw slot via the
    parent fact's `slotUpgrades` list. The wrapped child's kind must be in that
    slot's `slotKinds`.

When a child's kind can't be resolved statically (a `let`-bound value, a
parameter, a `List.map`-produced element, …) the `Unresolved` posture decides:
`Lenient` stays silent (default); `Strict` warns, naming the slot.

@docs Unresolved, rule, ruleWith

-}

import Cem.Facts exposing (Facet(..), Fact)
import Cem.Internal.Facts as Facts
import Dict exposing (Dict)
import Elm.Syntax.Declaration as Declaration
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Review.ModuleNameLookupTable as Lookup exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)


{-| How to treat a child whose kind can't be resolved statically.

A child's kind is resolvable ONLY when it is written as an inline
`<root>.*` component literal (e.g. `M3e.iconButton [] []`). Anything else is
unresolvable: a `let`-bound value, a function parameter, a `List.map`-produced
element, AND any child returned by a helper (`viewRow row`) or a non-component
barrel value (`M3e.text "x"`). In a constrained slot:

  - `Lenient` — stay silent on unresolvable children (the default;
    `rule = ruleWith Lenient`).
  - `Strict` — warn on every unresolvable child, so nothing escapes the static
    check unnoticed. Expect this to fire on idiomatic helper-based view code;
    it's a strict opt-in, not the default.

Either way, an unconstrained slot (declared but with no `slotKinds`) is silent.

-}
type Unresolved
    = Lenient
    | Strict


{-| Build from the generated facts, lenient about unresolvable children.
-}
rule : List Fact -> Rule
rule =
    ruleWith Lenient


{-| Build from the generated facts with an explicit `Unresolved` posture.
-}
ruleWith : Unresolved -> List Fact -> Rule
ruleWith mode facts =
    Rule.newModuleRuleSchemaUsingContextCreator "ValidSlotKind" (initContext mode facts)
        |> Rule.withDeclarationEnterVisitor declarationEnterVisitor
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


type alias Context =
    { lookup : ModuleNameLookupTable
    , factsIndex : Dict String Fact
    , namespaces : List (List String)
    , scope : Dict String (Node Expression)
    , mode : Unresolved
    }


initContext : Unresolved -> List Fact -> Rule.ContextCreator () Context
initContext mode facts =
    Rule.initContextCreator
        (\lookup () ->
            { lookup = lookup
            , factsIndex = Facts.buildIndex facts
            , namespaces = Facts.namespaces facts
            , scope = Dict.empty
            , mode = mode
            }
        )
        |> Rule.withModuleNameLookupTable


{-| DEFER (follow-up, not this pass): the `Unresolved` type could be renamed
and the speculative `defaultSlot` `unnamed`/`default` fallback dropped.
-}
declarationEnterVisitor : Node Declaration.Declaration -> Context -> ( List (Error {}), Context )
declarationEnterVisitor node context =
    case Facts.collectLetScope node of
        Just scope ->
            ( [], { context | scope = scope } )

        Nothing ->
            ( [], context )


expressionVisitor : Node Expression -> Context -> ( List (Error {}), Context )
expressionVisitor node context =
    case Node.value node of
        Expression.Application (fnNode :: args) ->
            case Facts.callSite context.namespaces context.lookup fnNode of
                Just site ->
                    case Facts.find site context.factsIndex of
                        Just fact ->
                            ( checkCall context site fact args, context )

                        Nothing ->
                            ( [], context )

                Nothing ->
                    ( [], context )

        _ ->
            ( [], context )


{-| The content list is the last argument of a fully-applied constructor
(2nd for Standard, 3rd for Record). Each resolved element is checked against the
enclosing component's slots.
-}
checkCall : Context -> Facts.CallSite -> Fact -> List (Node Expression) -> List (Error {})
checkCall context site fact args =
    let
        minArgs =
            case site.facet of
                Record ->
                    3

                _ ->
                    2
    in
    if List.length args >= minArgs then
        case List.reverse args |> List.head of
            Just contentNode ->
                Facts.tracedList context.lookup context.scope contentNode
                    |> .known
                    |> List.concatMap (checkChild context fact)

            Nothing ->
                []

    else
        []


{-| How a content-list element was classified.

  - `DefaultChild kind` — a component call in the default slot; `kind` is its
    resolved component noun (or `Nothing` when unresolvable).
  - `SlotChild setter kind` — a `<root>.<Comp>.<setter>` call targeting a named
    slot; `kind` is the wrapped child's resolved noun. `setter` is the
    PER-COMPONENT setter name (used to look up the raw slot via `slotRewrites`).
  - `LoosePlacerChild rawSlot kind` — a `<root>.slot<Name> child` barrel placer
    in the content list (Design C). `rawSlot` is the already-resolved raw HTML
    slot name (from `slotUpgrades`); `kind` is the wrapped child's resolved noun.

-}
type Classified
    = DefaultChild (Maybe String)
    | SlotChild String (Maybe String)
    | LoosePlacerChild String (Maybe String)


checkChild : Context -> Fact -> Node Expression -> List (Error {})
checkChild context fact element =
    let
        containerModuleParts =
            Facts.factNamespaceParts fact ++ [ Facts.capitalize fact.component ]
    in
    case classify context containerModuleParts element of
        DefaultChild maybeKind ->
            checkKindInSlot context fact (defaultSlot fact) maybeKind element

        SlotChild setterName maybeKind ->
            case rawSlotForSetter fact setterName of
                Just rawSlot ->
                    checkKindInSlot context fact (Just rawSlot) maybeKind element

                Nothing ->
                    [ undeclaredSlotError fact setterName element ]

        LoosePlacerChild rawSlot maybeKind ->
            checkKindInSlot context fact (Just rawSlot) maybeKind element


classify : Context -> List String -> Node Expression -> Classified
classify context containerModuleParts element =
    case Node.value element of
        Expression.ParenthesizedExpression inner ->
            classify context containerModuleParts inner

        Expression.Application (headNode :: innerArgs) ->
            case Facts.callSite context.namespaces context.lookup headNode of
                Just childSite ->
                    case resolvedKind context childSite of
                        Just kind ->
                            -- A known component in the index: raw default child.
                            DefaultChild (Just kind)

                        Nothing ->
                            -- callSite resolved to a barrel-root namespace, but the
                            -- noun isn't a known component. This is either a
                            -- non-component helper (`M3e.text`, `M3e.none`) OR a
                            -- Design-C loose slot placer (`M3e.slotIcon`).
                            -- Try the loose placer path first; fall back to DefaultChild.
                            case loosePlacerSlot context containerModuleParts headNode of
                                Just rawSlot ->
                                    LoosePlacerChild rawSlot (List.head innerArgs |> Maybe.andThen (kindOf context))

                                Nothing ->
                                    DefaultChild Nothing

                Nothing ->
                    case slotSetterName context containerModuleParts headNode of
                        Just setterName ->
                            SlotChild setterName (List.head innerArgs |> Maybe.andThen (kindOf context))

                        Nothing ->
                            DefaultChild Nothing

        Expression.FunctionOrValue _ _ ->
            DefaultChild (kindOf context element)

        _ ->
            DefaultChild Nothing


{-| A root-namespace call resolves to a known kind only when its noun names a
component in the facts index. A non-component barrel helper (`M3e.text`,
`M3e.none`, …) resolves via `callSite` but is NOT a component, so its kind is
`Nothing` (unresolvable) rather than a bogus noun that would falsely trip the
kind check inside a constrained slot.
-}
resolvedKind : Context -> Facts.CallSite -> Maybe String
resolvedKind context site =
    case Facts.find site context.factsIndex of
        Just _ ->
            Just site.noun

        Nothing ->
            Nothing


{-| If `headNode` resolves to the container's own module (and isn't its `component`
constructor), it's a named-slot setter — return the setter name.

NOTE: `containerModuleParts` is the STANDARD component module (e.g. `M3e.Component.Card`).
Per-component slot setters live there and are re-exported, so a slot child is
written `M3e.Card.actions …` whether the parent call is Standard or Record —
this recognises both. A hypothetical `M3e.Record.Card.<slot>` child would fall
through to `DefaultChild Nothing` (Strict would then flag it as unresolvable);
that form isn't emitted by the generator, so recognising it isn't worth the code.

-}
slotSetterName : Context -> List String -> Node Expression -> Maybe String
slotSetterName context containerModuleParts headNode =
    case Node.value headNode of
        Expression.FunctionOrValue _ name ->
            if name /= "component" && Lookup.moduleNameFor context.lookup headNode == Just containerModuleParts then
                Just name

            else
                Nothing

        _ ->
            Nothing


{-| If `headNode` is a loose barrel placer for one of the parent's declared
slots, return the raw slot name. A loose placer resolves to a barrel-root
namespace (e.g. `["M3e"]`) and has a name that is a known barrel slot setter for
the parent component (from `slotUpgrades`, e.g. `"slotIcon"` → raw slot `"icon"`).

This is the Design-C shape: `M3e.slotIcon child` inside
`M3e.Component.Button.component [] [ … ]` — the placer lives in the barrel module, not the
per-component module, so `slotSetterName` (which requires the container module)
can't see it. We check that the resolved module is a known barrel-root namespace
(using `context.namespaces`, which already contains every barrel root derived by
`buildIndex`/`namespaces`) and then look the name up in the parent's `slotUpgrades`.

-}
loosePlacerSlot : Context -> List String -> Node Expression -> Maybe String
loosePlacerSlot context containerModuleParts headNode =
    case Node.value headNode of
        Expression.FunctionOrValue _ name ->
            case Lookup.moduleNameFor context.lookup headNode of
                Just resolvedModule ->
                    -- The head must resolve to a known barrel-root namespace (e.g.
                    -- ["M3e"]). `context.namespaces` contains every barrel root that
                    -- `buildIndex`/`namespaces` derived from the facts, so membership
                    -- here is the right check — it is also what `callSite` resolves
                    -- against, keeping this consistent with the rest of the rule.
                    if List.member resolvedModule context.namespaces then
                        rawSlotForBarrelPlacer context containerModuleParts name

                    else
                        Nothing

                Nothing ->
                    Nothing

        _ ->
            Nothing


{-| Look up the raw slot name for a barrel-placer identifier by checking every
namespace's facts. `containerModuleParts` is the parent's STANDARD module (e.g.
`["M3e", "Button"]`); we only check the PARENT's own fact (already resolved at
the `checkCall`/`checkChild` level).

We can't reach the parent's fact here directly, so we scan all facts in the
index for one whose component module matches the container, and look up the
barrel placer in that fact's `slotUpgrades`.

-}
rawSlotForBarrelPlacer : Context -> List String -> String -> Maybe String
rawSlotForBarrelPlacer context containerModuleParts placerName =
    -- Find the parent fact by matching its Standard module parts
    -- against the container module parts.
    context.factsIndex
        |> Dict.values
        |> firstMaybe
            (\fact ->
                let
                    factParts =
                        Facts.factNamespaceParts fact ++ [ Facts.capitalize fact.component ]
                in
                if factParts == containerModuleParts then
                    rawSlotForUpgrade fact placerName

                else
                    Nothing
            )


{-| Given a parent fact and a barrel placer name (e.g. `"slotIcon"`), find the
raw slot name it targets.

The loose placer identifier is the generator's `"slot" ++ pascalCase(rawSlot)`
(e.g. raw slot `"leading-button"` → placer `slotLeadingButton`, `"icon"` →
`slotIcon`). We recover the raw slot by scanning the component's declared slot
names (`slotKinds` keys, excluding the `"unnamed"` default) and matching the one
whose derived placer identifier equals `placerName`.

NB: this is derived from `slotKinds`/`slotRewrites`, which are populated in the
real generated facts — NOT from `slotUpgrades`, which is empty for barrel
components in the real facts (an earlier draft zipped `slotUpgrades` and so
silently no-op'd on real code even though it passed synthetic-fixture tests).

Returns `Nothing` if the placer isn't a named slot of this component.

-}
rawSlotForUpgrade : Fact -> String -> Maybe String
rawSlotForUpgrade fact placerName =
    fact.slotKinds
        |> List.map Tuple.first
        |> List.filter (\rawSlot -> rawSlot /= "unnamed")
        |> firstMaybe
            (\rawSlot ->
                if slotPlacerIdent rawSlot == placerName then
                    Just rawSlot

                else
                    Nothing
            )


{-| The generator's loose slot-placer identifier for a raw html slot name:
`"slot" ++ pascalCase(rawSlot)`, where pascalCase splits on `-` and capitalises
each segment (`"leading-button"` → `"LeadingButton"`). Mirrors elm-cem's
`Emit.looseSlotPlacers` naming so the review rule inverts it exactly.
-}
slotPlacerIdent : String -> String
slotPlacerIdent rawSlot =
    "slot"
        ++ (rawSlot
                |> String.split "-"
                |> List.map Facts.capitalize
                |> String.concat
           )


firstMaybe : (a -> Maybe b) -> List a -> Maybe b
firstMaybe f xs =
    case xs of
        [] ->
            Nothing

        x :: rest ->
            case f x of
                Just y ->
                    Just y

                Nothing ->
                    firstMaybe f rest


{-| Resolve an expression's kind to a component noun, where statically possible.
-}
kindOf : Context -> Node Expression -> Maybe String
kindOf context node =
    case Node.value node of
        Expression.ParenthesizedExpression inner ->
            kindOf context inner

        Expression.Application (headNode :: _) ->
            Facts.callSite context.namespaces context.lookup headNode
                |> Maybe.andThen (resolvedKind context)

        Expression.FunctionOrValue _ _ ->
            Facts.callSite context.namespaces context.lookup node
                |> Maybe.andThen (resolvedKind context)

        _ ->
            Nothing


checkKindInSlot : Context -> Fact -> Maybe String -> Maybe String -> Node Expression -> List (Error {})
checkKindInSlot context fact maybeRawSlot maybeKind element =
    case maybeRawSlot of
        Nothing ->
            -- No default slot declared for this component; nothing to enforce.
            []

        Just rawSlot ->
            case allowedKinds fact rawSlot of
                Just allowed ->
                    case maybeKind of
                        Just kind ->
                            if isAllowedKind kind allowed then
                                []

                            else
                                [ disallowedKindError fact rawSlot kind allowed element ]

                        Nothing ->
                            unresolved context fact rawSlot element

                Nothing ->
                    -- Slot declared but no kind constraints recorded: there is
                    -- nothing to enforce, so stay silent in every posture —
                    -- including Strict, which has no constraint to check against.
                    []


unresolved : Context -> Fact -> String -> Node Expression -> List (Error {})
unresolved context fact rawSlot element =
    case context.mode of
        Strict ->
            [ unresolvedError fact rawSlot element ]

        Lenient ->
            []



-- FACT LOOKUPS


{-| The raw slot name whose per-component setter is `child` (the default slot),
falling back to a conventional `unnamed`/`default` key if present in `slotKinds`.
-}
defaultSlot : Fact -> Maybe String
defaultSlot fact =
    case List.filter (\( _, setter ) -> setter == "child") fact.slotRewrites of
        ( raw, _ ) :: _ ->
            Just raw

        [] ->
            if List.any (\( k, _ ) -> k == "unnamed") fact.slotKinds then
                Just "unnamed"

            else if List.any (\( k, _ ) -> k == "default") fact.slotKinds then
                Just "default"

            else
                Nothing


{-| The kinds a slot accepts, or `Nothing` when the slot is unconstrained.

Per the `Cem.Facts` contract, an **empty or absent** `slotKinds` entry means
"unconstrained" — the `"arbitrary"` config token (accepts-anything) is encoded as
an empty kind list. So a present-but-empty entry (`( slot, [] )`) collapses to
`Nothing` here, identical to an absent slot: both are silent in every posture.
Returning `Just []` would wrongly read as "constrained to nothing" and reject
every child of an arbitrary slot.

-}
allowedKinds : Fact -> String -> Maybe (List String)
allowedKinds fact rawSlot =
    fact.slotKinds
        |> List.filter (\( k, _ ) -> k == rawSlot)
        |> List.head
        |> Maybe.map Tuple.second
        |> Maybe.andThen
            (\kinds ->
                if List.isEmpty kinds then
                    Nothing

                else
                    Just kinds
            )


{-| Check if a child kind is permitted by the allowed list.

Two match paths:

  - Exact match: `"iconButton"` in `["iconButton", "button"]` → accepted.
  - Shared-atom match (WS2): a kind `"text"` is accepted when the list contains
    `"shared:text"` — `Kind.Shared` atoms (from `elm-html-intermediate-representation`)
    compose into slots that opt in via `"shared:<atom>"` in their `slotKinds`. This is
    backward-compatible: old facts with no `"shared:"` entries behave identically.

-}
isAllowedKind : String -> List String -> Bool
isAllowedKind kind allowed =
    List.member kind allowed
        || List.member ("shared:" ++ kind) allowed


rawSlotForSetter : Fact -> String -> Maybe String
rawSlotForSetter fact setterName =
    fact.slotRewrites
        |> List.filter (\( _, setter ) -> setter == setterName)
        |> List.head
        |> Maybe.map Tuple.first


slotLabel : String -> String
slotLabel raw =
    if raw == "unnamed" || raw == "default" then
        "default"

    else
        raw



-- ERRORS


disallowedKindError : Fact -> String -> String -> List String -> Node Expression -> Error {}
disallowedKindError fact rawSlot kind allowed element =
    Rule.error
        { message =
            "`"
                ++ kind
                ++ "` is not an allowed child of the `"
                ++ slotLabel rawSlot
                ++ "` slot on `"
                ++ fact.component
                ++ "`"
        , details =
            [ "The `" ++ slotLabel rawSlot ++ "` slot accepts: " ++ String.join ", " allowed ++ "."
            , "Move this child to a slot that accepts it, or use an allowed component."
            ]
        }
        (Node.range element)


undeclaredSlotError : Fact -> String -> Node Expression -> Error {}
undeclaredSlotError fact setterName element =
    Rule.error
        { message = "`" ++ fact.component ++ "` does not declare a slot for `" ++ setterName ++ "`"
        , details =
            [ "This child is stamped with a slot the container doesn't declare; it won't render where you expect."
            ]
        }
        (Node.range element)


unresolvedError : Fact -> String -> Node Expression -> Error {}
unresolvedError fact rawSlot element =
    Rule.error
        { message =
            "Cannot statically resolve the kind of a child in the `"
                ++ slotLabel rawSlot
                ++ "` slot on `"
                ++ fact.component
                ++ "`"
        , details =
            [ "Strict mode is on: this child's kind couldn't be determined, so it can't be checked against the slot's allowed kinds."
            ]
        }
        (Node.range element)
