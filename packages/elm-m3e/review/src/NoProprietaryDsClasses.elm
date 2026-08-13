module NoProprietaryDsClasses exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node(..))
import Review.ModuleNameLookupTable as ModuleNameLookupTable exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)


{-| Reports use of proprietary `ds-*` / `t-*` CSS classes anywhere in the code.

These classes are project-proprietary tokens that are **not** part of Material
and ship **no CSS** in this library — applying one renders nothing. The compiler
cannot see this because `class : String -> Attribute msg` accepts any string.

The rule inspects string-literal arguments to `Html.Attributes.class`,
`Html.Attributes.classList`, and any `…withClass` builder setter, and reports a
string whose space-separated tokens include one prefixed `ds-` or `t-`.


## Fail

    Html.div [ Attr.class "ds-card-media" ] []

    Attr.class "t-primary"

    Ui.Shape.withClass "ds-w-16"


## Success

    Html.div [ Attr.class "flex items-center" ] []

-}
rule : Rule
rule =
    Rule.newModuleRuleSchemaUsingContextCreator "NoProprietaryDsClasses" initialContext
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


type alias Context =
    { lookupTable : ModuleNameLookupTable }


initialContext : Rule.ContextCreator () Context
initialContext =
    Rule.initContextCreator (\lookupTable () -> { lookupTable = lookupTable })
        |> Rule.withModuleNameLookupTable


expressionVisitor : Node Expression -> Context -> ( List (Error {}), Context )
expressionVisitor node context =
    case Node.value node of
        Expression.Application (fn :: arg :: []) ->
            ( checkClassCall context fn arg, context )

        _ ->
            ( [], context )


checkClassCall : Context -> Node Expression -> Node Expression -> List (Error {})
checkClassCall context fn arg =
    case fn of
        Node _ (Expression.FunctionOrValue _ name) ->
            if isClassLike context fn name then
                checkStringLiteral arg

            else if name == "classList" && resolvesToHtmlAttributes context fn then
                checkClassList arg

            else
                []

        _ ->
            []


{-| `Html.Attributes.class`, or any builder setter named `withClass`.
-}
isClassLike : Context -> Node Expression -> String -> Bool
isClassLike context fn name =
    (name == "class" && resolvesToHtmlAttributes context fn)
        || (name == "withClass")


resolvesToHtmlAttributes : Context -> Node Expression -> Bool
resolvesToHtmlAttributes context fn =
    case ModuleNameLookupTable.moduleNameFor context.lookupTable fn of
        Just [ "Html", "Attributes" ] ->
            True

        _ ->
            False


checkStringLiteral : Node Expression -> List (Error {})
checkStringLiteral node =
    case Node.value node of
        Expression.Literal str ->
            if hasProprietaryToken str then
                [ proprietaryError node ]

            else
                []

        _ ->
            []


{-| `classList [ ( "ds-active", cond ), … ]` — check each tuple's first element.
-}
checkClassList : Node Expression -> List (Error {})
checkClassList node =
    case Node.value node of
        Expression.ListExpr entries ->
            List.concatMap checkClassListEntry entries

        _ ->
            []


checkClassListEntry : Node Expression -> List (Error {})
checkClassListEntry node =
    case Node.value node of
        Expression.TupledExpression (keyNode :: _) ->
            checkStringLiteral keyNode

        _ ->
            []


hasProprietaryToken : String -> Bool
hasProprietaryToken str =
    str
        |> String.words
        |> List.any (\token -> String.startsWith "ds-" token || String.startsWith "t-" token)


proprietaryError : Node Expression -> Error {}
proprietaryError node =
    Rule.error
        { message = "Proprietary CSS class — not Material, ships no CSS"
        , details =
            [ "`ds-*` and `t-*` classes are project-proprietary tokens that are not part of Material and ship no CSS in this library, so they render nothing."
            , "Use a typed M3e slot/role binding or a real utility class instead."
            ]
        }
        (Node.range node)
