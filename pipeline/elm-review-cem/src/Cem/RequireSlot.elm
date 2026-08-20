module Cem.RequireSlot exposing (rule)

{-| Codegen-aware, **advisory** rule: a required slot should be filled.

Required-_singular_ slots live in the constructor's required record (first argument), so
Elm's own record types already enforce their presence — this rule would be redundant
there. The gap it closes is the required-_multi_ slot: a repeatable slot the component
needs at least one of, which lives in the loose content list and is **not** type-enforced.
This flags a constructor whose content list omits a required-multi slot entirely.

The required and multi slot sets come from the generated `Cem.Facts`; their
intersection is the set this rule checks. Advisory: report-only.

@docs rule

-}

import Cem.Facts exposing (Fact)
import Cem.Internal.Facts as Facts
import Dict exposing (Dict)
import Elm.Syntax.Declaration as Declaration
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Review.ModuleNameLookupTable exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)


{-| Build from the generated facts.
-}
rule : List Fact -> Rule
rule facts =
    Rule.newModuleRuleSchemaUsingContextCreator "RequireSlot" (initContext (buildIndex facts) (Facts.namespaces facts))
        |> Rule.withDeclarationEnterVisitor declarationEnterVisitor
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


{-| Per-component slot info the rule needs: the content-setter names that must
appear at least once (required ∩ multi), plus the component's named-slot setters
(so a raw default child can be recognised as filling the default slot).
-}
type alias RequiredInfo =
    { setters : List String
    , named : List String
    }


{-| component noun -> its `RequiredInfo`.
-}
type alias Index =
    Dict String RequiredInfo


buildIndex : List Fact -> Index
buildIndex facts =
    -- Derive from the canonical barrel-aware `Facts.buildIndex` (inserts the
    -- barrel-alias key alongside the `factKey`) so barrel call sites (`M3e.grid …`)
    -- resolve. A private `factKey`-only index was DEAD on the barrel surface on
    -- real generated facts; flat test fixtures (`module_ = "M3e.Grid"`) masked it.
    -- See docs/decisions.md "Facts-index canonicality".
    Facts.buildIndex facts
        |> Dict.map
            (\_ f ->
                { setters =
                    f.requiredSlots
                        |> List.filter (\s -> List.member s f.multiSlots)
                        |> List.map (slotSetter f)
                , named = Facts.namedSlotSetters f
                }
            )
        |> Dict.filter (\_ info -> not (List.isEmpty info.setters))


{-| The content-setter name for a slot. Checks slotRewrites first (e.g. "unnamed" -> "child"),
then falls back to camelCase conversion.
-}
slotSetter : Fact -> String -> String
slotSetter fact slot =
    case List.filter (\( from, _ ) -> from == slot) fact.slotRewrites of
        ( _, to ) :: _ ->
            to

        [] ->
            if slot == "default" || slot == "unnamed" then
                "child"

            else
                Facts.camelize slot


type alias Context =
    { lookup : ModuleNameLookupTable
    , index : Index
    , namespaces : List (List String)
    , scope : Dict String (Node Expression)
    }


initContext : Index -> List (List String) -> Rule.ContextCreator () Context
initContext index namespaces =
    Rule.initContextCreator (\lookup () -> { lookup = lookup, index = index, namespaces = namespaces, scope = Dict.empty })
        |> Rule.withModuleNameLookupTable


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
                    case Dict.get (Facts.siteKey site) context.index of
                        Just info ->
                            ( checkCall context site.namespace site.noun info (Node.range fnNode) args, context )

                        Nothing ->
                            ( [], context )

                Nothing ->
                    ( [], context )

        _ ->
            ( [], context )


{-| The content is the _last_ argument of a fully-applied constructor — UNLESS
the default/repeatable `child` slot is required, in which case the two-arity
`component` ctor threads its content through the leading required
record's `content` field instead: `component required_ attrs children = H.select
attrs (required_.content :: children)`. That record is a THIRD, LEADING
argument (`component : { content : Element ... } -> attrs -> children -> Element`),
so a call site with this shape has 3 args, not 2 — a call site without a
required default slot, or the bare `component attrs children` arity, still has exactly 2
(`attrs children`), and `args[0]` there is `attrs`, never a content record.

Once the leading record is visible at all, Elm's own type system already
guarantees its `content` field is set (exactly the posture
`MissingRequiredSingularSlot` takes for required-singular slots) — we don't
need to also classify what kind of element it holds, unlike a raw entry in
the trailing content list. If the record can't be resolved statically (a
variable, a helper call, …), stay silent about the default slot specifically
(advisory posture) rather than false-positive; other required-multi setters,
if any, are still checked against the trailing list as before.

Uses `Facts.tracedList` to look through dynamic expressions (List.map, concat, etc.).
We only flag when we have enough args (>=2 for Standard, >=3 for Record).
When `unresolved = True` we still check the known setters but stay silent if
there are zero known (we can't distinguish "truly empty" from "all-dynamic").

-}
checkCall : Context -> List String -> String -> RequiredInfo -> { start : { row : Int, column : Int }, end : { row : Int, column : Int } } -> List (Node Expression) -> List (Error {})
checkCall context namespace componentNoun info range args =
    if List.length args >= 2 then
        case List.reverse args of
            last :: _ ->
                let
                    -- A leading content-record argument can only be present
                    -- when the default slot is required (`component`'s codegen only
                    -- adds that leading param in that case) AND there are
                    -- enough args for one to exist ahead of `attrs, children`.
                    hasCandidateRecord : Bool
                    hasCandidateRecord =
                        List.member "child" info.setters && List.length args >= 3

                    leadingRecordFields : Maybe (Dict String (Node Expression))
                    leadingRecordFields =
                        if hasCandidateRecord then
                            args
                                |> List.head
                                |> Maybe.andThen (Facts.resolveRecordFields context.scope)

                        else
                            Nothing

                    defaultSatisfiedByRecord : Bool
                    defaultSatisfiedByRecord =
                        leadingRecordFields
                            |> Maybe.map (Dict.member "content")
                            |> Maybe.withDefault False

                    defaultRecordUnresolved : Bool
                    defaultRecordUnresolved =
                        hasCandidateRecord && leadingRecordFields == Nothing

                    traced =
                        Facts.tracedList context.lookup context.scope last

                    present =
                        List.filterMap (elementSetter context namespace componentNoun) traced.known

                    -- The default (`unnamed`→`child`) slot is filled by raw
                    -- default children in the content list, an explicit
                    -- `<Comp>.child` setter never appears there — or, since
                    -- el-unification, by the leading record's `content` field
                    -- (`defaultSatisfiedByRecord`).
                    hasDefaultChild =
                        defaultSatisfiedByRecord
                            || List.any
                                (Facts.fillsDefaultSlot [ namespace ] context.lookup info.named componentNoun)
                                traced.known
                in
                if traced.unresolved && List.isEmpty traced.known && not defaultSatisfiedByRecord then
                    -- Truly opaque — stay silent rather than false-positive
                    []

                else
                    info.setters
                        |> List.filter
                            (\name ->
                                not (List.member name present)
                                    && not (name == "child" && hasDefaultChild)
                                    && not (name == "child" && defaultRecordUnresolved)
                            )
                        |> List.map (\name -> error name range)

            [] ->
                []

    else
        []


{-| Extract the setter name from a content-list element, verifying it resolves
to the top-layer barrel or `<root>.<Comp>` module so bare names from unrelated
modules don't silence the rule.
-}
elementSetter : Context -> List String -> String -> Node Expression -> Maybe String
elementSetter context namespace componentNoun elementNode =
    let
        isTopLayer setterNode name =
            if Facts.isTopLayerModule [ namespace ] context.lookup setterNode componentNoun then
                Just name

            else
                Nothing
    in
    case Node.value elementNode of
        Expression.Application (setterNode :: _) ->
            case Node.value setterNode of
                Expression.FunctionOrValue _ name ->
                    isTopLayer setterNode name

                _ ->
                    Nothing

        Expression.FunctionOrValue _ name ->
            isTopLayer elementNode name

        _ ->
            Nothing


error : String -> { start : { row : Int, column : Int }, end : { row : Int, column : Int } } -> Error {}
error name range =
    Rule.error
        { message = "Required slot `" ++ name ++ "` is not filled"
        , details =
            [ "This component needs at least one `" ++ name ++ "` in its content list, but none is present."
            , "This is a repeatable required slot, so the type system doesn't enforce it — add the missing content."
            ]
        }
        range
