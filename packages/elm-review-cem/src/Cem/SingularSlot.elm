module Cem.SingularSlot exposing (rule)

{-| Codegen-aware, **advisory** rule: a singular slot should be filled
at most once. In the double-list top form, nothing stops a caller passing two
`trailing` items to a slot that renders only one — the extra silently wins or is
dropped. This flags a content-slot setter used 2+ times on one constructor when that
slot is **not** in the component's multi (repeatable) set.

Multi-slot names come from the generated `Cem.Facts`; everything not listed multi
is treated as singular. Advisory: report-only.

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
    Rule.newModuleRuleSchemaUsingContextCreator "SingularSlot" (initContext (buildIndex facts) (Facts.namespaces facts))
        |> Rule.withDeclarationEnterVisitor declarationEnterVisitor
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


{-| component key -> the component's SINGULAR slot-setter names (the setters that
render one element and so must not repeat). A repeated head is flagged ONLY if it
is in this set, so a non-slot barrel function applied to several children — e.g. a
message mapper `M3e.mapMsg toMsg child` used once per child — is NOT mistaken for a
doubled slot. (Keying on the setter names, not "any top-layer function", is what
distinguishes a slot from a wrapper: only actual slots appear in `slotKinds` /
`slotRewrites`.)
-}
type alias Index =
    Dict String (List String)


buildIndex : List Fact -> Index
buildIndex facts =
    -- Derive from the canonical barrel-aware index, NOT a private `factKey`-only
    -- one: `Facts.buildIndex` inserts BOTH the `factKey` (`"M3e.Component\0button"`)
    -- and the barrel-alias key (`"M3e\0button"`) for components under a
    -- `Component`/`Build` segment, so a barrel call site (`M3e.button …`, whose
    -- `siteKey` is `"M3e\0button"`) resolves. A private `factKey`-only index was
    -- DEAD on the entire barrel surface on real generated facts (flat test
    -- fixtures hid it because `factKey == siteKey` when `module_` has no
    -- `.Component.` segment). See docs/decisions.md "Facts-index canonicality".
    Facts.buildIndex facts
        |> Dict.map (\_ f -> singularSlotSetters f)


{-| The setter names for a component's SINGULAR slots (every declared slot that is
not in `multiSlots`), in both forms a content-list element can take: the re-exposed
per-component setter (`slotSetter`, e.g. `title`) and the loose Design-C barrel
placer (`slot<Name>`, e.g. `slotTitle`). Both name the same singular slot, so a
repeat of either is a doubled singular slot.

The slot names themselves come from the facts (`slotKinds` keys and `slotRewrites`
sources) — NEVER from "whatever function appears in the content list" — so wrappers
and raw children that are not slots (a `mapMsg`, another component's `component`) are
correctly excluded.

-}
singularSlotSetters : Fact -> List String
singularSlotSetters fact =
    (List.map Tuple.first fact.slotKinds ++ List.map Tuple.first fact.slotRewrites)
        |> List.filter (\slot -> not (List.member slot fact.multiSlots))
        |> List.concatMap
            (\slot ->
                [ slotSetter fact slot
                , "slot" ++ Facts.capitalize (Facts.camelize slot)
                ]
            )
        -- a slot may appear in both `slotKinds` and `slotRewrites`; dedupe so the
        -- membership set is tidy (harmless either way — `List.member` is used).
        |> List.foldr
            (\name acc ->
                if List.member name acc then
                    acc

                else
                    name :: acc
            )
            []


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

                                                name =
                                                    Node.value fnDecl.name
                                            in
                                            Dict.insert name fnDecl.expression acc

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
                    case Dict.get (Facts.siteKey site) context.index of
                        Just singular ->
                            if List.length args >= 2 then
                                case List.reverse args of
                                    last :: _ ->
                                        let
                                            traced =
                                                Facts.tracedList context.lookup context.scope last
                                        in
                                        ( checkArg context site.namespace site.noun singular traced.known, context )

                                    [] ->
                                        ( [], context )

                            else
                                ( [], context )

                        Nothing ->
                            ( [], context )

                Nothing ->
                    ( [], context )

        _ ->
            ( [], context )


{-| Flag any SINGULAR slot setter that appears more than once in the content list.
`singular` is the component's singular slot-setter names; a repeated head not in it
(a multi setter, or a non-slot wrapper like `mapMsg`) is left alone.
-}
checkArg : Context -> List String -> String -> List String -> List (Node Expression) -> List (Error {})
checkArg context namespace componentNoun singular elements =
    let
        setters =
            List.filterMap (elementSetter context namespace componentNoun) elements

        repeated =
            setters
                |> List.filter (\( name, _ ) -> countBy name setters > 1)
                |> List.filter (\( name, _ ) -> List.member name singular)
    in
    -- report each repeated singular setter once (dedupe by name via a fold)
    repeated
        |> dedupeByName
        |> List.map (\( name, range ) -> error name range)


{-| Extract setter name and range from a content-list element, verifying it
resolves to the top-layer barrel or `<root>.<Comp>` module.
-}
elementSetter : Context -> List String -> String -> Node Expression -> Maybe ( String, { start : { row : Int, column : Int }, end : { row : Int, column : Int } } )
elementSetter context namespace componentNoun elementNode =
    case Node.value elementNode of
        Expression.Application (setterNode :: _) ->
            case Node.value setterNode of
                Expression.FunctionOrValue _ name ->
                    if Facts.isTopLayerModule [ namespace ] context.lookup setterNode componentNoun then
                        Just ( name, Node.range elementNode )

                    else
                        Nothing

                _ ->
                    Nothing

        _ ->
            Nothing


countBy : String -> List ( String, a ) -> Int
countBy name =
    List.filter (\( n, _ ) -> n == name) >> List.length


dedupeByName : List ( String, a ) -> List ( String, a )
dedupeByName =
    List.foldl
        (\(( name, _ ) as item) acc ->
            if List.any (\( n, _ ) -> n == name) acc then
                acc

            else
                acc ++ [ item ]
        )
        []


error : String -> { start : { row : Int, column : Int }, end : { row : Int, column : Int } } -> Error {}
error name range =
    Rule.error
        { message = "Singular slot `" ++ name ++ "` is filled more than once"
        , details =
            [ "This slot renders a single element, but it's set multiple times here — the extra will silently win or be dropped."
            , "Keep one, or (if this component genuinely repeats the slot) it should be in the multi set — check the component's slot config."
            ]
        }
        range
