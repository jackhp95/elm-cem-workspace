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


{-| component noun -> set of setter names that MAY repeat (the multi slots, camelCased).
-}
type alias Index =
    Dict String (List String)


buildIndex : List Fact -> Index
buildIndex facts =
    facts
        |> List.map (\f -> ( Facts.factKey f, List.map (slotSetter f) f.multiSlots ))
        |> Dict.fromList


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
                        Just multi ->
                            if List.length args >= 2 then
                                case List.reverse args of
                                    last :: _ ->
                                        let
                                            traced =
                                                Facts.tracedList context.lookup context.scope last
                                        in
                                        ( checkArg context site.namespace site.noun multi traced.known, context )

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


{-| Flag any singular setter that appears more than once in the content list.
-}
checkArg : Context -> List String -> String -> List String -> List (Node Expression) -> List (Error {})
checkArg context namespace componentNoun multi elements =
    let
        setters =
            List.filterMap (elementSetter context namespace componentNoun) elements

        repeated =
            setters
                |> List.filter (\( name, _ ) -> countBy name setters > 1)
                |> List.filter (\( name, _ ) -> not (List.member name multi))
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
