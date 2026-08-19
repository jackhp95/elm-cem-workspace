module Cem.MissingRequiredSingularSlot exposing (rule)

{-| Flag `component` calls whose required-record argument omits a required-singular slot's
field.

In the four-package shape, EVERY component with at least one required-singular
slot takes that content through its `component` constructor's leading required record
(`component : { content : ..., action : ... } -> attrs -> children -> Element`), never
through the loose content list — the loose Html producer (`<root>.button`) is the
escape hatch, the `component` record arity is where required content is enforced.
A well-typed record LITERAL at
the call site already has every field (Elm won't compile a partial one against a
fixed record type), so this rule only has something to catch on code that is
mid-edit or otherwise not yet type-checking. Advisory posture — silent whenever
the record argument can't be resolved statically (a variable, a helper-built
record, point-free application, etc.), same posture the content-list tracer
already uses for `List.map`/opaque expressions.

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
                                ( checkCall context site.namespace fact fnNode args, context )

                            Nothing ->
                                ( [], context )

                Nothing ->
                    ( [], context )

        _ ->
            ( [], context )


checkCall : Context -> List String -> Fact -> Node Expression -> List (Node Expression) -> List (Error {})
checkCall context namespace fact fnNode args =
    let
        requiredSingular =
            fact.requiredSlots
                |> List.filter (\s -> not (List.member s fact.multiSlots))
    in
    if List.isEmpty requiredSingular then
        []

    else
        -- `requiredSingular` non-empty means the generator gave this component's
        -- `component` ctor the required-record arity: the record is ALWAYS the
        -- leading argument, whatever else is (or isn't) applied after it.
        case List.head args |> Maybe.andThen (resolveRecordFields context) of
            Nothing ->
                -- Can't statically resolve the record argument — stay silent.
                []

            Just fieldNames ->
                requiredSingular
                    |> List.filterMap
                        (\slotName ->
                            let
                                fieldName =
                                    recordFieldNameForSlot slotName
                            in
                            if List.member fieldName fieldNames then
                                Nothing

                            else
                                Just
                                    (Rule.error
                                        { message =
                                            "Component `"
                                                ++ fact.component
                                                ++ "` requires content slot `"
                                                ++ slotName
                                                ++ "` but the record argument doesn't set it"
                                        , details =
                                            [ "Add `"
                                                ++ fieldName
                                                ++ " = <value>` to the record passed to `"
                                                ++ String.join "." namespace
                                                ++ "."
                                                ++ fact.component
                                                ++ "` (the leading record of its `component` constructor), which enforces this at the type level."
                                            ]
                                        }
                                        (Node.range fnNode)
                                    )
                        )


{-| The required record's field name for a raw slot name, mirroring the
generator's own derivation (`elm-cem/codegen/Generate/Phantom/Emit.elm`,
`reqField`): the default slot's field is always `content`; every other
required-singular slot's field is the plain camelCase of its raw (possibly
kebab-case) slot name — NOT `slotRewrites`, which names the (now-gone)
content-list setter instead.
-}
recordFieldNameForSlot : String -> String
recordFieldNameForSlot slotName =
    if slotName == "unnamed" || slotName == "default" then
        "content"

    else
        Facts.camelize slotName


{-| Resolve a call argument to the field names of the record LITERAL it
statically is, following simple let-bound variable references (with cycle
protection) the same way `Facts.tracedList` follows list-valued ones. Returns
`Nothing` for anything else (a function call, a piped/point-free argument, an
unbound or external variable) — those are left for the advisory-silent path.
-}
resolveRecordFields : Context -> Node Expression -> Maybe (List String)
resolveRecordFields context node =
    resolveRecordFieldsWith context.scope Dict.empty node


resolveRecordFieldsWith : Dict String (Node Expression) -> Dict String Bool -> Node Expression -> Maybe (List String)
resolveRecordFieldsWith scope seen node =
    case Node.value node of
        Expression.RecordExpr setters ->
            Just (List.map (\setter -> Node.value setter |> Tuple.first |> Node.value) setters)

        Expression.ParenthesizedExpression inner ->
            resolveRecordFieldsWith scope seen inner

        Expression.FunctionOrValue [] name ->
            if Dict.member name seen then
                Nothing

            else
                Dict.get name scope
                    |> Maybe.andThen (resolveRecordFieldsWith scope (Dict.insert name True seen))

        _ ->
            Nothing
