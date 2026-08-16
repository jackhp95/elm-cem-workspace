module Cem.Internal.Translate exposing (Target(..), rule)

{-| Shared machinery for the two opt-in Standard→surface translators
`Cem.TranslateToRecord` and `Cem.TranslateToBuild`, driven by `Cem.Facts`.

Both rules start from the SAME shape — a per-component Standard constructor call
`<root>.<Comp>.<slug> [attrs] [children]` (where `<slug>` is the whole-word
lowercased component segment, e.g. `M3e.Component.Button.button`) — and re-express
it on another surface of the SAME component:

  - `Record` → `<root>.<Comp>.component { <requiredFields> } [residualAttrs] [residualChildren]`
  - `Build` → `<buildRoot>.<Comp>.build <requiredRecord?> |> <buildRoot>.<Comp>.withX … |> <buildRoot>.<Comp>.toElement`
    (the Build surface lives in a SEPARATE module — `M3e.Component.<X>` → `M3e.Build.<X>`)

The required record is reconstructed from the facts: one field per `requiredSlots`
entry (`unnamed` → `content`, every other slot → its camelCase name), plus an
`action` field when `fact.usesAction`. The field VALUES are hoisted out of the
Standard call's children (the required-slot fillers) and attrs (the action
setter), leaving the rest in place.

For the Record surface (same module the input already imports) residual
per-component setters need no re-qualification. The Build surface targets a
separate `<buildRoot>.<Comp>` module, so its `withX`/`toElement` are emitted
fully qualified against that module. The only import a fix can add is the
root-level `Action` module (for a synthesised `action` field).

**Deliberately conservative.** The rule reports NOTHING (a clean no-op) unless the
whole call is statically resolvable and every part maps to a known surface form:

  - only the per-component Standard form `<root>.<Comp>.<slug>` is a source (never the
    flat barrel `<root>.<comp>` — run `PreferComponentModules` first);
  - both argument lists must be literal `[ … ]` (a dynamic `++` tail, `List.map`,
    or a bare variable list makes the call unresolvable → skip);
  - every required slot must have a locatable filler;
  - `Build` additionally requires every residual attr/child to resolve to a known
    per-component setter (an unrecognised setter — e.g. a generic `class` from
    another module — makes the withX name unknown → skip);
  - a component whose required record carries an `aria-label` (its `requiredAttrs`
    contains `"aria-label"`, e.g. `fab`/`iconButton`) is skipped entirely: the
    `aria-label` string has no setter on the Standard surface, so the required
    `ariaLabel : String` field cannot be sourced. See the module docs of the two
    public rules for the full gap list.

Each transform is a single-pass fixpoint: its output uses `component`/`build`/
`withX`/`toElement`, never the Standard slug, so re-running the rule matches nothing.

@docs Target, rule

-}

import Cem.Facts exposing (Facet(..), Fact)
import Cem.Internal.Facts as Facts
import Dict exposing (Dict)
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Import exposing (Import)
import Elm.Syntax.Module as Module
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Range exposing (Range)
import Review.Fix as Fix
import Review.ModuleNameLookupTable as Lookup exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)
import Set exposing (Set)


{-| Which alternate surface a translator targets.
-}
type Target
    = ToRecord
    | ToBuild


{-| Build the rule for a `Target` from the generated facts.
-}
rule : Target -> List Fact -> Rule
rule target facts =
    Rule.newModuleRuleSchemaUsingContextCreator (ruleName target) (initContext facts)
        |> Rule.withModuleDefinitionVisitor moduleDefinitionVisitor
        |> Rule.withImportVisitor importVisitor
        |> Rule.withExpressionEnterVisitor (expressionVisitor target)
        |> Rule.fromModuleRuleSchema


ruleName : Target -> String
ruleName target =
    case target of
        ToRecord ->
            "TranslateToRecord"

        ToBuild ->
            "TranslateToBuild"


type alias Context =
    { lookup : ModuleNameLookupTable
    , extract : Range -> String
    , byModule : Dict String Fact
    , importedModules : Set (List String)
    , insertionRow : Int
    }


initContext : List Fact -> Rule.ContextCreator () Context
initContext facts =
    Rule.initContextCreator
        (\lookup extract () ->
            { lookup = lookup
            , extract = extract
            , byModule =
                facts
                    |> List.map (\f -> ( f.module_, f ))
                    |> Dict.fromList
            , importedModules = Set.empty
            , insertionRow = 1
            }
        )
        |> Rule.withModuleNameLookupTable
        |> Rule.withSourceCodeExtractor


moduleDefinitionVisitor : Node Module.Module -> Context -> ( List (Error {}), Context )
moduleDefinitionVisitor node context =
    ( [], { context | insertionRow = (Node.range node).end.row } )


importVisitor : Node Import -> Context -> ( List (Error {}), Context )
importVisitor node context =
    ( []
    , { context
        | importedModules = Set.insert (Node.value (Node.value node).moduleName) context.importedModules
        , insertionRow = (Node.range node).end.row
      }
    )


expressionVisitor : Target -> Node Expression -> Context -> ( List (Error {}), Context )
expressionVisitor target node context =
    case Node.value node of
        Expression.Application (fnNode :: attrsNode :: childrenNode :: []) ->
            case planFor target context node fnNode attrsNode childrenNode of
                Just plan ->
                    ( [ toError target context node plan ], context )

                Nothing ->
                    ( [], context )

        _ ->
            ( [], context )



-- PLAN


{-| The fully-resolved rewrite of one Standard call: the replacement source plus
any import the fix must add. `Nothing` from `planFor` means "not soundly
transformable — leave it alone".
-}
type alias Plan =
    { replacement : String
    , actionImport : Maybe (List String)
    }


planFor : Target -> Context -> Node Expression -> Node Expression -> Node Expression -> Node Expression -> Maybe Plan
planFor target context _ fnNode attrsNode childrenNode =
    resolveViewCall context fnNode
        |> Maybe.andThen
            (\fact ->
                if target == ToRecord && not (List.member Record fact.facets) then
                    -- TranslateToRecord only applies to the components that HAVE a
                    -- required record (the `component` ctor's leading-record arity).
                    Nothing

                else if List.member "aria-label" fact.requiredAttrs then
                    -- The required `ariaLabel : String` field has no Standard-surface
                    -- source; skip (fab/iconButton). Documented gap.
                    Nothing

                else
                    Maybe.map2 Tuple.pair
                        (literalList attrsNode)
                        (literalList childrenNode)
                        |> Maybe.andThen
                            (\( attrElems, childElems ) ->
                                buildPlan target context fact attrElems childElems
                            )
            )


{-| The fact for a per-component Standard `<root>.<Comp>.<slug>` reference (where
`<slug>` is the whole-word-lowercased component module segment, e.g.
`M3e.Component.AppBar.appbar`), or `Nothing` for anything else (the flat barrel,
the record `.component` ctor, another module).
-}
resolveViewCall : Context -> Node Expression -> Maybe Fact
resolveViewCall context fnNode =
    case Node.value fnNode of
        Expression.FunctionOrValue _ name ->
            Lookup.moduleNameFor context.lookup fnNode
                |> Maybe.andThen (\parts -> Dict.get (String.join "." parts) context.byModule)
                |> Maybe.andThen
                    (\fact ->
                        if name == standardSlug fact then
                            Just fact

                        else
                            Nothing
                    )

        _ ->
            Nothing


{-| The Standard top-layer constructor name for a component: its module's last
segment, whole-word-lowercased (`AppBar` → `appbar`, `Accordion` → `accordion`).
This is the elm-cem/generator convention (whole-word lowercase), and is NOT the
same as `fact.component` (which is camelCase, e.g. `appBar`), so it must be
derived from the module segment, not the noun field.
-}
standardSlug : Fact -> String
standardSlug fact =
    String.toLower (Facts.factComponentSegment fact)


{-| The Build-surface module for a component: its Standard module with the
component-namespace segment swapped for `Build`. `M3e.Component.AppBar` →
`M3e.Build.AppBar`. For a flat `<root>.<Comp>` library (no intermediate segment)
this degrades to `<root>.Build.<Comp>` — acceptable, as every namespace carrying
the Build facet today is the nested `Component` layout.
-}
buildModule : Fact -> String
buildModule fact =
    String.join "." (buildNamespaceParts fact ++ [ Facts.factComponentSegment fact ])


{-| The Build namespace: the component's namespace with its last segment
(`Component`) replaced by `Build`. `["M3e","Component"]` → `["M3e","Build"]`.
A single-segment namespace (`["M3e"]`) gains a `Build` segment → `["M3e","Build"]`.
-}
buildNamespaceParts : Fact -> List String
buildNamespaceParts fact =
    case List.reverse (Facts.factNamespaceParts fact) of
        _ :: restReversed ->
            List.reverse ("Build" :: restReversed)

        [] ->
            [ "Build" ]


{-| The module the synthesised `action` field's constructors live in. In the
elm-m3e library `Action` stayed at the ROOT namespace (`M3e.Action`), NOT under
the intermediate `Component` segment — so it is the barrel root plus `Action`,
never `factNamespaceParts` (which would wrongly yield `M3e.Component.Action`).
For a flat single-segment library it degrades to `<root>.Action`.
-}
actionModuleParts : Fact -> List String
actionModuleParts fact =
    let
        ns =
            Facts.factNamespaceParts fact

        root =
            case ns of
                _ :: _ :: _ ->
                    -- Intermediate segment present → barrel root is all-but-last.
                    dropLastPart ns

                _ ->
                    ns
    in
    root ++ [ "Action" ]


dropLastPart : List a -> List a
dropLastPart xs =
    List.take (List.length xs - 1) xs


buildPlan : Target -> Context -> Fact -> List (Node Expression) -> List (Node Expression) -> Maybe Plan
buildPlan target context fact attrElems childElems =
    let
        compModule =
            fact.module_

        childResult =
            partitionChildren context fact childElems

        attrResult =
            partitionAttrs context fact attrElems
    in
    childResult
        |> Maybe.andThen
            (\{ requiredFields, residualChildren, residualNodes } ->
                let
                    actionField =
                        if fact.usesAction then
                            [ ( "action"
                              , attrResult.actionValue
                                    |> Maybe.withDefault (String.join "." (actionModuleParts fact) ++ ".none")
                              )
                            ]

                        else
                            []

                    fields =
                        requiredFields ++ actionField

                    actionImport =
                        if fact.usesAction then
                            Just (actionModuleParts fact)

                        else
                            Nothing
                in
                case target of
                    ToRecord ->
                        Just
                            { replacement =
                                compModule
                                    ++ ".component "
                                    ++ recordLiteral fields
                                    ++ " "
                                    ++ listLiteral attrResult.residual
                                    ++ " "
                                    ++ listLiteral residualChildren
                            , actionImport = actionImport
                            }

                    ToBuild ->
                        buildPipes context fact (buildModule fact) attrResult.residualNodes residualNodes
                            |> Maybe.map
                                (\pipes ->
                                    { replacement = buildReplacement (buildModule fact) fields pipes
                                    , actionImport = actionImport
                                    }
                                )
            )



-- CHILDREN


type alias ChildPartition =
    { requiredFields : List ( String, String )
    , residualChildren : List String
    , residualNodes : List (Node Expression)
    }


{-| Consume one child per required slot (a required slot with no locatable filler
aborts the whole plan); everything left over is residual. Preserves source order.
-}
partitionChildren : Context -> Fact -> List (Node Expression) -> Maybe ChildPartition
partitionChildren context fact childElems =
    let
        namedSetters =
            Facts.namedSlotSetters fact

        roots =
            [ Facts.factNamespaceParts fact ]

        step slot acc =
            acc
                |> Maybe.andThen
                    (\state ->
                        takeSlotFiller context fact roots namedSetters slot state.remaining
                            |> Maybe.map
                                (\( field, rest ) ->
                                    { requiredFields = state.requiredFields ++ [ field ]
                                    , remaining = rest
                                    }
                                )
                    )

        initial =
            Just { requiredFields = [], remaining = childElems }
    in
    List.foldl step initial fact.requiredSlots
        |> Maybe.map
            (\state ->
                { requiredFields = state.requiredFields
                , residualChildren = List.map (\n -> context.extract (Node.range n)) state.remaining
                , residualNodes = state.remaining
                }
            )


{-| Locate and remove the child filling `slot`, returning its record field and the
remaining children. The default (`unnamed`) slot's filler is the first child that
is not one of the component's named-slot setters (unwrapping a `child` wrapper);
a named slot's filler is the first child whose head is that slot's setter.
-}
takeSlotFiller : Context -> Fact -> List (List String) -> List String -> String -> List (Node Expression) -> Maybe ( ( String, String ), List (Node Expression) )
takeSlotFiller context fact roots namedSetters slot remaining =
    if slot == "unnamed" || slot == "default" then
        takeFirst (Facts.fillsDefaultSlot roots context.lookup namedSetters fact.component) remaining
            |> Maybe.map
                (\( elem, rest ) ->
                    ( ( "content", defaultChildValue context fact elem ), rest )
                )

    else
        let
            perComp =
                slotSetterName fact slot
        in
        takeFirst (headSetterIs context fact perComp) remaining
            |> Maybe.map
                (\( elem, rest ) ->
                    ( ( Facts.camelize slot, setterArgSource context elem ), rest )
                )


{-| The per-component setter name for a slot, from `slotRewrites`; falls back to
the camelCase slot name (the generated setter's canonical name).
-}
slotSetterName : Fact -> String -> String
slotSetterName fact slot =
    fact.slotRewrites
        |> List.filter (\( s, _ ) -> s == slot)
        |> List.head
        |> Maybe.map Tuple.second
        |> Maybe.withDefault (Facts.camelize slot)


{-| The value of a default-slot child: the argument of a `<root>.<Comp>.child`
wrapper if it is one, else the whole child expression verbatim.
-}
defaultChildValue : Context -> Fact -> Node Expression -> String
defaultChildValue context fact elem =
    if headSetterIs context fact "child" elem then
        setterArgSource context elem

    else
        context.extract (Node.range elem)



-- ATTRS


type alias AttrPartition =
    { actionValue : Maybe String
    , residual : List String
    , residualNodes : List (Node Expression)
    }


{-| Pull out the first action setter (a setter whose name is a key of
`actionMap`, e.g. `onClick`/`href`) as the `action` value, keeping every other
attr. Only relevant when `fact.usesAction`; otherwise every attr is residual.
-}
partitionAttrs : Context -> Fact -> List (Node Expression) -> AttrPartition
partitionAttrs context fact attrElems =
    let
        allResidual =
            { actionValue = Nothing
            , residual = List.map (\n -> context.extract (Node.range n)) attrElems
            , residualNodes = attrElems
            }
    in
    if fact.usesAction then
        case takeFirst (isActionSetter context fact) attrElems of
            Just ( elem, rest ) ->
                { actionValue = Just (actionExpression context fact elem)
                , residual = List.map (\n -> context.extract (Node.range n)) rest
                , residualNodes = rest
                }

            Nothing ->
                allResidual

    else
        allResidual


isActionSetter : Context -> Fact -> Node Expression -> Bool
isActionSetter context fact elem =
    case attrHeadName context fact elem of
        Just name ->
            List.any (\( attr, _ ) -> attr == name) fact.actionMap

        Nothing ->
            False


{-| `<root>.Action.<constructor> <arg>`, mapping the action setter (`onClick`,
`href`) to its constructor (`onClick`, `link`) via `actionMap`.
-}
actionExpression : Context -> Fact -> Node Expression -> String
actionExpression context fact elem =
    let
        constructor =
            attrHeadName context fact elem
                |> Maybe.andThen
                    (\name ->
                        fact.actionMap
                            |> List.filter (\( attr, _ ) -> attr == name)
                            |> List.head
                            |> Maybe.map Tuple.second
                    )
                |> Maybe.withDefault "none"
    in
    String.join "." (actionModuleParts fact) ++ "." ++ constructor ++ " " ++ setterArgSource context elem



-- BUILD PIPES


{-| Turn residual attrs and children into `withX` pipe stages, or `Nothing` if any
element does not resolve to a known per-component setter (so its `withX` name is
unknowable). Attrs first, then children, both in source order.
-}
buildPipes : Context -> Fact -> String -> List (Node Expression) -> List (Node Expression) -> Maybe (List String)
buildPipes context fact buildMod attrNodes childNodes =
    let
        roots =
            [ Facts.factNamespaceParts fact ]

        namedSetters =
            Facts.namedSlotSetters fact

        attrPipes =
            attrNodes
                |> List.map (attrPipe context fact buildMod)
                |> combineMaybes

        childPipes =
            childNodes
                |> List.map (childPipe context fact buildMod roots namedSetters)
                |> combineMaybes
    in
    Maybe.map2 (++) attrPipes childPipes


attrPipe : Context -> Fact -> String -> Node Expression -> Maybe String
attrPipe context fact buildMod elem =
    attrHeadName context fact elem
        |> Maybe.map
            (\name ->
                buildMod ++ "." ++ withSetterName fact name False ++ " " ++ setterArgSource context elem
            )


childPipe : Context -> Fact -> String -> List (List String) -> List String -> Node Expression -> Maybe String
childPipe context fact buildMod roots namedSetters elem =
    if Facts.fillsDefaultSlot roots context.lookup namedSetters fact.component elem then
        Just (buildMod ++ ".withChild " ++ parenValue (defaultChildValue context fact elem))

    else
        attrHeadName context fact elem
            |> Maybe.map
                (\name ->
                    buildMod ++ "." ++ withSetterName fact name True ++ " " ++ setterArgSource context elem
                )


{-| The `with<Setter>` pipe name for a setter. Convention: `with` + capitalised
setter name (trailing keyword underscore dropped, so `type_` → `withType`). A SLOT
setter whose name collides with an attr setter of the same base takes a `Slot`
suffix (`selected` slot → `withSelectedSlot`, disambiguating it from the
`selected` attr's `withSelected`). NOT authoritative — see the gap note in the
public rule docs.
-}
withSetterName : Fact -> String -> Bool -> String
withSetterName fact name isSlot =
    let
        base =
            "with" ++ Facts.capitalize (dropTrailingUnderscore name)

        collides =
            List.any (\( _, perComp ) -> perComp == name) fact.attrRewrites
    in
    if isSlot && collides then
        base ++ "Slot"

    else
        base


buildReplacement : String -> List ( String, String ) -> List String -> String
buildReplacement compModule fields pipes =
    let
        seed =
            if List.isEmpty fields then
                compModule ++ ".build"

            else
                compModule ++ ".build " ++ recordLiteral fields

        stages =
            pipes ++ [ compModule ++ ".toElement" ]
    in
    String.join " |> " (seed :: stages)



-- SHARED HELPERS


{-| The setter name of an attr/slot element applied as `<root>.<Comp>.<name> …`,
if its head resolves to this component's module. `Nothing` for a raw child, a
literal, or a setter from another module.
-}
attrHeadName : Context -> Fact -> Node Expression -> Maybe String
attrHeadName context fact elem =
    case Node.value elem of
        Expression.Application (setterNode :: _) ->
            headName context fact setterNode

        _ ->
            Nothing


headName : Context -> Fact -> Node Expression -> Maybe String
headName context fact setterNode =
    case Node.value setterNode of
        Expression.FunctionOrValue _ name ->
            if Lookup.moduleNameFor context.lookup setterNode == Just (String.split "." fact.module_) then
                Just name

            else
                Nothing

        _ ->
            Nothing


headSetterIs : Context -> Fact -> String -> Node Expression -> Bool
headSetterIs context fact wanted elem =
    attrHeadName context fact elem == Just wanted


{-| The source of a setter's argument(s) (`<root>.<Comp>.onClick Msg` → `"Msg"`),
spanning the first through the last argument verbatim.
-}
setterArgSource : Context -> Node Expression -> String
setterArgSource context elem =
    case Node.value elem of
        Expression.Application (_ :: firstArg :: rest) ->
            let
                lastArg =
                    List.reverse rest |> List.head |> Maybe.withDefault firstArg
            in
            context.extract
                { start = (Node.range firstArg).start
                , end = (Node.range lastArg).end
                }

        _ ->
            context.extract (Node.range elem)


{-| A list expression's elements when it is a literal `[ … ]` (unwrapping
parentheses); `Nothing` for a dynamic list (`a ++ b`, `List.map …`, a bare var).
-}
literalList : Node Expression -> Maybe (List (Node Expression))
literalList node =
    case Node.value node of
        Expression.ListExpr elems ->
            Just elems

        Expression.ParenthesizedExpression inner ->
            literalList inner

        _ ->
            Nothing


recordLiteral : List ( String, String ) -> String
recordLiteral fields =
    if List.isEmpty fields then
        "{}"

    else
        "{ "
            ++ String.join ", " (List.map (\( k, v ) -> k ++ " = " ++ v) fields)
            ++ " }"


listLiteral : List String -> String
listLiteral items =
    if List.isEmpty items then
        "[]"

    else
        "[ " ++ String.join ", " items ++ " ]"


parenValue : String -> String
parenValue s =
    if String.contains " " s && not (String.startsWith "(" s) then
        "(" ++ s ++ ")"

    else
        s


takeFirst : (a -> Bool) -> List a -> Maybe ( a, List a )
takeFirst pred xs =
    takeFirstHelp pred [] xs


takeFirstHelp : (a -> Bool) -> List a -> List a -> Maybe ( a, List a )
takeFirstHelp pred seen xs =
    case xs of
        [] ->
            Nothing

        x :: rest ->
            if pred x then
                Just ( x, List.reverse seen ++ rest )

            else
                takeFirstHelp pred (x :: seen) rest


combineMaybes : List (Maybe a) -> Maybe (List a)
combineMaybes =
    List.foldr (Maybe.map2 (::)) (Just [])


dropTrailingUnderscore : String -> String
dropTrailingUnderscore s =
    if String.endsWith "_" s then
        String.dropRight 1 s

    else
        s



-- ERROR


toError : Target -> Context -> Node Expression -> Plan -> Error {}
toError target context node plan =
    let
        surface =
            case target of
                ToRecord ->
                    "required-record (`component`)"

                ToBuild ->
                    "builder pipeline (`build … |> toElement`)"

        importFix =
            case plan.actionImport of
                Just parts ->
                    if Set.member parts context.importedModules then
                        []

                    else
                        [ Fix.insertAt
                            { row = context.insertionRow + 1, column = 1 }
                            ("import " ++ String.join "." parts ++ "\n")
                        ]

                Nothing ->
                    []
    in
    Rule.errorWithFix
        { message = "This Standard `component` call can be rewritten to the " ++ surface ++ " surface"
        , details =
            [ "The generated component module exposes the same element on another surface; this opt-in transform rewrites the call in place, hoisting the required fields out of the attrs/children per the facts."
            ]
        }
        (Node.range node)
        (Fix.replaceRangeBy (Node.range node) plan.replacement :: importFix)
