module Cem.SingularAttribute exposing (rule)

{-| Attribute-half rule: flag a call whose attrs list sets the same attribute
setter more than once. Most HTML attributes can hold only one value; a repeated
attr is a bug (the browser keeps one at random).

Mirrors `SingularSlot` for the content half.

**Multi-attributes are exempt.** A few attributes are token lists rather than
single values, and the IR these setters build merges them instead of letting
one win — so a repeat is idiomatic, not a bug. `HtmlIr.Internal` routes
`"class"` to a structural fact specifically "so it merges", `toHtml` is
documented as "where the `class` / `style` merge happens", and
`TypedHtml.Attributes.class` says it "accumulates with every other `class` /
`classList` on the element". Flagging those told authors to fix a bug that
cannot happen, with a rationale (the browser discards the extras) that is
false for this stack.

`style` is exempt for the merging setters only. The raw
`HtmlIr.Internal.attribute "style"` form deliberately CLOBBERS rather than
merges — splitting a declaration block would mean parsing CSS, and `;`/`:`
occur inside `url(data:…)` values — but that form is not a named setter and so
never reaches this rule's `elementSetter` in the first place.

@docs rule

-}

import Cem.Facts exposing (Facet(..), Fact)
import Cem.Internal.Facts as Facts
import Cem.Internal.ListExtra exposing (countBy, dedupeByName)
import Dict exposing (Dict)
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Review.ModuleNameLookupTable exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)


{-| Build from the generated facts.
-}
rule : List Fact -> Rule
rule facts =
    Rule.newModuleRuleSchemaUsingContextCreator "SingularAttribute" (initContext (Facts.namespaces facts))
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


type alias Context =
    { lookup : ModuleNameLookupTable
    , namespaces : List (List String)
    , scope : Dict String (Node Expression)
    }


initContext : List (List String) -> Rule.ContextCreator () Context
initContext namespaces =
    Rule.initContextCreator
        (\lookup () ->
            { lookup = lookup
            , namespaces = namespaces
            , scope = Dict.empty
            }
        )
        |> Rule.withModuleNameLookupTable


expressionVisitor : Node Expression -> Context -> ( List (Error {}), Context )
expressionVisitor node context =
    case Node.value node of
        Expression.Application (fnNode :: args) ->
            case Facts.callSite context.namespaces context.lookup fnNode of
                Just site ->
                    let
                        attrsList =
                            case site.facet of
                                Standard ->
                                    List.head args

                                Record ->
                                    case args of
                                        _ :: attrs :: _ ->
                                            Just attrs

                                        _ ->
                                            Nothing

                                _ ->
                                    Nothing

                        attrsTrace =
                            case attrsList of
                                Just node_ ->
                                    Facts.tracedList context.lookup context.scope node_

                                Nothing ->
                                    { known = [], unresolved = True }
                    in
                    ( checkAttrs attrsTrace, context )

                Nothing ->
                    ( [], context )

        _ ->
            ( [], context )


{-| Attributes whose values are token lists the IR merges, so setting them more
than once is idiomatic rather than a bug. See this module's docs for the
merge semantics these names rely on.
-}
multiAttributes : List String
multiAttributes =
    [ "class", "classList", "style", "styles" ]


checkAttrs : Facts.TracedList -> List (Error {})
checkAttrs trace =
    if trace.unresolved then
        []

    else
        let
            setters =
                trace.known |> List.filterMap elementSetter
        in
        setters
            |> List.filter (\( name, _ ) -> not (List.member name multiAttributes))
            |> List.filter (\( name, _ ) -> countBy name setters > 1)
            |> dedupeByName
            |> List.map (\( name, range ) -> error name range)


elementSetter :
    Node Expression
    -> Maybe ( String, { start : { row : Int, column : Int }, end : { row : Int, column : Int } } )
elementSetter element =
    case Node.value element of
        Expression.Application (setterNode :: _) ->
            case Node.value setterNode of
                Expression.FunctionOrValue _ name ->
                    Just ( name, Node.range setterNode )

                _ ->
                    Nothing

        _ ->
            Nothing


error :
    String
    -> { start : { row : Int, column : Int }, end : { row : Int, column : Int } }
    -> Error {}
error name range =
    Rule.error
        { message = "Attribute `" ++ name ++ "` is set more than once on this call"
        , details =
            [ "HTML allows only one value per attribute; the browser will silently keep one and discard the others."
            , "Merge or delete the extras."
            ]
        }
        range
