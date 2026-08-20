module Cem.PreferComponentModules exposing (rule)

{-| Prefer per-component setters over barrel shorthands, with autofix.

Two cases:

  - Attr case: `<root>.<barrelName>` inside a component's attrs list → rewrite to
    `<root>.<Comp>.<perCompName>` using `attrRewrites`.
  - Slot case: `<root>.Content.slot "<slotName>" body` in the content list →
    rewrite to `<root>.<Comp>.<setterName> body` using `slotRewrites`.

Autofix atomically inserts `import <root>.<Comp>` when the module is not yet
imported, placing it after the last existing import (or after the module
definition line if there are no imports).

This is the exact inverse of `Cem.PreferBarrel`, and resolves the flat barrel the
same way. The barrel producers/setters/tokens/aria a call references live at the
BARREL ROOT (`Cem.Internal.Facts.barrelRoot` — `Lib`), which in a four-package
shape is one level UP from the per-component namespace (`Lib.Component`); detection
must strip the barrel root, and the barrel-root-level replacements (`Lib.Aria`,
`Lib.Token`, the slot-upgrade setters) target it too. Only the per-component
replacement (`Lib.Component.<Comp>.<setter>`) uses the fact namespace. Using the
fact namespace where the barrel root is meant is the bug that made this rule inert
in the four-package shape. The constructor case additionally skips a record-form
`component` (`Facts.hasRecordFormConstructor`): the loose barrel producer and the
record-form smart ctor are different functions, so specialising one to the other
is a type error — the mirror of `PreferBarrel`'s record-form skip.

@docs rule

-}

import Cem.Facts exposing (Facet(..), Fact)
import Cem.Internal.BarrelMapping as Mapping
import Cem.Internal.Facts as Facts
import Dict exposing (Dict)
import Elm.Syntax.Declaration as Declaration
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Import exposing (Import)
import Elm.Syntax.Module as Module
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Range exposing (Range)
import Review.Fix as Fix
import Review.ModuleNameLookupTable as Lookup exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)
import Set exposing (Set)


{-| Build from the generated facts (`Cem.Facts`).
-}
rule : List Fact -> Rule
rule facts =
    Rule.newModuleRuleSchemaUsingContextCreator "PreferComponentModules" (initContext facts)
        |> Rule.withModuleDefinitionVisitor moduleDefinitionVisitor
        |> Rule.withImportVisitor importVisitor
        |> Rule.withDeclarationEnterVisitor declarationEnterVisitor
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


type alias Context =
    { lookup : ModuleNameLookupTable
    , factsIndex : Dict String Fact
    , scope : Dict String (Node Expression)
    , extractSourceCode : Range -> String
    , importedModules : Set (List String)
    , insertionRow : Int
    , namespaces : List (List String)
    }


initContext : List Fact -> Rule.ContextCreator () Context
initContext facts =
    Rule.initContextCreator
        (\lookup extractSourceCode () ->
            { lookup = lookup
            , factsIndex = Facts.buildIndex facts
            , scope = Dict.empty
            , extractSourceCode = extractSourceCode
            , importedModules = Set.empty
            , insertionRow = 1
            , namespaces = Facts.namespaces facts
            }
        )
        |> Rule.withModuleNameLookupTable
        |> Rule.withSourceCodeExtractor


moduleDefinitionVisitor : Node Module.Module -> Context -> ( List (Error {}), Context )
moduleDefinitionVisitor node context =
    let
        endRow =
            (Node.range node).end.row
    in
    ( [], { context | insertionRow = endRow } )


importVisitor : Node Import -> Context -> ( List (Error {}), Context )
importVisitor node context =
    let
        imp =
            Node.value node

        moduleName =
            Node.value imp.moduleName

        endRow =
            (Node.range node).end.row
    in
    ( []
    , { context
        | importedModules = Set.insert moduleName context.importedModules
        , insertionRow = endRow
      }
    )


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
                            -- An ordinary constructor: the barrel form `<root>.<noun>`
                            -- specialises to `<root>.Component.<Comp>.component`.
                            ( checkCall context site fact fnNode "component" args, context )

                        Nothing ->
                            -- A variant-group member (`<root>.circular`) whose noun is
                            -- not a component but a member of one's `groupConstructors`;
                            -- it specialises to `<root>.<Comp>.<member>`.
                            case findByGroupConstructor site.noun context.factsIndex of
                                Just fact ->
                                    ( checkCall context site fact fnNode site.noun args, context )

                                Nothing ->
                                    ( [], context )

                Nothing ->
                    ( [], context )

        _ ->
            ( [], context )


{-| Find the fact for a variant-group whose `groupConstructors` include `noun`
(e.g. `"circular"` → the `progress` fact). Used to specialise a barrel group
member `<root>.<noun>` back to `<root>.<Comp>.<noun>`.
-}
findByGroupConstructor : String -> Dict String Fact -> Maybe Fact
findByGroupConstructor noun factsIndex =
    factsIndex
        |> Dict.values
        |> List.filter (\f -> List.member noun f.groupConstructors)
        |> List.head


checkCall : Context -> Facts.CallSite -> Fact -> Node Expression -> String -> List (Node Expression) -> List (Error {})
checkCall context site fact fnNode constructorMember args =
    let
        ( maybeAttrsList, maybeContentList ) =
            case site.facet of
                Standard ->
                    case args of
                        a :: c :: _ ->
                            ( Just a, Just c )

                        [ a ] ->
                            ( Just a, Nothing )

                        _ ->
                            ( Nothing, Nothing )

                Record ->
                    case args of
                        _ :: a :: c :: _ ->
                            ( Just a, Just c )

                        _ ->
                            ( Nothing, Nothing )

                _ ->
                    ( Nothing, Nothing )

        constructorErrors =
            constructorErrorFor context fact fnNode constructorMember
                |> Maybe.map List.singleton
                |> Maybe.withDefault []

        attrErrors =
            maybeAttrsList
                |> Maybe.map (checkAttrs context fact)
                |> Maybe.withDefault []

        slotErrors =
            maybeContentList
                |> Maybe.map (checkSlots context fact)
                |> Maybe.withDefault []

        slotUpgradeErrors =
            maybeContentList
                |> Maybe.map (checkSlotUpgrades context fact)
                |> Maybe.withDefault []
    in
    constructorErrors ++ attrErrors ++ slotErrors ++ slotUpgradeErrors


{-| The constructor case: the barrel form `<root>.<noun>` (`<root>.button`, or a
variant-group member `<root>.circular`) specialises to `<root>.<Comp>.<member>`
(`<root>.Component.Button.component`, `<root>.Progress.circular`). Fires only when `fnNode`
resolves to the barrel ROOT — an already-specific `<root>.Component.<Comp>.component` is left
alone (its attrs/slots may still be barrel forms and get rewritten separately).
Inverse of `PreferBarrel.barrelReplacement`'s constructor branch.
-}
constructorErrorFor : Context -> Fact -> Node Expression -> String -> Maybe (Error {})
constructorErrorFor context fact fnNode constructorMember =
    if constructorMember == "component" && Facts.hasRecordFormConstructor fact then
        -- Record-form smart ctor: the per-component `component` takes a leading
        -- required-fields record (`{ content, … } -> attrs -> children`) and is a
        -- DIFFERENT function from the loose barrel producer `<root>.<noun>`
        -- (`attrs -> children`). Specialising the loose barrel call to it is a type
        -- error, so leave it — the exact mirror of `PreferBarrel`'s record-form
        -- skip. A variant-group member (`constructorMember /= "component"`) is
        -- always a loose producer, so it is never skipped here.
        Nothing

    else if Maybe.andThen (Facts.dropPrefix (Facts.barrelRootParts fact)) (Lookup.moduleNameFor context.lookup fnNode) == Just [] then
        let
            compModule =
                Facts.factNamespace fact ++ "." ++ Facts.capitalize fact.component

            compModuleParts =
                Facts.factNamespaceParts fact ++ [ Facts.capitalize fact.component ]

            replacement =
                compModule ++ "." ++ constructorMember

            fixes =
                Fix.replaceRangeBy (Node.range fnNode) replacement
                    :: importFixIfMissing context compModule compModuleParts
        in
        Just
            (Rule.errorWithFix
                { message =
                    "The barrel call can be replaced with the component-module `"
                        ++ replacement
                        ++ "`"
                , details =
                    [ "The component-module constructor scopes this call's attrs and slots to "
                        ++ fact.component
                        ++ ", so the compiler rejects another component's setters."
                    ]
                }
                (Node.range fnNode)
                fixes
            )

    else
        Nothing


checkAttrs : Context -> Fact -> Node Expression -> List (Error {})
checkAttrs context fact attrsNode =
    let
        trace =
            Facts.tracedList context.lookup context.scope attrsNode

        -- Each attr element is at most one of: a component-attr barrel setter, an
        -- aria combined (`ariaLabel`), or an enum value combined
        -- (`variantFilled`). Try each; take the first that matches.
        errorFor element =
            case attrErrorFor context fact element of
                Just err ->
                    Just err

                Nothing ->
                    case ariaErrorFor context fact element of
                        Just err ->
                            Just err

                        Nothing ->
                            combinedErrorFor context fact element
    in
    if trace.unresolved then
        []

    else
        List.filterMap errorFor trace.known


attrErrorFor : Context -> Fact -> Node Expression -> Maybe (Error {})
attrErrorFor context fact element =
    case Node.value element of
        Expression.Application (setterNode :: _) ->
            case ( Node.value setterNode, Maybe.andThen (Facts.dropPrefix (Facts.barrelRootParts fact)) (Lookup.moduleNameFor context.lookup setterNode) ) of
                ( Expression.FunctionOrValue _ name, Just [] ) ->
                    Mapping.attrToPerComponent fact name
                        |> Maybe.map
                            (\perCompName ->
                                let
                                    compModule =
                                        Facts.factNamespace fact ++ "." ++ Facts.capitalize fact.component

                                    compModuleParts =
                                        Facts.factNamespaceParts fact ++ [ Facts.capitalize fact.component ]

                                    replacement =
                                        compModule ++ "." ++ perCompName

                                    fixes =
                                        Fix.replaceRangeBy (Node.range setterNode) replacement
                                            :: importFixIfMissing context compModule compModuleParts
                                in
                                Rule.errorWithFix
                                    { message =
                                        "`"
                                            ++ name
                                            ++ "` can be replaced with the component setter `"
                                            ++ replacement
                                            ++ "`"
                                    , details =
                                        [ "The barrel-level setter accepts every component's tokens; the component setter only accepts "
                                            ++ fact.component
                                            ++ "'s."
                                        ]
                                    }
                                    (Node.range setterNode)
                                    fixes
                            )

                _ ->
                    Nothing

        _ ->
            Nothing


{-| The aria case: a barrel aria combined (`<root>.ariaLabel`) specialises to
the universal `<root>.Aria.<setter>` (`<root>.Aria.label`). Universal (not
component-scoped), so it needs no fact. Inverse of `PreferBarrel`'s aria branch.
-}
ariaErrorFor : Context -> Fact -> Node Expression -> Maybe (Error {})
ariaErrorFor context fact element =
    let
        setterNode =
            case Node.value element of
                Expression.Application (s :: _) ->
                    Just s

                Expression.FunctionOrValue _ _ ->
                    Just element

                _ ->
                    Nothing
    in
    setterNode
        |> Maybe.andThen
            (\node ->
                case ( Node.value node, Maybe.andThen (Facts.dropPrefix (Facts.barrelRootParts fact)) (Lookup.moduleNameFor context.lookup node) ) of
                    ( Expression.FunctionOrValue _ barrelName, Just [] ) ->
                        ariaSpecificName barrelName
                            |> Maybe.map
                                (\setter ->
                                    let
                                        ariaModule =
                                            Facts.barrelRoot fact ++ ".Aria"

                                        ariaModuleParts =
                                            Facts.barrelRootParts fact ++ [ "Aria" ]

                                        replacement =
                                            ariaModule ++ "." ++ setter

                                        fixes =
                                            Fix.replaceRangeBy (Node.range node) replacement
                                                :: importFixIfMissing context ariaModule ariaModuleParts
                                    in
                                    Rule.errorWithFix
                                        { message =
                                            "`"
                                                ++ barrelName
                                                ++ "` can be replaced with the universal setter `"
                                                ++ replacement
                                                ++ "`"
                                        , details =
                                            [ "`" ++ ariaModule ++ "` is the canonical home for the accessible-name setters; the barrel `" ++ barrelName ++ "` is a flat re-export of it." ]
                                        }
                                        (Node.range node)
                                        fixes
                                )

                    _ ->
                        Nothing
            )


{-| The enum-value case: a barrel value combined (`<root>.variantFilled`)
un-folds to the per-component enum setter applied to a `<root>.Value` token
(`<root>.Button.variant <root>.Token.filled`). A constant → application. The
combined is only resolvable inside a known component call (many components can
share a combined), which is why this lives in `checkCall`. Inverse of
`PreferBarrel.combinedCollapse`.
-}
combinedErrorFor : Context -> Fact -> Node Expression -> Maybe (Error {})
combinedErrorFor context fact element =
    case ( Node.value element, Maybe.andThen (Facts.dropPrefix (Facts.barrelRootParts fact)) (Lookup.moduleNameFor context.lookup element) ) of
        ( Expression.FunctionOrValue _ combined, Just [] ) ->
            combinedExpansion fact combined
                |> Maybe.map
                    (\( attr, token ) ->
                        let
                            compModule =
                                Facts.factNamespace fact ++ "." ++ Facts.capitalize fact.component

                            compModuleParts =
                                Facts.factNamespaceParts fact ++ [ Facts.capitalize fact.component ]

                            valueModule =
                                -- `Token` is re-exported flat at the BARREL ROOT
                                -- (`Lib.Token`), one level up from the intermediate
                                -- component namespace in the four-package shape.
                                Facts.barrelRoot fact ++ ".Token"

                            replacement =
                                compModule ++ "." ++ attr ++ " " ++ valueModule ++ "." ++ token

                            fixes =
                                Fix.replaceRangeBy (Node.range element) replacement
                                    :: (importFixIfMissing context compModule compModuleParts
                                            ++ importFixIfMissing context valueModule (Facts.barrelRootParts fact ++ [ "Token" ])
                                       )
                        in
                        Rule.errorWithFix
                            { message =
                                "`"
                                    ++ combined
                                    ++ "` can be replaced with the component-module `"
                                    ++ replacement
                                    ++ "`"
                            , details =
                                [ "The barrel constant folds the setter and its token into one; the component setter names the "
                                    ++ fact.component
                                    ++ " setter and the token separately, so only this component's tokens typecheck."
                                ]
                            }
                            (Node.range element)
                            fixes
                    )

        _ ->
            Nothing


{-| Barrel aria combined → `<root>.Aria` setter name. Inverse of
`PreferBarrel.ariaUniversalBarrel`.
-}
ariaSpecificName : String -> Maybe String
ariaSpecificName barrelName =
    case barrelName of
        "ariaLabel" ->
            Just "label"

        "ariaLabelledby" ->
            Just "labelledby"

        "ariaDescribedby" ->
            Just "describedby"

        "ariaHidden" ->
            Just "hidden"

        _ ->
            Nothing


{-| The `(attr, token)` a barrel value combined un-folds to, or `Nothing` if
it names none of `fact`'s enum tokens. Inverts `PreferBarrel.combinedName`
(`dropTrailingUnderscore attr ++ Facts.capitalize token`) over `fact.enums`, so
the keyword-attr underscore strip matches (`typeButton` → `type_` + `button`).
-}
combinedExpansion : Fact -> String -> Maybe ( String, String )
combinedExpansion fact combined =
    fact.enums
        |> List.concatMap (\( attr, tokens ) -> List.map (\token -> ( attr, token )) tokens)
        |> List.filter (\( attr, token ) -> dropTrailingUnderscore attr ++ Facts.capitalize token == combined)
        |> List.head


dropTrailingUnderscore : String -> String
dropTrailingUnderscore s =
    if String.endsWith "_" s then
        String.dropRight 1 s

    else
        s


checkSlots : Context -> Fact -> Node Expression -> List (Error {})
checkSlots context fact contentNode =
    let
        trace =
            Facts.tracedList context.lookup context.scope contentNode
    in
    if trace.unresolved then
        []

    else
        List.filterMap (slotErrorFor context fact) trace.known


slotErrorFor : Context -> Fact -> Node Expression -> Maybe (Error {})
slotErrorFor context fact element =
    case Node.value element of
        Expression.Application (setterNode :: setterArgs) ->
            case ( Node.value setterNode, Maybe.andThen (Facts.dropPrefix (Facts.barrelRootParts fact)) (Lookup.moduleNameFor context.lookup setterNode) ) of
                ( Expression.FunctionOrValue _ "slot", Just [ "Content" ] ) ->
                    case setterArgs of
                        firstArg :: bodyNode :: _ ->
                            case Node.value firstArg of
                                Expression.Literal slotName ->
                                    Mapping.slotToPerComponent fact slotName
                                        |> Maybe.map
                                            (\perCompSetter ->
                                                let
                                                    compModule =
                                                        Facts.factNamespace fact ++ "." ++ Facts.capitalize fact.component

                                                    compModuleParts =
                                                        Facts.factNamespaceParts fact ++ [ Facts.capitalize fact.component ]

                                                    bodySource =
                                                        context.extractSourceCode (Node.range bodyNode)

                                                    replacement =
                                                        compModule ++ "." ++ perCompSetter ++ " (" ++ bodySource ++ ")"

                                                    fixes =
                                                        Fix.replaceRangeBy (Node.range element) replacement
                                                            :: importFixIfMissing context compModule compModuleParts
                                                in
                                                Rule.errorWithFix
                                                    { message =
                                                        "`.slot \""
                                                            ++ slotName
                                                            ++ "\"` can be replaced with the typed setter `"
                                                            ++ compModule
                                                            ++ "."
                                                            ++ perCompSetter
                                                            ++ "`"
                                                    , details =
                                                        [ "The typed setter enforces the slot's kinds at compile time."
                                                        ]
                                                    }
                                                    (Node.range element)
                                                    fixes
                                            )

                                _ ->
                                    Nothing

                        _ ->
                            Nothing

                _ ->
                    Nothing

        _ ->
            Nothing


{-| Upgrade case: a GENERALIZED barrel slot setter used as content of a known
enclosing constructor is promoted to the component-SPECIFIC barrel setter, using
the enclosing component's `slotUpgrades` map (generic → specific). Example:
`<root>.button [] [ <root>.slotIcon (…) ]` → `<root>.button [] [ <root>.buttonSlotIcon (…) ]`.

Unlike the attr/`.slot` cases this stays entirely within the barrel — the
specific setter is a re-export too — so there is no import to insert. A bare
`<root>.slotIcon` outside any known call site is left alone (the component, and
thus the right specific setter, is unknown).

-}
checkSlotUpgrades : Context -> Fact -> Node Expression -> List (Error {})
checkSlotUpgrades context fact contentNode =
    let
        trace =
            Facts.tracedList context.lookup context.scope contentNode
    in
    if trace.unresolved then
        []

    else
        List.filterMap (slotUpgradeErrorFor context fact) trace.known


slotUpgradeErrorFor : Context -> Fact -> Node Expression -> Maybe (Error {})
slotUpgradeErrorFor context fact element =
    case Node.value element of
        Expression.Application (setterNode :: _) ->
            case ( Node.value setterNode, Maybe.andThen (Facts.dropPrefix (Facts.barrelRootParts fact)) (Lookup.moduleNameFor context.lookup setterNode) ) of
                ( Expression.FunctionOrValue _ generic, Just [] ) ->
                    fact.slotUpgrades
                        |> List.filter (\( g, _ ) -> g == generic)
                        |> List.head
                        |> Maybe.map
                            (\( _, specific ) ->
                                let
                                    root =
                                        -- Both the generic (`Lib.slotIcon`) and the
                                        -- specific (`Lib.buttonSlotIcon`) upgrade
                                        -- setters are flat re-exports at the BARREL
                                        -- ROOT, not the intermediate component ns.
                                        Facts.barrelRoot fact
                                in
                                Rule.errorWithFix
                                    { message =
                                        "`"
                                            ++ root
                                            ++ "."
                                            ++ generic
                                            ++ "` can be upgraded to the "
                                            ++ fact.component
                                            ++ " component setter `"
                                            ++ root
                                            ++ "."
                                            ++ specific
                                            ++ "`"
                                    , details =
                                        [ "Inside `"
                                            ++ root
                                            ++ "."
                                            ++ fact.component
                                            ++ "` the component setter constrains the slot body to the kinds this component actually accepts, catching mismatched content at compile time."
                                        ]
                                    }
                                    (Node.range setterNode)
                                    [ Fix.replaceRangeBy (Node.range setterNode) (root ++ "." ++ specific) ]
                            )

                _ ->
                    Nothing

        _ ->
            Nothing


importFixIfMissing : Context -> String -> List String -> List Fix.Fix
importFixIfMissing context compModule compModuleParts =
    if Set.member compModuleParts context.importedModules then
        []

    else
        [ Fix.insertAt
            { row = context.insertionRow + 1, column = 1 }
            ("import " ++ compModule ++ "\n")
        ]
