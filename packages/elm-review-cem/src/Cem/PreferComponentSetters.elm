module Cem.PreferComponentSetters exposing (rule)

{-| Opt-in autofix: upgrade a GENERIC barrel slot setter to the COMPONENT
setter, driven by `Cem.Facts`.

Inside a barrel constructor call `<root>.<noun> [attrs] [content]`, a generic
slot setter in the content (`<root>.slotLeading`) is rewritten to the component
setter re-exported for that component (`<root>.listItemSlotLeading`) via the
component's `slotUpgrades` (generic → component). Both forms are re-exposed by
the `<root>` barrel, so the rewrite changes NO imports.

The generic setter accepts any element valid in SOME component's version of
the slot (its input row is the union of every component's kinds); the component
setter is scoped to this component's kinds, so the compiler rejects a wrong-kind
child. The loose generic form is the teaching form, the component setter is the
precise one.

It is the counterpart of `PreferBarrel` (component module → generic barrel):
this rule takes generic barrel → component setter, keeping the single import.

@docs rule

-}

import Cem.Facts exposing (Fact)
import Cem.Internal.Facts as Facts
import Dict exposing (Dict)
import Elm.Syntax.Declaration as Declaration
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Review.Fix as Fix
import Review.ModuleNameLookupTable as Lookup exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)


{-| Build from the generated facts (`Cem.Facts`).
-}
rule : List Fact -> Rule
rule facts =
    Rule.newModuleRuleSchemaUsingContextCreator "PreferComponentSetters" (initContext facts)
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


{-| Collect a declaration's top-level `let` bindings so a content list bound to a
name (`let content = [ … ] in <root>.listItem [] content`) is still traceable.
-}
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
                            ( slotErrors context fact args, context )

                        Nothing ->
                            ( [], context )

                Nothing ->
                    ( [], context )

        _ ->
            ( [], context )


{-| For each element in the constructor's content list (its LAST argument) that
is a generic slot setter this component declares, emit an upgrade to the
component-specific setter.
-}
slotErrors : Context -> Fact -> List (Node Expression) -> List (Error {})
slotErrors context fact args =
    let
        contentTrace =
            case List.reverse args |> List.head of
                Just contentNode ->
                    Facts.tracedList context.lookup context.scope contentNode

                Nothing ->
                    { known = [], unresolved = True }
    in
    List.filterMap (slotErrorFor context fact) contentTrace.known


slotErrorFor : Context -> Fact -> Node Expression -> Maybe (Error {})
slotErrorFor context fact element =
    case Node.value element of
        Expression.Application (setterNode :: _) ->
            case ( Node.value setterNode, Maybe.andThen (Facts.dropPrefix (Facts.factNamespaceParts fact)) (Lookup.moduleNameFor context.lookup setterNode) ) of
                ( Expression.FunctionOrValue _ name, Just [] ) ->
                    fact.slotUpgrades
                        |> List.filter (\( generic, _ ) -> generic == name)
                        |> List.head
                        |> Maybe.map
                            (\( generic, specific ) ->
                                let
                                    root =
                                        Facts.factNamespace fact

                                    replacement =
                                        root ++ "." ++ specific
                                in
                                Rule.errorWithFix
                                    { message =
                                        "The generic setter `"
                                            ++ root
                                            ++ "."
                                            ++ generic
                                            ++ "` can be replaced with the component setter `"
                                            ++ replacement
                                            ++ "`"
                                    , details =
                                        [ "The generic barrel slot setter accepts any element valid in some component's version of the slot; the component setter is scoped to this component, so the compiler rejects a wrong-kind child. Both are re-exposed by the `"
                                            ++ root
                                            ++ "` barrel, so this changes no imports."
                                        ]
                                    }
                                    (Node.range setterNode)
                                    [ Fix.replaceRangeBy (Node.range setterNode) replacement ]
                            )

                _ ->
                    Nothing

        _ ->
            Nothing
