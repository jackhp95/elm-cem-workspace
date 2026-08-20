module Cem.ValidEnumValue exposing (rule)

{-| Codegen-aware rule: flag a **loose** enum setter given a `<root>.Value`
token the target component does not accept — e.g. `barrel.button [ variant circular ] …`
(a Button has no `circular` variant). The loose top-layer vocabulary accepts every
component's tokens at the type level on purpose; this rule is the correctness backstop
the types deliberately don't enforce.

Also flags **portmanteau** enum attribute identifiers (e.g. `variantRainbow`) applied
to a component whose enum for that attribute does not include that value. Portmanteau
attrs are nullary — they bake both the attribute name and value into a single identifier
— so the rule parses the identifier against the enums index to recover `(attr, value)`,
then applies the same validity check.

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
    Rule.newModuleRuleSchemaUsingContextCreator "ValidEnumValue"
        (initContext
            (buildIndex facts)
            (buildGlobalTokenIndex facts)
            (Facts.namespaces facts)
        )
        |> Rule.withDeclarationEnterVisitor declarationEnterVisitor
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


{-| component noun (e.g. "button") -> attr setter name (e.g. "variant") -> valid tokens.

Keyed by the canonical `Cem.Internal.Facts.buildIndex`, which inserts BOTH the
`factKey` (e.g. `"M3e.Component\u{0000}button"`) and a barrel-alias key (e.g.
`"M3e\u{0000}button"`) for components with a barrel root. Without the barrel
alias, loose barrel call sites (`M3e.button [ ... ]`, which resolve to the
barrel `siteKey`) never match a per-component-only index and the rule no-ops
on the entire loose barrel surface — see WS-D diagnosis.

-}
type alias Index =
    Dict String (Dict String (List String))


buildIndex : List Fact -> Index
buildIndex facts =
    Facts.buildIndex facts
        |> Dict.map (\_ f -> Dict.fromList f.enums)


{-| attr setter name -> all tokens that appear for that attr across ANY component.
Used to parse portmanteau identifiers: a suffix only resolves to a token if it
appears in the global set for the matching attr prefix.
-}
type alias GlobalTokenIndex =
    Dict String (List String)


buildGlobalTokenIndex : List Fact -> GlobalTokenIndex
buildGlobalTokenIndex facts =
    List.foldl
        (\fact acc ->
            List.foldl
                (\( attr, tokens ) innerAcc ->
                    let
                        existing =
                            Maybe.withDefault [] (Dict.get attr innerAcc)

                        merged =
                            List.foldl
                                (\tok tokAcc ->
                                    if List.member tok tokAcc then
                                        tokAcc

                                    else
                                        tokAcc ++ [ tok ]
                                )
                                existing
                                tokens
                    in
                    Dict.insert attr merged innerAcc
                )
                acc
                fact.enums
        )
        Dict.empty
        facts


type alias Context =
    { lookup : ModuleNameLookupTable
    , index : Index
    , globalTokens : GlobalTokenIndex
    , namespaces : List (List String)
    , scope : Dict String (Node Expression)
    }


initContext : Index -> GlobalTokenIndex -> List (List String) -> Rule.ContextCreator () Context
initContext index globalTokens namespaces =
    Rule.initContextCreator
        (\lookup () ->
            { lookup = lookup
            , index = index
            , globalTokens = globalTokens
            , namespaces = namespaces
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

Also handles the nullary portmanteau form: a bare `variantRainbow` identifier that
resolves to the library's Attributes module and parses as `<attr><PascalToken>` against
the component's enums.

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

        Expression.FunctionOrValue _ name ->
            checkPortmanteau context namespace enums elementNode name

        _ ->
            Nothing


{-| Check a bare identifier against the portmanteau pattern `<attrName><PascalToken>`.

Resolution:

1.  Verify the identifier resolves to the library namespace (any remainder is fine —
    `Attributes`, bare barrel, or any other module — as long as it is under one of
    the known library namespaces). This guards against flagging user-defined names.
2.  For each attr the component supports, check whether `identifier` equals
    `attr ++ capitalize(tok)` for some `tok` in the GLOBAL token set for that attr.
3.  If matched, apply the same validity check: is `tok` in this component's valid tokens
    for `attr`? If not, emit an error.

-}
checkPortmanteau : Context -> List String -> Dict String (List String) -> Node Expression -> String -> Maybe (Error {})
checkPortmanteau context namespace enums elementNode identifier =
    if not (isLibraryRef context.namespaces context.lookup elementNode) then
        Nothing

    else
        resolvePortmanteau identifier enums context.globalTokens
            |> Maybe.andThen
                (\( attr, token ) ->
                    case Dict.get attr enums of
                        Just validTokens ->
                            if List.member token validTokens then
                                Nothing

                            else
                                Just (portmanteauError attr validTokens token (Node.range elementNode))

                        Nothing ->
                            Nothing
                )


{-| Attempt to parse `identifier` as `<attrName><PascalToken>` against the component's
enums and the global token set.

For each attr the component exposes, check whether the identifier equals
`attr ++ capitalize(tok)` for some `tok` in the global token universe for that attr.
Returns the first match found.

-}
resolvePortmanteau : String -> Dict String (List String) -> GlobalTokenIndex -> Maybe ( String, String )
resolvePortmanteau identifier enums globalTokens =
    Dict.keys enums
        |> firstJust
            (\attr ->
                if String.startsWith attr identifier then
                    let
                        suffix =
                            String.dropLeft (String.length attr) identifier
                    in
                    if String.isEmpty suffix then
                        Nothing

                    else
                        let
                            token =
                                Facts.decapitalize suffix
                        in
                        case Dict.get attr globalTokens of
                            Just globalToks ->
                                if List.member token globalToks then
                                    Just ( attr, token )

                                else
                                    Nothing

                            Nothing ->
                                Nothing

                else
                    Nothing
            )


{-| True iff `node` resolves to a module under one of the known library namespaces.
This distinguishes a library portmanteau attr from a user-defined function of the same
name.
-}
isLibraryRef : List (List String) -> ModuleNameLookupTable -> Node Expression -> Bool
isLibraryRef namespaces lookup node =
    case Lookup.moduleNameFor lookup node of
        Just moduleName ->
            List.any
                (\ns ->
                    case Facts.dropPrefix ns moduleName of
                        Just _ ->
                            True

                        Nothing ->
                            False
                )
                namespaces

        Nothing ->
            False


firstJust : (a -> Maybe b) -> List a -> Maybe b
firstJust f xs =
    case xs of
        [] ->
            Nothing

        x :: rest ->
            case f x of
                Just y ->
                    Just y

                Nothing ->
                    firstJust f rest


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


{-| The token name a `Values.<token>` (or exposed `<token>`) reference names.

The generated value-token module is `<root>.Values` (e.g. `M3e.Values.rainbow`),
not `<root>.Token` — the latter was this rule's own stale assumption and never
matched real generated code, so the two-node form (`MA.variant MV.rainbow`)
silently no-op'd even when the index resolved. `"Token"` is kept alongside
`"Values"` in case any hand-written/legacy facet still uses that naming.

-}
valueToken : Context -> List String -> Node Expression -> Maybe String
valueToken context namespace tokenNode =
    case Node.value tokenNode of
        Expression.FunctionOrValue _ name ->
            case Maybe.andThen (Facts.dropPrefix namespace) (Lookup.moduleNameFor context.lookup tokenNode) of
                Just [ "Values" ] ->
                    Just name

                Just [ "Token" ] ->
                    Just name

                _ ->
                    -- also accept an unqualified token that resolves nowhere useful;
                    -- be conservative and only flag when we resolved it to the
                    -- library's value-token module.
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


portmanteauError : String -> List String -> String -> { start : { row : Int, column : Int }, end : { row : Int, column : Int } } -> Error {}
portmanteauError attr validTokens token range =
    Rule.error
        { message = "`" ++ token ++ "` is not a valid `" ++ attr ++ "` value for this component"
        , details =
            [ "This component's `" ++ attr ++ "` enum only accepts: " ++ String.join ", " validTokens ++ "."
            , "The portmanteau attribute `" ++ attr ++ Facts.capitalize token ++ "` bakes in a value this component does not support. Use a portmanteau the component accepts, or the component-module's strict setter."
            ]
        }
        range
