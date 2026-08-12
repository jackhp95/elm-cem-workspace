module Cem.ValidEnumValue exposing (rule)

{-| Codegen-aware rule: flag a **loose** enum setter given a `<root>.Value`
token the target component does not accept — e.g. `barrel.button [ variant circular ] …`
(a Button has no `circular` variant). The loose top-layer vocabulary accepts every
component's tokens at the type level on purpose; this rule is the correctness backstop
the types deliberately don't enforce.

Per-component validity comes from the generated `Cem.Facts` (generated from the CEM),
injected into the rule — so it stays correct as the underlying components change without
editing rule logic.

@docs rule

-}

import Cem.Facts exposing (Fact)
import Cem.Internal.Facts as Facts
import Dict exposing (Dict)
import Elm.Syntax.Declaration as Declaration
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Review.ModuleNameLookupTable as Lookup exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)


{-| Build the rule from the generated facts (pass the generated `facts` value).
-}
rule : List Fact -> Rule
rule facts =
    Rule.newModuleRuleSchemaUsingContextCreator "ValidEnumValue" (initContext (buildIndex facts) (Facts.namespaces facts))
        |> Rule.withDeclarationEnterVisitor declarationEnterVisitor
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


{-| component noun (e.g. "button") -> attr setter name (e.g. "variant") -> valid tokens.
-}
type alias Index =
    Dict String (Dict String (List String))


buildIndex : List Fact -> Index
buildIndex facts =
    facts
        |> List.map (\f -> ( Facts.factKey f, Dict.fromList f.enums ))
        |> Dict.fromList


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
                        Just enums ->
                            let
                                -- Enum SETTERS live in the attribute argument(s); the
                                -- trailing argument is the content/children list, whose
                                -- elements are child nodes, not setters. Excluding it
                                -- mirrors SingularSlot/RequireSlot and avoids flagging a
                                -- child that happens to be enum-setter-shaped (#90).
                                attrArgs =
                                    if List.length args >= 2 then
                                        List.take (List.length args - 1) args

                                    else
                                        args
                            in
                            ( List.concatMap (checkArg context site.namespace enums) attrArgs, context )

                        Nothing ->
                            ( [], context )

                Nothing ->
                    ( [], context )

        _ ->
            ( [], context )


{-| Within a constructor argument that could be an attribute list, check each enum setter.
Uses `Facts.tracedList` to resolve dynamic expressions. We only flag elements we can
statically resolve to known setters — dynamic parts are silently ignored.
-}
checkArg : Context -> List String -> Dict String (List String) -> Node Expression -> List (Error {})
checkArg context namespace enums argNode =
    let
        traced =
            Facts.tracedList context.lookup context.scope argNode
    in
    List.filterMap (checkSetter context namespace enums) traced.known


{-| An `<enumSetter> <valueToken>` application whose token isn't valid for this
component is the error.
-}
checkSetter : Context -> List String -> Dict String (List String) -> Node Expression -> Maybe (Error {})
checkSetter context namespace enums elementNode =
    case Node.value elementNode of
        Expression.Application (setterNode :: tokenNode :: _) ->
            case ( setterName setterNode, Dict.get (setterNameString setterNode) enums, valueToken context namespace tokenNode ) of
                ( _, Just validTokens, Just token ) ->
                    if List.member token validTokens then
                        Nothing

                    else
                        Just (error validTokens token (Node.range tokenNode))

                _ ->
                    Nothing

        _ ->
            Nothing


setterName : Node Expression -> Maybe String
setterName n =
    case Node.value n of
        Expression.FunctionOrValue _ name ->
            Just name

        _ ->
            Nothing


setterNameString : Node Expression -> String
setterNameString n =
    Maybe.withDefault "" (setterName n)


{-| The token name a `Value.<token>` (or exposed `<token>`) reference names.
-}
valueToken : Context -> List String -> Node Expression -> Maybe String
valueToken context namespace tokenNode =
    case Node.value tokenNode of
        Expression.FunctionOrValue _ name ->
            if Maybe.andThen (Facts.dropPrefix namespace) (Lookup.moduleNameFor context.lookup tokenNode) == Just [ "Token" ] then
                Just name

            else
                -- also accept an unqualified token that resolves nowhere useful;
                -- be conservative and only flag when we resolved it to the
                -- library's Value module.
                Nothing

        _ ->
            Nothing


error : List String -> String -> { start : { row : Int, column : Int }, end : { row : Int, column : Int } } -> Error {}
error validTokens token range =
    Rule.error
        { message = "`" ++ token ++ "` is not a valid value for this component"
        , details =
            [ "This component's enum only accepts: " ++ String.join ", " validTokens ++ "."
            , "The loose top-layer vocabulary lets any token type-check; use one this component actually supports, or the component-module's strict setter (which rejects the wrong token at compile time)."
            ]
        }
        range
