module Cem.MissingRequiredSingularSlot exposing (rule)

{-| Flag Standard calls whose content list omits a required-singular slot.

Record calls are silent (the required record's field is compile-time-enforced).
Advisory posture — silent on unresolved content lists.

@docs rule

-}

import Cem.Facts exposing (Facet(..), Fact)
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
    Rule.newModuleRuleSchemaUsingContextCreator "MissingRequiredSingularSlot" (initContext facts)
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
                    if site.facet /= Standard then
                        ( [], context )

                    else
                        case Facts.find site context.factsIndex of
                            Just fact ->
                                ( checkCall context fact fnNode args, context )

                            Nothing ->
                                ( [], context )

                Nothing ->
                    ( [], context )

        _ ->
            ( [], context )


checkCall : Context -> Fact -> Node Expression -> List (Node Expression) -> List (Error {})
checkCall context fact fnNode args =
    let
        requiredSingular =
            fact.requiredSlots
                |> List.filter (\s -> not (List.member s fact.multiSlots))

        contentTrace =
            case List.reverse args |> List.head of
                Just contentNode ->
                    Facts.tracedList context.lookup context.scope contentNode

                Nothing ->
                    { known = [], unresolved = True }

        setterForSlot slotName =
            fact.slotRewrites
                |> List.filter (\( k, _ ) -> k == slotName)
                |> List.head
                |> Maybe.map Tuple.second
                |> Maybe.withDefault (Facts.camelize slotName)

        slotFilled slotName setter =
            if slotName == "unnamed" || slotName == "default" then
                -- The default slot is filled by raw default children in the
                -- content list, not by an explicit `<Comp>.child` setter.
                List.any
                    (Facts.fillsDefaultSlot [ Facts.factNamespaceParts fact ] context.lookup (Facts.namedSlotSetters fact) fact.component)
                    contentTrace.known

            else
                -- Facet-agnostic: a named slot is filled by its per-component
                -- setter (`<root>.<Comp>.header`) OR the generic barrel
                -- setter (`<root>.slotHeader`) `PreferBarrel` rewrites toward.
                let
                    acceptableSetters =
                        setter
                            :: (Facts.barrelSlotSetter fact slotName
                                    |> Maybe.map List.singleton
                                    |> Maybe.withDefault []
                               )
                in
                List.any (elementIsCall context (Facts.factNamespaceParts fact) fact.component acceptableSetters) contentTrace.known
    in
    requiredSingular
        |> List.filterMap
            (\slotName ->
                let
                    setter =
                        setterForSlot slotName
                in
                if contentTrace.unresolved then
                    Nothing

                else if slotFilled slotName setter then
                    Nothing

                else
                    Just
                        (Rule.error
                            { message =
                                "Component `"
                                    ++ fact.component
                                    ++ "` requires content slot `"
                                    ++ slotName
                                    ++ "` but the content list doesn't fill it"
                            , details =
                                [ "Add `"
                                    ++ Facts.factNamespace fact
                                    ++ "."
                                    ++ Facts.capitalize fact.component
                                    ++ "."
                                    ++ setter
                                    ++ " <value>` to the content list, or use `"
                                    ++ Facts.factNamespace fact
                                    ++ ".Record."
                                    ++ Facts.capitalize fact.component
                                    ++ ".view` which enforces this at the type level."
                                ]
                            }
                            (Node.range fnNode)
                        )
            )


{-| Check whether a content-list element calls one of the acceptable named
setters (per-component or generic barrel), verifying it resolves to the
top-layer barrel or `<root>.<Comp>` module.
-}
elementIsCall : Context -> List String -> String -> List String -> Node Expression -> Bool
elementIsCall context namespace componentNoun setters element =
    case Node.value element of
        Expression.Application (setterNode :: _) ->
            case Node.value setterNode of
                Expression.FunctionOrValue _ name ->
                    List.member name setters && Facts.isTopLayerModule [ namespace ] context.lookup setterNode componentNoun

                _ ->
                    False

        _ ->
            False
