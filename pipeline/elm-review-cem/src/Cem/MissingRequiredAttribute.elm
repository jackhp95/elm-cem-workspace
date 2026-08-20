module Cem.MissingRequiredAttribute exposing (rule)

{-| Flag component calls missing a required HTML attribute.

Reads `requiredAttrs` from the generated facts. For each required attr, checks
that a satisfier is present in the call's attribute list (or, for Record, in
the required record's fields).

Satisfier conventions:

  - `aria-*` attrs → `<root>.Aria.<lowerCamel(name)>` (e.g. `aria-label` → `<root>.Aria.label`).
  - Other attrs → `<root>.<Comp>.<camelCase(name)>` (per-component setter).
  - Universal escape → `<root>.Html.Attr.attribute "<name>" ...`.

Silent when `tracedList.unresolved = True` and no static satisfier is found.
Advisory posture.

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


{-| Build from the generated facts.
-}
rule : List Fact -> Rule
rule facts =
    Rule.newModuleRuleSchemaUsingContextCreator "MissingRequiredAttribute" (initContext facts)
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
                            ( checkCall context site fact fnNode args, context )

                        Nothing ->
                            ( [], context )

                Nothing ->
                    ( [], context )

        _ ->
            ( [], context )


checkCall : Context -> Facts.CallSite -> Fact -> Node Expression -> List (Node Expression) -> List (Error {})
checkCall context site fact fnNode args =
    if List.isEmpty fact.requiredAttrs then
        []

    else
        let
            ( recordArg, attrsList, contentList ) =
                case site.facet of
                    Standard ->
                        ( Nothing, List.head args, args |> List.drop 1 |> List.head )

                    Record ->
                        case args of
                            record :: attrs :: content :: _ ->
                                ( Just record, Just attrs, Just content )

                            record :: attrs :: _ ->
                                ( Just record, Just attrs, Nothing )

                            _ ->
                                ( Nothing, Nothing, Nothing )

                    _ ->
                        -- Facts.callSite only produces Standard or Record;
                        -- Raw/Html/Build never reach here. Exhaustiveness only.
                        ( Nothing, Nothing, Nothing )

            attrsTrace =
                case attrsList of
                    Just attrsNode ->
                        Facts.tracedList context.lookup context.scope attrsNode

                    Nothing ->
                        { known = [], unresolved = True }

            contentTrace =
                case contentList of
                    Just contentNode ->
                        Facts.tracedList context.lookup context.scope contentNode

                    Nothing ->
                        { known = [], unresolved = False }
        in
        fact.requiredAttrs
            |> List.filterMap (checkOneAttr context site fact recordArg attrsTrace contentTrace fnNode)


checkOneAttr :
    Context
    -> Facts.CallSite
    -> Fact
    -> Maybe (Node Expression)
    -> Facts.TracedList
    -> Facts.TracedList
    -> Node Expression
    -> String
    -> Maybe (Error {})
checkOneAttr context site fact recordArg attrsTrace contentTrace fnNode attrName =
    if
        satisfiedInRecord recordArg attrName
            || satisfiedInAttrs context attrsTrace fact attrName
            || satisfiedByLabelSlot context fact contentTrace attrName
    then
        Nothing

    else if attrsTrace.unresolved then
        -- Can't verify — silent per advisory posture.
        Nothing

    else
        Just
            (Rule.error
                { message =
                    "Component `"
                        ++ fact.component
                        ++ "` requires attribute `"
                        ++ attrName
                        ++ "` but this call doesn't provide it"
                , details =
                    [ "The component declares `"
                        ++ attrName
                        ++ "` as required for "
                        ++ fact.component
                        ++ " (and accessibility guidance treats an accessible name as non-optional)."
                    , "Add `" ++ satisfierHint fact attrName ++ "` to the attrs list."
                    ]
                }
                (Node.range fnNode)
            )


{-| True when `aria-label` is required but the component's label slot is filled
in the content list. A filled label slot provides the accessible name, making
aria-label redundant.

Detects `("label", setterName)` in `fact.slotRewrites` and then looks for a
call to `<root>.<Comp>.setterName` in the content list.

-}
satisfiedByLabelSlot : Context -> Fact -> Facts.TracedList -> String -> Bool
satisfiedByLabelSlot context fact contentTrace attrName =
    if attrName /= "aria-label" then
        False

    else
        case List.filter (\( slotName, _ ) -> slotName == "label") fact.slotRewrites of
            ( _, labelSetterName ) :: _ ->
                let
                    compModule =
                        Facts.factNamespaceParts fact ++ [ Facts.capitalize fact.component ]

                    -- The label slot can be filled on the per-component facet
                    -- (`<root>.<Comp>.<labelSetter>`) OR the barrel facet, where
                    -- `PreferBarrel` generalizes it to `<root>.<barrelSetter>`
                    -- (e.g. `M3e.slotLabel`).
                    barrelLabelSetter =
                        Facts.barrelSlotSetter fact "label"

                    isLabelCall setterNode =
                        isCallTo context compModule labelSetterName setterNode
                            || (case barrelLabelSetter of
                                    Just barrelSetter ->
                                        isCallTo context (Facts.factNamespaceParts fact) barrelSetter setterNode

                                    Nothing ->
                                        False
                               )

                    isLabelElement element =
                        case Node.value element of
                            Expression.Application (setterNode :: _) ->
                                isLabelCall setterNode

                            Expression.FunctionOrValue _ _ ->
                                -- Bare function reference (partial application, e.g. List.map <root>.Fab.label items)
                                isLabelCall element

                            _ ->
                                False
                in
                List.any isLabelElement contentTrace.known

            [] ->
                False


satisfiedInRecord : Maybe (Node Expression) -> String -> Bool
satisfiedInRecord recordArg attrName =
    case recordArg of
        Just record ->
            case Node.value record of
                Expression.RecordExpr fields ->
                    let
                        fieldName =
                            Facts.camelize attrName
                    in
                    List.any
                        (\field ->
                            let
                                ( name, _ ) =
                                    Node.value field
                            in
                            Node.value name == fieldName
                        )
                        fields

                _ ->
                    False

        Nothing ->
            False


satisfiedInAttrs : Context -> Facts.TracedList -> Fact -> String -> Bool
satisfiedInAttrs context attrsTrace fact attrName =
    List.any (attrElementSatisfies context fact attrName) attrsTrace.known


{-| An attribute is satisfied by a setter in the attrs list, recognised
**facet-agnostically**: the per-component form, the flat barrel re-export, or
the raw escape hatch. Missing any of these facets is what let a required-attr
violation hide (or a false-positive fire) depending on which facet the call
was written in.
-}
attrElementSatisfies : Context -> Fact -> String -> Node Expression -> Bool
attrElementSatisfies context fact attrName element =
    case Node.value element of
        Expression.Application (setterNode :: setterArgs) ->
            let
                -- ARIA: per-component `<root>.Aria.<x>` OR the flat barrel
                -- re-export `<root>.aria<X>` (`M3e.ariaLabel`).
                ariaSatisfier =
                    if String.startsWith "aria-" attrName then
                        let
                            suffix =
                                String.dropLeft 5 attrName
                        in
                        isCallTo context (Facts.factNamespaceParts fact ++ [ "Aria" ]) suffix setterNode
                            || isCallToAnyAriaAxis context suffix setterNode
                            || List.any (\ns -> isCallTo context ns (Facts.ariaBarrelName suffix) setterNode) context.namespaces

                    else
                        False

                -- Non-aria: per-component `<root>.<Comp>.<attr>` OR its flat
                -- barrel form (`<root>.attr<Name>`, or the bare `value`/`name`).
                perComponentSetter =
                    Facts.camelize attrName

                perComponentSatisfier =
                    isCallTo context (Facts.factNamespaceParts fact ++ [ Facts.capitalize fact.component ]) perComponentSetter setterNode
                        || (case Facts.attrBarrelName fact perComponentSetter of
                                Just barrelName ->
                                    isCallTo context (Facts.factNamespaceParts fact) barrelName setterNode

                                Nothing ->
                                    False
                           )

                rawAttributeSatisfier =
                    case ( isCallTo context (Facts.factNamespaceParts fact ++ [ "Html", "Attr" ]) "attribute" setterNode, setterArgs ) of
                        ( True, arg0 :: _ ) ->
                            case Node.value arg0 of
                                Expression.Literal literal ->
                                    literal == attrName

                                _ ->
                                    False

                        _ ->
                            False
            in
            ariaSatisfier || perComponentSatisfier || rawAttributeSatisfier

        _ ->
            False


{-| ARIA is a brand-agnostic concern axis: `TypedHtml.Aria.label`
(or any `<Brand>.Aria.<x>`) provides `aria-<x>` on ANY brand's element. Accept
a call to `<x>` resolved to any module whose LAST segment is `Aria`.
-}
isCallToAnyAriaAxis : Context -> String -> Node Expression -> Bool
isCallToAnyAriaAxis context expectedName setterNode =
    case Node.value setterNode of
        Expression.FunctionOrValue _ name ->
            (name == expectedName)
                && (case Lookup.moduleNameFor context.lookup setterNode of
                        Just moduleName ->
                            List.head (List.reverse moduleName) == Just "Aria"

                        Nothing ->
                            False
                   )

        _ ->
            False


satisfierHint : Fact -> String -> String
satisfierHint fact attrName =
    if String.startsWith "aria-" attrName then
        Facts.factNamespace fact ++ ".Aria." ++ String.dropLeft 5 attrName ++ " \"...\""

    else
        Facts.factNamespace fact ++ "." ++ Facts.capitalize fact.component ++ "." ++ Facts.camelize attrName ++ " \"...\""
