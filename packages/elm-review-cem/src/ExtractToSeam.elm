module ExtractToSeam exposing (rule)

{-| **Autofix companion to `NoSeamOutsideAllowedModules`.**

Where `NoSeamOutsideAllowedModules` merely _flags_ a `Seam.*` escape used outside
the blessed adapter modules, this rule **lifts that escape into a named function
in the `Seam` module and rewrites the call site to use it** — a coordinated
cross-module autofix.

    Seam.asAttribute (class "flex-auto") -- in Feature (flagged)

becomes

    -- Feature
    Seam.flexAuto

    -- Seam  (new top-level function + added to `exposing`)
    flexAuto =
        Seam.asAttribute (class "flex-auto")

This rule is **opt-in** and is deliberately **not** part of the shipped
`ReviewConfig`: it rewrites source across two files, so a team should run it
under `elm-review --fix` on purpose, review the result, and then keep the seam
contained with `NoSeamOutsideAllowedModules`. The two rules share detection: this
rule triggers on exactly the applied `Seam.*` escapes the gate flags.

    config =
        [ ExtractToSeam.rule
            { seamModule = "Seam"
            , allowedModules = [ "Native", "Layout", "Kit" ]
            }
        ]

**Brand crossings — two tools**

  - **`recast`** (in your seam module) — the general/unrestricted brand escape: it
    crosses ANY kinds but makes no semantic claim. Use it for one-off or exploratory
    crossings that don't warrant a named coercion.
  - **Config-blessed coercions** (WS6 / CX5, e.g. `M3e.Coerce.asButton`) — named
    loud crossings declared in `_coerce` and emitted by the generator. Use these when
    a crossing has a stable identity (e.g. "a Chip admitted as a button"). They appear
    in `<Lib>.Coerce` and are greppable by name.

`ExtractToSeam` extracts `recast` escapes (and other seam calls) into the designated
seam module; it does NOT extract blessed coercions (those come from the generator).

**How it works**

  - _Detection_ mirrors the gate: an `Expression.Application` whose head resolves
    (via the module-name lookup table) to the configured seam module, used in a
    module that is not in `allowedModules` and is not the seam module itself.
  - _Naming_ is deterministic: a camelCase slug is derived from the string
    literals inside the escape (`"flex-auto"` → `flexAuto`), falling back to
    `seam<EscapeFn>`; collisions with existing/other names get a stable hash
    suffix derived from the escape's normalized text.
  - _Dedup_ is by normalized (whitespace-collapsed) source text: two identical
    escapes lift to one function and both call sites reuse it; an escape whose
    text already matches an existing top-level `Seam` function reuses that
    function and only the call site is rewritten.
  - _Captured references_ become **arguments** of the lifted function, threaded at
    the call site: a lowercase local (a parameter, `msg`) verbatim (`Seam.gridCol n`
    ↔ `gridCol n = Seam.asAttribute (class ("col-" ++ n))`); an uppercase local
    constructor via a slugified parameter (`Seam.onClick Toggle` ↔ `seamOnClick
    toggle = onClick toggle`); a reference into a module that imports the seam (a
    cycle) via a slugified parameter passed the original qualified name. A reference
    whose module the seam already imports under a different alias is rewritten to the
    seam's qualifier rather than re-imported; a captured parameter that would shadow
    an existing seam top-level is renamed.
  - _Convergence_: already-lifted `Seam` functions — recognized because the lifted
    body's head **resolves** (via the module-name lookup) to the seam module and is
    one of its exposed names — are never re-extracted, so `--fix` terminates.

**Punted (fixless) cases** — surfaced as plain errors for manual handling rather
than emitting a broken fix:

  - point-free / bare `Seam.*` references (`List.map Seam.asElement`);
  - escapes that capture a local via a `let`/`case`/lambda/record-update inside
    the escape;
  - escapes that capture a value defined at the top level of the violating
    module (cannot be lifted into `Seam` cleanly);
  - multi-line escapes that also capture free variables.

@docs rule

-}

import Dict exposing (Dict)
import Elm.Syntax.Declaration as Declaration exposing (Declaration)
import Elm.Syntax.Exposing as Exposing exposing (Exposing)
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.File exposing (File)
import Elm.Syntax.Module as Module
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Range exposing (Location, Range)
import Review.Fix as Fix exposing (Fix)
import Review.ModuleNameLookupTable as Lookup exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)
import Set exposing (Set)


{-| Build the autofix rule.

  - `seamModule` — the dotted name of the module lifted functions go into
    (e.g. `"Seam"`); the same module whose functions count as escapes.
  - `allowedModules` — dotted module-name prefixes allowed to use the seam
    (matching `NoSeamOutsideAllowedModules`); escapes are only extracted _outside_
    these.

-}
rule : { seamModule : String, allowedModules : List String } -> Rule
rule config =
    let
        seamModuleName : ModuleName
        seamModuleName =
            String.split "." config.seamModule
    in
    Rule.newProjectRuleSchema "ExtractToSeam" initialProjectContext
        |> Rule.withModuleVisitor moduleVisitor
        |> Rule.withModuleContextUsingContextCreator
            { fromProjectToModule = fromProjectToModule seamModuleName config.allowedModules
            , fromModuleToProject = fromModuleToProject
            , foldProjectContexts = foldProjectContexts
            }
        |> Rule.withFinalProjectEvaluation (finalEvaluation seamModuleName)
        |> Rule.fromProjectRuleSchema



-- CONTEXT


type alias ProjectContext =
    { seam : Maybe SeamInfo
    , escapes : List Escape
    , bareRefs : List BareRef
    , moduleImports : List ( ModuleName, List ModuleName )
    }


initialProjectContext : ProjectContext
initialProjectContext =
    { seam = Nothing, escapes = [], bareRefs = [], moduleImports = [] }


type alias ModuleContext =
    { moduleKey : Rule.ModuleKey
    , moduleName : ModuleName
    , lookup : ModuleNameLookupTable
    , extract : Range -> String
    , ast : File
    , seamModuleName : ModuleName
    , isSeamModule : Bool
    , gated : Bool
    , escapes : List Escape
    , bareRefs : List BareRef
    , coveredHeads : Set ( Int, Int )
    }


{-| Everything the final evaluation needs about the target seam module.
-}
type alias SeamInfo =
    { moduleKey : Rule.ModuleKey
    , existingNames : Set String
    , liftedNames : Set String
    , bodyKeyToName : Dict String String
    , exposedNames : Set String
    , exposingAll : Bool
    , exposingInsertAt : Maybe Location
    , declInsertAt : Maybe Location
    , existingImports : Dict String String
    , importInsertAt : Maybe Location
    }


{-| A candidate applied escape collected from a violating module.
-}
type alias Escape =
    { moduleKey : Rule.ModuleKey
    , moduleName : ModuleName
    , range : Range
    , text : String
    , fnName : String
    , qualifier : String
    , freeRefs : List LocalRef
    , qualRefs : List QualRef
    , captures : List LocalRef
    , importedRefs : List QualRef
    , baseName : String
    , support : Support
    }


{-| A module-qualified reference found inside an escape's arguments (e.g.
`Seam.title`, `Value.small`, `Doc.markdown`). Classified later into self /
thread / import buckets once the project-wide import graph is known.
-}
type alias QualRef =
    { range : Range
    , writtenQualifier : String
    , name : String
    , resolvedModule : Maybe ModuleName
    }


{-| An unqualified identifier inside an escape that resolves locally (to nothing,
or to the current module): a captured local. Lowercase locals are threaded
verbatim as parameters; uppercase constructors are threaded via a slugified
parameter (a constructor name cannot itself be a parameter name).
-}
type alias LocalRef =
    { range : Range
    , name : String
    }


type Support
    = Fixable
    | Punt String


{-| A point-free / bare `Seam.*` reference we cannot cleanly extract.
-}
type alias BareRef =
    { moduleKey : Rule.ModuleKey
    , moduleName : ModuleName
    , range : Range
    , fnName : String
    }


fromProjectToModule : ModuleName -> List String -> Rule.ContextCreator ProjectContext ModuleContext
fromProjectToModule seamModuleName allowed =
    Rule.initContextCreator
        (\moduleKey moduleName lookup extract ast _ ->
            let
                isSeam =
                    moduleName == seamModuleName
            in
            { moduleKey = moduleKey
            , moduleName = moduleName
            , lookup = lookup
            , extract = extract
            , ast = ast
            , seamModuleName = seamModuleName
            , isSeamModule = isSeam
            , gated = not isSeam && not (isAllowed allowed (String.join "." moduleName))
            , escapes = []
            , bareRefs = []
            , coveredHeads = Set.empty
            }
        )
        |> Rule.withModuleKey
        |> Rule.withModuleName
        |> Rule.withModuleNameLookupTable
        |> Rule.withSourceCodeExtractor
        |> Rule.withFullAst


fromModuleToProject : Rule.ContextCreator ModuleContext ProjectContext
fromModuleToProject =
    Rule.initContextCreator
        (\ctx ->
            { seam =
                if ctx.isSeamModule then
                    Just (seamInfoFromModule ctx)

                else
                    Nothing
            , escapes = ctx.escapes
            , bareRefs = ctx.bareRefs
            , moduleImports = [ ( ctx.moduleName, importedModuleNames ctx.ast ) ]
            }
        )


{-| The resolved module names this module imports (ignoring aliases), used to
build the import graph for cycle detection.
-}
importedModuleNames : File -> List ModuleName
importedModuleNames ast =
    List.map (Node.value << .moduleName << Node.value) ast.imports


{-| Each imported module paired with the qualifier this module refers to it by:
its alias if it has one, else its full dotted name. Lets a carried reference be
rewritten to whatever the seam already calls that module.
-}
importQualifiers : File -> List ( String, String )
importQualifiers ast =
    List.map
        (\imp ->
            let
                import_ =
                    Node.value imp

                moduleStr =
                    String.join "." (Node.value import_.moduleName)
            in
            ( moduleStr
            , case import_.moduleAlias of
                Just alias_ ->
                    String.join "." (Node.value alias_)

                Nothing ->
                    moduleStr
            )
        )
        ast.imports


foldProjectContexts : ProjectContext -> ProjectContext -> ProjectContext
foldProjectContexts new previous =
    { seam =
        case new.seam of
            Just _ ->
                new.seam

            Nothing ->
                previous.seam
    , escapes = new.escapes ++ previous.escapes
    , bareRefs = new.bareRefs ++ previous.bareRefs
    , moduleImports = new.moduleImports ++ previous.moduleImports
    }


{-| Allow-list check, identical to `NoSeamOutsideAllowedModules`: dot-boundary
prefix match.
-}
isAllowed : List String -> String -> Bool
isAllowed allowed currentModule =
    List.any
        (\prefix -> currentModule == prefix || String.startsWith (prefix ++ ".") currentModule)
        allowed



-- MODULE VISITOR (collect escapes in violating modules)


moduleVisitor : Rule.ModuleRuleSchema {} ModuleContext -> Rule.ModuleRuleSchema { hasAtLeastOneVisitor : () } ModuleContext
moduleVisitor schema =
    schema
        |> Rule.withExpressionEnterVisitor expressionVisitor


expressionVisitor : Node Expression -> ModuleContext -> ( List (Error {}), ModuleContext )
expressionVisitor node ctx =
    if not ctx.gated then
        ( [], ctx )

    else
        case Node.value node of
            Expression.Application (head :: args) ->
                case seamRef ctx head of
                    Just fnName ->
                        if Set.member (locKey (.start (Node.range head))) ctx.coveredHeads then
                            -- A nested `Seam.*` application inside an outer escape we
                            -- already collected: it is de-qualified in the lifted body,
                            -- not lifted on its own.
                            ( [], ctx )

                        else
                            let
                                escape =
                                    buildEscape ctx node head fnName args
                            in
                            ( []
                            , { ctx
                                | escapes = escape :: ctx.escapes
                                , coveredHeads = coverEscapeHeads ctx escape head
                              }
                            )

                    Nothing ->
                        ( [], ctx )

            Expression.FunctionOrValue _ fnName ->
                case seamRef ctx node of
                    Just _ ->
                        if Set.member (locKey (.start (Node.range node))) ctx.coveredHeads then
                            ( [], ctx )

                        else
                            ( []
                            , { ctx
                                | bareRefs =
                                    { moduleKey = ctx.moduleKey
                                    , moduleName = ctx.moduleName
                                    , range = Node.range node
                                    , fnName = fnName
                                    }
                                        :: ctx.bareRefs
                              }
                            )

                    Nothing ->
                        ( [], ctx )

            _ ->
                ( [], ctx )


{-| Locations to mark "covered" for an escape: the escape head, plus every nested
`Seam.*` reference inside its arguments. Covering the nested seam refs stops them
being reported independently (as their own escape or as a point-free bareRef);
they are de-qualified in the lifted body instead.
-}
coverEscapeHeads : ModuleContext -> Escape -> Node Expression -> Set ( Int, Int )
coverEscapeHeads ctx escape head =
    let
        nestedSeamLocs =
            escape.qualRefs
                |> List.filter (\r -> r.resolvedModule == Just ctx.seamModuleName)
                |> List.map (\r -> locKey (.start r.range))
    in
    List.foldl Set.insert
        (Set.insert (locKey (.start (Node.range head))) ctx.coveredHeads)
        nestedSeamLocs


{-| If `node` is a `FunctionOrValue` resolving (via the lookup table) to the seam
module, return the function name.
-}
seamRef : ModuleContext -> Node Expression -> Maybe String
seamRef ctx node =
    case Node.value node of
        Expression.FunctionOrValue _ name ->
            if Lookup.moduleNameFor ctx.lookup node == Just ctx.seamModuleName then
                Just name

            else
                Nothing

        _ ->
            Nothing


buildEscape : ModuleContext -> Node Expression -> Node Expression -> String -> List (Node Expression) -> Escape
buildEscape ctx node head fnName args =
    let
        text =
            ctx.extract (Node.range node)

        -- Analyze the head too, not just the args: a `Seam.*` head is a
        -- self-reference that must be de-qualified when the body lands in the
        -- seam module (`Seam.title …` → `title …`). It resolves to the seam
        -- module, so it classifies as `Self` like any other self-reference.
        analysis =
            mergeMany (List.map (analyzeExpr ctx.lookup) (head :: args))

        freeVars =
            distinctFreeVars analysis.free

        multiLine =
            (.start (Node.range node)).row /= (.end (Node.range node)).row

        support =
            if analysis.hasBinder then
                Punt "captures a value bound by a let/case/lambda/record-update inside the escape"

            else if multiLine && not (List.isEmpty freeVars) then
                Punt "multi-line escape that also captures free variables"

            else
                Fixable
    in
    { moduleKey = ctx.moduleKey
    , moduleName = ctx.moduleName
    , range = Node.range node
    , text = text
    , fnName = fnName
    , qualifier = qualifierOf head
    , freeRefs = analysis.free
    , qualRefs = analysis.qualRefs
    , captures = analysis.captures
    , importedRefs = analysis.importedRefs
    , baseName = deriveBaseName analysis.literals fnName
    , support = support
    }


qualifierOf : Node Expression -> String
qualifierOf head =
    case Node.value head of
        Expression.FunctionOrValue parts _ ->
            String.join "." parts

        _ ->
            ""



-- FREE-VARIABLE / LITERAL ANALYSIS


type alias Analysis =
    { free : List LocalRef
    , captures : List LocalRef
    , importedRefs : List QualRef
    , literals : List String
    , hasBinder : Bool
    , qualRefs : List QualRef
    }


emptyAnalysis : Analysis
emptyAnalysis =
    { free = [], captures = [], importedRefs = [], literals = [], hasBinder = False, qualRefs = [] }


mergeAnalysis : Analysis -> Analysis -> Analysis
mergeAnalysis a b =
    { free = a.free ++ b.free
    , captures = a.captures ++ b.captures
    , importedRefs = a.importedRefs ++ b.importedRefs
    , literals = a.literals ++ b.literals
    , hasBinder = a.hasBinder || b.hasBinder
    , qualRefs = a.qualRefs ++ b.qualRefs
    }


mergeMany : List Analysis -> Analysis
mergeMany =
    List.foldr mergeAnalysis emptyAnalysis


analyzeExpr : ModuleNameLookupTable -> Node Expression -> Analysis
analyzeExpr lookup node =
    case Node.value node of
        Expression.FunctionOrValue parts name ->
            if List.isEmpty parts then
                case Lookup.moduleNameFor lookup node of
                    Just ((_ :: _) as m) ->
                        -- Imported unqualified value/constructor: usually available where the
                        -- escape lands, but if its bare name also names a seam top-level it
                        -- would rebind to the seam's own definition once lifted. Record it so
                        -- the body can be re-qualified in that case (see `prepareEscape`).
                        { emptyAnalysis
                            | importedRefs =
                                [ { range = Node.range node
                                  , writtenQualifier = ""
                                  , name = name
                                  , resolvedModule = Just m
                                  }
                                ]
                        }

                    _ ->
                        -- Resolves to nothing or to this module (elm-review reports locals and
                        -- current-module definitions as `Nothing`/`Just []`): not in scope in the
                        -- seam module, so it must be captured. A lowercase value threads verbatim
                        -- as a free variable; an uppercase constructor threads via a slugified
                        -- parameter (a constructor name cannot itself be a parameter name).
                        let
                            ref =
                                { range = Node.range node, name = name }
                        in
                        if isLowerIdent name then
                            { emptyAnalysis | free = [ ref ] }

                        else
                            { emptyAnalysis | captures = [ ref ] }

            else
                -- Module-qualified reference (`Seam.title`, `Value.small`, `Doc.markdown`).
                -- Record it with its resolved module so it can be classified (self /
                -- thread / import) once the project-wide import graph is known.
                { emptyAnalysis
                    | qualRefs =
                        [ { range = Node.range node
                          , writtenQualifier = String.join "." parts
                          , name = name
                          , resolvedModule = Lookup.moduleNameFor lookup node
                          }
                        ]
                }

        Expression.Application xs ->
            mergeMany (List.map (analyzeExpr lookup) xs)

        Expression.OperatorApplication _ _ l r ->
            mergeAnalysis (analyzeExpr lookup l) (analyzeExpr lookup r)

        Expression.ParenthesizedExpression x ->
            analyzeExpr lookup x

        Expression.Negation x ->
            analyzeExpr lookup x

        Expression.TupledExpression xs ->
            mergeMany (List.map (analyzeExpr lookup) xs)

        Expression.ListExpr xs ->
            mergeMany (List.map (analyzeExpr lookup) xs)

        Expression.IfBlock a b c ->
            mergeMany [ analyzeExpr lookup a, analyzeExpr lookup b, analyzeExpr lookup c ]

        Expression.RecordAccess x _ ->
            analyzeExpr lookup x

        Expression.Literal s ->
            { emptyAnalysis | literals = [ s ] }

        Expression.LambdaExpression _ ->
            { emptyAnalysis | hasBinder = True }

        Expression.LetExpression _ ->
            { emptyAnalysis | hasBinder = True }

        Expression.CaseExpression _ ->
            { emptyAnalysis | hasBinder = True }

        Expression.RecordExpr _ ->
            { emptyAnalysis | hasBinder = True }

        Expression.RecordUpdateExpression _ _ ->
            { emptyAnalysis | hasBinder = True }

        _ ->
            emptyAnalysis


isLowerIdent : String -> Bool
isLowerIdent name =
    case String.uncons name of
        Just ( c, _ ) ->
            Char.isLower c

        Nothing ->
            False



-- SEAM MODULE ANALYSIS


seamInfoFromModule : ModuleContext -> SeamInfo
seamInfoFromModule ctx =
    let
        decls =
            ctx.ast.declarations

        functions =
            List.filterMap asFunction decls

        exposing_ =
            Module.exposingList (Node.value ctx.ast.moduleDefinition)

        exposedNames_ =
            exposedNamesOf exposing_
    in
    { moduleKey = ctx.moduleKey
    , existingNames = Set.fromList (List.filterMap declName decls)
    , liftedNames =
        functions
            |> List.filter (\f -> isLiftedHelperBody ctx.lookup ctx.seamModuleName exposedNames_ f.body)
            |> List.map .name
            |> Set.fromList
    , bodyKeyToName =
        List.foldr
            (\f acc -> Dict.insert (normalizeWs (ctx.extract (Node.range f.body))) f.name acc)
            Dict.empty
            functions
    , exposedNames = exposedNames_
    , exposingAll = isExposingAll exposing_
    , exposingInsertAt = exposingInsertLocation exposing_
    , declInsertAt = lastDeclarationEnd decls
    , existingImports =
        Dict.fromList (importQualifiers ctx.ast)
    , importInsertAt = lastImportEnd ctx.ast.imports
    }


type alias SeamFunction =
    { name : String
    , body : Node Expression
    }


asFunction : Node Declaration -> Maybe SeamFunction
asFunction node =
    case Node.value node of
        Declaration.FunctionDeclaration f ->
            let
                impl =
                    Node.value f.declaration
            in
            Just { name = Node.value impl.name, body = impl.expression }

        _ ->
            Nothing


declName : Node Declaration -> Maybe String
declName node =
    case Node.value node of
        Declaration.FunctionDeclaration f ->
            Just (Node.value (Node.value f.declaration).name)

        Declaration.AliasDeclaration a ->
            Just (Node.value a.name)

        Declaration.CustomTypeDeclaration t ->
            Just (Node.value t.name)

        Declaration.PortDeclaration p ->
            Just (Node.value p.name)

        _ ->
            Nothing


{-| Recognize an already-lifted helper so its call sites are not re-extracted.
Its body (unwrapping parens) is an application whose head **resolves to** the
seam module and is one of the module's **exposed** functions.

Resolving the head (via the lookup table) rather than matching a written `Seam.`
prefix means the marker still holds after the head is de-qualified — a lifted
body reads `title Value.small […]`, not `Seam.title …`. Requiring the head to be
exported is what separates a lifted helper (which always composes the public
vocab: `title`, `asAttribute`, `div`, …) from a hand-written base-vocab function
whose head is an internal helper (`el`, `typescale`) or an external producer
(`TypedHtml.text`) — those must stay extractable.

-}
isLiftedHelperBody : ModuleNameLookupTable -> ModuleName -> Set String -> Node Expression -> Bool
isLiftedHelperBody lookup seamModuleName exposedNames body =
    case Node.value body of
        Expression.ParenthesizedExpression x ->
            isLiftedHelperBody lookup seamModuleName exposedNames x

        Expression.Application (head :: _) ->
            headResolvesToSeamExport lookup seamModuleName exposedNames head

        Expression.FunctionOrValue _ _ ->
            headResolvesToSeamExport lookup seamModuleName exposedNames body

        _ ->
            False


headResolvesToSeamExport : ModuleNameLookupTable -> ModuleName -> Set String -> Node Expression -> Bool
headResolvesToSeamExport lookup seamModuleName exposedNames head =
    case Node.value head of
        Expression.FunctionOrValue _ name ->
            let
                resolvesToSeam =
                    case Lookup.moduleNameFor lookup head of
                        Just [] ->
                            -- Unqualified ref that resolves to this (the seam) module.
                            True

                        Just m ->
                            m == seamModuleName

                        Nothing ->
                            False
            in
            resolvesToSeam && Set.member name exposedNames

        _ ->
            False


exposedNamesOf : Exposing -> Set String
exposedNamesOf exposing_ =
    case exposing_ of
        Exposing.All _ ->
            Set.empty

        Exposing.Explicit list ->
            list
                |> List.filterMap (topLevelExposeName << Node.value)
                |> Set.fromList


topLevelExposeName : Exposing.TopLevelExpose -> Maybe String
topLevelExposeName expose =
    case expose of
        Exposing.FunctionExpose name ->
            Just name

        Exposing.InfixExpose name ->
            Just name

        Exposing.TypeOrAliasExpose name ->
            Just name

        Exposing.TypeExpose t ->
            Just t.name


isExposingAll : Exposing -> Bool
isExposingAll exposing_ =
    case exposing_ of
        Exposing.All _ ->
            True

        Exposing.Explicit _ ->
            False


{-| Location just after the last item in an explicit exposing list — where a
`", newName"` insert goes.
-}
exposingInsertLocation : Exposing -> Maybe Location
exposingInsertLocation exposing_ =
    case exposing_ of
        Exposing.Explicit list ->
            list
                |> List.map (.end << Node.range)
                |> List.foldl maxLocation Nothing

        Exposing.All _ ->
            Nothing


lastDeclarationEnd : List (Node Declaration) -> Maybe Location
lastDeclarationEnd decls =
    decls
        |> List.map (.end << Node.range)
        |> List.foldl maxLocation Nothing


{-| Location just after the last `import` line — where new `import` lines for
carried external references are inserted.
-}
lastImportEnd : List (Node a) -> Maybe Location
lastImportEnd imports =
    imports
        |> List.map (.end << Node.range)
        |> List.foldl maxLocation Nothing


maxLocation : Location -> Maybe Location -> Maybe Location
maxLocation loc acc =
    case acc of
        Nothing ->
            Just loc

        Just current ->
            if ( loc.row, loc.column ) > ( current.row, current.column ) then
                Just loc

            else
                Just current



-- FINAL EVALUATION


finalEvaluation : ModuleName -> ProjectContext -> List (Error { useErrorForModule : () })
finalEvaluation seamModuleName project =
    case project.seam of
        Nothing ->
            []

        Just seam ->
            let
                -- Modules that transitively import the seam module: a reference into
                -- one of these must be threaded (not carried as an import) to avoid a
                -- cycle.
                cyclicSet =
                    modulesDependingOnSeam seamModuleName project.moduleImports

                -- Escapes that are genuinely extractable (not already lifted).
                live =
                    project.escapes
                        |> List.filter (\e -> not (Set.member e.fnName seam.liftedNames))

                fixable =
                    List.filter (\e -> e.support == Fixable) live

                punted =
                    List.filter (\e -> e.support /= Fixable) live

                bareLive =
                    project.bareRefs
                        |> List.filter (\r -> not (Set.member r.fnName seam.liftedNames))

                groups =
                    fixable
                        |> List.map (prepareEscape seamModuleName cyclicSet seam)
                        |> groupByKey

                ( groupErrors, _ ) =
                    List.foldl
                        (assignAndEmit seamModuleName seam)
                        ( [], seam.existingNames )
                        groups
            in
            groupErrors
                ++ List.map puntError punted
                ++ List.map bareRefError bareLive


{-| Group prepared escapes by their rewritten-body key, preserving a stable
order (sorted by key) so name assignment is deterministic.
-}
groupByKey : List Prepared -> List ( String, List Prepared )
groupByKey prepared =
    prepared
        |> List.foldr (\p acc -> Dict.update p.key (\m -> Just (p :: Maybe.withDefault [] m)) acc) Dict.empty
        |> Dict.toList


{-| The set of modules that (transitively) import the seam module. A qualified
reference into one of these cannot be carried as a seam import (it would form an
import cycle), so it is threaded as a parameter instead.
-}
modulesDependingOnSeam : ModuleName -> List ( ModuleName, List ModuleName ) -> Set String
modulesDependingOnSeam seamModuleName moduleImports =
    let
        seamStr =
            String.join "." seamModuleName

        edges =
            List.map (\( m, imps ) -> ( String.join "." m, List.map (String.join ".") imps )) moduleImports

        step current =
            List.foldl
                (\( m, imps ) acc ->
                    if Set.member m acc then
                        acc

                    else if List.any (\i -> i == seamStr || Set.member i acc) imps then
                        Set.insert m acc

                    else
                        acc
                )
                current
                edges

        closure current =
            let
                next =
                    step current
            in
            if Set.size next == Set.size current then
                current

            else
                closure next
    in
    closure Set.empty


{-| A qualified reference's classification once the import graph is known.
-}
type Bucket
    = Self
    | Thread String
    | Requalify String
    | CarryImport ModuleName String
    | Keep


classifyRef : ModuleName -> Set String -> Dict String String -> QualRef -> Bucket
classifyRef seamModuleName cyclicSet seamImports ref =
    case ref.resolvedModule of
        Just m ->
            if m == seamModuleName then
                Self

            else if Set.member (String.join "." m) cyclicSet then
                Thread (slugify (ref.writtenQualifier ++ " " ++ ref.name))

            else
                case Dict.get (String.join "." m) seamImports of
                    Just seamQualifier ->
                        if seamQualifier == ref.writtenQualifier then
                            -- Already imported under the same qualifier: leave the
                            -- reference as written (its import is filtered out below).
                            CarryImport m ref.writtenQualifier

                        else
                            -- Already imported under a different qualifier (or unaliased):
                            -- rewrite the reference to the seam's qualifier; add no import.
                            Requalify seamQualifier

                    Nothing ->
                        CarryImport m ref.writtenQualifier

        Nothing ->
            Keep


{-| An escape whose qualified references have been classified and whose lifted
body has been rewritten accordingly: self references de-qualified, cyclic
references replaced by threaded parameters, importable references kept qualified
(with the module recorded so the seam gains the import). The dedup key is the
normalized rewritten body, so identical results merge and `--fix` converges.
-}
type alias Prepared =
    { escape : Escape
    , body : String
    , params : List String
    , callArgs : List String
    , imports : List ( ModuleName, String )
    , key : String
    }


prepareEscape : ModuleName -> Set String -> SeamInfo -> Escape -> Prepared
prepareEscape seamModuleName cyclicSet seam escape =
    let
        classified =
            List.map (\ref -> ( ref, classifyRef seamModuleName cyclicSet seam.existingImports ref )) escape.qualRefs

        -- Body edits that introduce no parameter: self-references de-qualified.
        fixedEdits =
            List.filterMap bodyEdit classified

        -- The lifted function's parameters, in a stable order: captured free
        -- variables, then captured constructors, then threaded cyclic refs.
        -- Repeated same-argument occurrences merge; a parameter whose name would
        -- shadow an existing seam top-level (or an earlier parameter) is renamed.
        -- Each carries the body ranges to rewrite to its final name.
        assignedParams =
            mergeParams
                (freeRawParams escape.freeRefs
                    ++ captureRawParams escape.captures
                    ++ threadRawParams classified
                )
                |> assignParamNames seam.existingNames

        paramEdits =
            List.concatMap
                (\p -> List.map (\r -> { start = r.start, end = r.end, replacement = p.final }) p.ranges)
                assignedParams

        importedEdits =
            List.filterMap
                (importedRequalify seamModuleName seam.existingNames seam.existingImports)
                escape.importedRefs

        body =
            applyBodyEdits (.start escape.range) escape.text (fixedEdits ++ paramEdits ++ importedEdits)

        imports =
            classified
                |> List.filterMap
                    (\( _, bucket ) ->
                        case bucket of
                            CarryImport m alias_ ->
                                Just ( m, alias_ )

                            _ ->
                                Nothing
                    )
                |> dedupByFirst (String.join "." << Tuple.first)
    in
    { escape = escape
    , body = body
    , params = List.map .final assignedParams
    , callArgs = List.map .callArg assignedParams
    , imports = imports
    , key = normalizeWs body
    }


{-| A lifted-function parameter before its final name is chosen: a desired name,
the argument to pass at the call site, and the body ranges to rewrite.
-}
type alias RawParam =
    { desired : String
    , callArg : String
    , ranges : List Range
    }


type alias FinalParam =
    { final : String
    , callArg : String
    , ranges : List Range
    }


{-| Captured lowercase locals become parameters named verbatim (the call site
passes the same name from its own scope).
-}
freeRawParams : List LocalRef -> List RawParam
freeRawParams refs =
    List.map (\r -> { desired = r.name, callArg = r.name, ranges = [ r.range ] }) refs


{-| Captured uppercase constructors become parameters named by a lowercase slug
of the constructor; the call site passes the constructor itself.
-}
captureRawParams : List LocalRef -> List RawParam
captureRawParams caps =
    List.map (\c -> { desired = slugify c.name, callArg = c.name, ranges = [ c.range ] }) caps


{-| Threaded cyclic references become parameters named by a slug; the call site
passes the original qualified reference.
-}
threadRawParams : List ( QualRef, Bucket ) -> List RawParam
threadRawParams classified =
    List.filterMap
        (\( ref, bucket ) ->
            case bucket of
                Thread param ->
                    Just
                        { desired = param
                        , callArg = ref.writtenQualifier ++ "." ++ ref.name
                        , ranges = [ ref.range ]
                        }

                _ ->
                    Nothing
        )
        classified


{-| Merge parameter occurrences sharing both a desired name and a call-site
argument (the same value used more than once), concatenating their body ranges.
Occurrences sharing only the name are a genuine clash, left distinct for renaming.
-}
mergeParams : List RawParam -> List RawParam
mergeParams raws =
    List.foldl
        (\p acc ->
            if List.any (\q -> q.desired == p.desired && q.callArg == p.callArg) acc then
                List.map
                    (\q ->
                        if q.desired == p.desired && q.callArg == p.callArg then
                            { q | ranges = q.ranges ++ p.ranges }

                        else
                            q
                    )
                    acc

            else
                acc ++ [ p ]
        )
        []
        raws


{-| Give each parameter a final name colliding with neither an existing seam
top-level name nor an earlier parameter, appending `_` until free. Deterministic,
so identical escapes still rewrite to identical bodies (and so dedup together).
-}
assignParamNames : Set String -> List RawParam -> List FinalParam
assignParamNames existingNames raws =
    List.foldl
        (\p ( taken, acc ) ->
            let
                final =
                    avoidCollision p.desired taken
            in
            ( Set.insert final taken
            , acc ++ [ { final = final, callArg = p.callArg, ranges = p.ranges } ]
            )
        )
        ( existingNames, [] )
        raws
        |> Tuple.second


avoidCollision : String -> Set String -> String
avoidCollision name taken =
    if Set.member name taken then
        avoidCollision (name ++ "_") taken

    else
        name


type alias BodyEdit =
    { start : Location, end : Location, replacement : String }


bodyEdit : ( QualRef, Bucket ) -> Maybe BodyEdit
bodyEdit ( ref, bucket ) =
    case bucket of
        Self ->
            Just { start = ref.range.start, end = ref.range.end, replacement = ref.name }

        Requalify newQualifier ->
            Just { start = ref.range.start, end = ref.range.end, replacement = newQualifier ++ "." ++ ref.name }

        Thread _ ->
            -- Threaded cyclic refs are rewritten via `threadRawParams`/`paramEdits`,
            -- so the parameter name can be de-collided first. No fixed edit here.
            Nothing

        CarryImport _ _ ->
            Nothing

        Keep ->
            Nothing


{-| An unqualified imported value normally lands fine in the seam module. But if
its bare name also names a seam top-level, the lifted body would rebind it to the
seam's own definition. When that happens and the seam imports the value's real
module, re-qualify the reference to the seam's qualifier for that module.
-}
importedRequalify : ModuleName -> Set String -> Dict String String -> QualRef -> Maybe BodyEdit
importedRequalify seamModuleName existingNames seamImports ref =
    case ref.resolvedModule of
        Just m ->
            if m /= seamModuleName && Set.member ref.name existingNames then
                case Dict.get (String.join "." m) seamImports of
                    Just qualifier ->
                        Just { start = ref.range.start, end = ref.range.end, replacement = qualifier ++ "." ++ ref.name }

                    Nothing ->
                        Nothing

            else
                Nothing

        Nothing ->
            Nothing


{-| Apply range-based edits to the escape text. Offsets are computed relative to
the escape's start and spliced right-to-left so earlier edits never shift the
offsets of later ones. Tailwind string literals inside the escape are never
touched because only qualifier/reference ranges are edited.
-}
applyBodyEdits : Location -> String -> List BodyEdit -> String
applyBodyEdits textStart text edits =
    edits
        |> List.map
            (\e ->
                { startOffset = locOffset textStart text e.start
                , endOffset = locOffset textStart text e.end
                , replacement = e.replacement
                }
            )
        |> List.sortBy (\e -> negate e.startOffset)
        |> List.foldl
            (\e acc -> String.left e.startOffset acc ++ e.replacement ++ String.dropLeft e.endOffset acc)
            text


{-| Character offset of a source `Location` into `text`, where `text` begins at
`textStart`. Assumes `\n` line separators (Elm source files).
-}
locOffset : Location -> String -> Location -> Int
locOffset textStart text loc =
    let
        lineIdx =
            loc.row - textStart.row

        colInLine =
            if lineIdx == 0 then
                loc.column - textStart.column

            else
                loc.column - 1

        precedingLen =
            String.lines text
                |> List.take lineIdx
                |> List.map (\l -> String.length l + 1)
                |> List.sum
    in
    precedingLen + colInLine


dedupByFirst : (a -> comparable) -> List a -> List a
dedupByFirst keyOf xs =
    List.foldl
        (\x ( seen, acc ) ->
            let
                k =
                    keyOf x
            in
            if Set.member k seen then
                ( seen, acc )

            else
                ( Set.insert k seen, acc ++ [ x ] )
        )
        ( Set.empty, [] )
        xs
        |> Tuple.second


assignAndEmit :
    ModuleName
    -> SeamInfo
    -> ( String, List Prepared )
    -> ( List (Error { useErrorForModule : () }), Set String )
    -> ( List (Error { useErrorForModule : () }), Set String )
assignAndEmit seamModuleName seam ( key, prepared ) ( errorsAcc, takenNames ) =
    case sortPrepared prepared of
        [] ->
            ( errorsAcc, takenNames )

        representative :: _ ->
            let
                escape =
                    representative.escape

                reuse =
                    Dict.get key seam.bodyKeyToName

                ( name, needsInsert, newTaken ) =
                    case reuse of
                        Just existing ->
                            ( existing, False, takenNames )

                        Nothing ->
                            let
                                chosen =
                                    uniqueName escape.baseName key takenNames
                            in
                            ( chosen, True, Set.insert chosen takenNames )

                needsExpose =
                    needsInsert || (not seam.exposingAll && not (Set.member name seam.exposedNames))

                callSiteFixes =
                    preparedByModule prepared
                        |> List.map
                            (\( moduleKey, modulePrepared ) ->
                                Rule.editModule moduleKey
                                    (List.map (callSiteFix seamModuleName name) modulePrepared)
                            )

                seamFixes =
                    if needsInsert || needsExpose then
                        [ Rule.editModule seam.moduleKey (seamFixList seam name representative needsInsert needsExpose) ]

                    else
                        []

                emitted =
                    Rule.errorForModule escape.moduleKey
                        { message = "`" ++ escape.qualifier ++ "." ++ escape.fnName ++ "` escape can be lifted into `" ++ String.join "." seamModuleName ++ "." ++ name ++ "`"
                        , details =
                            [ "This `" ++ escape.qualifier ++ ".*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `" ++ String.join "." seamModuleName ++ "` as `" ++ name ++ "` and rewrites this call site to `" ++ String.join "." seamModuleName ++ "." ++ name ++ "`."
                            , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `" ++ String.join "." seamModuleName ++ "` function is never re-extracted."
                            ]
                        }
                        escape.range
                        |> Rule.withFixesV2 (callSiteFixes ++ seamFixes)
            in
            ( emitted :: errorsAcc, newTaken )


sortPrepared : List Prepared -> List Prepared
sortPrepared =
    List.sortBy (\p -> ( String.join "." p.escape.moduleName, (.start p.escape.range).row, (.start p.escape.range).column ))


{-| Partition prepared escapes by module key (keyed via module name for
comparability).
-}
preparedByModule : List Prepared -> List ( Rule.ModuleKey, List Prepared )
preparedByModule prepared =
    prepared
        |> List.foldr
            (\p acc -> Dict.update (String.join "." p.escape.moduleName) (\m -> Just ( p.escape.moduleKey, p :: Maybe.withDefault [] (Maybe.map Tuple.second m) )) acc)
            Dict.empty
        |> Dict.values


callSiteFix : ModuleName -> String -> Prepared -> Fix
callSiteFix seamModuleName name prepared =
    let
        escape =
            prepared.escape

        qualifier =
            if String.isEmpty escape.qualifier then
                String.join "." seamModuleName

            else
                escape.qualifier

        args =
            String.concat (List.map (\v -> " " ++ v) prepared.callArgs)
    in
    Fix.replaceRangeBy escape.range (qualifier ++ "." ++ name ++ args)


seamFixList : SeamInfo -> String -> Prepared -> Bool -> Bool -> List Fix
seamFixList seam name representative needsInsert needsExpose =
    let
        insertFix =
            if needsInsert then
                case seam.declInsertAt of
                    Just loc ->
                        [ Fix.insertAt loc (liftedDefinition name representative) ]

                    Nothing ->
                        []

            else
                []

        exposeFix =
            if needsExpose && not seam.exposingAll then
                case seam.exposingInsertAt of
                    Just loc ->
                        [ Fix.insertAt loc (", " ++ name) ]

                    Nothing ->
                        []

            else
                []

        importFix =
            if needsInsert then
                let
                    missing =
                        representative.imports
                            |> List.filter (\( m, _ ) -> not (Dict.member (String.join "." m) seam.existingImports))
                in
                case ( seam.importInsertAt, missing ) of
                    ( Just loc, _ :: _ ) ->
                        [ Fix.insertAt loc (String.concat (List.map importLine missing)) ]

                    _ ->
                        []

            else
                []
    in
    insertFix ++ exposeFix ++ importFix


{-| An `import` line for a carried external reference, preserving its alias.
-}
importLine : ( ModuleName, String ) -> String
importLine ( m, alias_ ) =
    let
        moduleStr =
            String.join "." m
    in
    if alias_ == moduleStr then
        "\nimport " ++ moduleStr

    else
        "\nimport " ++ moduleStr ++ " as " ++ alias_


liftedDefinition : String -> Prepared -> String
liftedDefinition name prepared =
    let
        params =
            String.concat (List.map (\v -> " " ++ v) prepared.params)
    in
    "\n\n\n" ++ name ++ params ++ " =\n    " ++ prepared.body


puntError : Escape -> Error { useErrorForModule : () }
puntError escape =
    let
        reason =
            case escape.support of
                Punt r ->
                    r

                Fixable ->
                    ""
    in
    Rule.errorForModule escape.moduleKey
        { message = "`" ++ escape.qualifier ++ "." ++ escape.fnName ++ "` escape cannot be auto-extracted"
        , details =
            [ "This seam escape " ++ reason ++ ", so `ExtractToSeam` will not emit a fix that could be wrong."
            , "Lift it into the seam module by hand (as a named function taking the captured values as arguments), then use it here."
            ]
        }
        escape.range


bareRefError : BareRef -> Error { useErrorForModule : () }
bareRefError ref =
    Rule.errorForModule ref.moduleKey
        { message = "`Seam." ++ ref.fnName ++ "` is used point-free and cannot be auto-extracted"
        , details =
            [ "This is a bare (point-free) reference to a seam function rather than an applied escape expression, so there is nothing self-contained to lift."
            , "Refactor it into an applied escape, or lift the surrounding expression into the seam module by hand."
            ]
        }
        ref.range



-- NAMING


{-| Derive a readable camelCase base name from the escape's string literals,
falling back to `seam<EscapeFn>`.
-}
deriveBaseName : List String -> String -> String
deriveBaseName literals fnName =
    let
        fromLiterals =
            slugify (String.join " " literals)
    in
    if String.isEmpty fromLiterals then
        "seam" ++ capitalizeFirst fnName

    else
        fromLiterals


slugify : String -> String
slugify raw =
    let
        words =
            raw
                |> String.map
                    (\c ->
                        if Char.isAlphaNum c then
                            c

                        else
                            ' '
                    )
                |> String.words
    in
    case words of
        [] ->
            ""

        first :: rest ->
            let
                joined =
                    lowerFirst first ++ String.concat (List.map capitalizeFirst rest)
            in
            case String.uncons joined of
                Just ( c, _ ) ->
                    if Char.isDigit c then
                        "s" ++ joined

                    else
                        joined

                Nothing ->
                    ""


{-| Ensure `base` is unique among `taken`; if not, append a stable hash of the
escape's normalized text (and a counter as a last resort).
-}
uniqueName : String -> String -> Set String -> String
uniqueName base key taken =
    if not (Set.member base taken) then
        base

    else
        let
            withHash =
                base ++ capitalizeFirst (hashString key)
        in
        if not (Set.member withHash taken) then
            withHash

        else
            bumpName withHash 2 taken


bumpName : String -> Int -> Set String -> String
bumpName base n taken =
    let
        candidate =
            base ++ String.fromInt n
    in
    if not (Set.member candidate taken) then
        candidate

    else if n > 500 then
        candidate

    else
        bumpName base (n + 1) taken


lowerFirst : String -> String
lowerFirst s =
    case String.uncons s of
        Just ( c, rest ) ->
            String.cons (Char.toLower c) rest

        Nothing ->
            s


capitalizeFirst : String -> String
capitalizeFirst s =
    case String.uncons s of
        Just ( c, rest ) ->
            String.cons (Char.toUpper c) rest

        Nothing ->
            s


normalizeWs : String -> String
normalizeWs =
    String.words >> String.join " "


{-| A small deterministic base36 hash of a string (stable across runs).
-}
hashString : String -> String
hashString s =
    s
        |> String.toList
        |> List.foldl (\c acc -> modBy 2147483647 (acc * 31 + Char.toCode c)) 7
        |> toBase36
        |> String.left 4


toBase36 : Int -> String
toBase36 n =
    if n <= 0 then
        "0"

    else
        toBase36Help n ""


toBase36Help : Int -> String -> String
toBase36Help n acc =
    if n <= 0 then
        acc

    else
        toBase36Help (n // 36) (String.cons (base36Digit (modBy 36 n)) acc)


base36Digit : Int -> Char
base36Digit d =
    if d < 10 then
        Char.fromCode (Char.toCode '0' + d)

    else
        Char.fromCode (Char.toCode 'a' + (d - 10))


locKey : Location -> ( Int, Int )
locKey loc =
    ( loc.row, loc.column )


distinctFreeVars : List LocalRef -> List String
distinctFreeVars =
    List.map .name >> firstOccDistinct


firstOccDistinct : List String -> List String
firstOccDistinct xs =
    List.foldl
        (\x ( seen, acc ) ->
            if Set.member x seen then
                ( seen, acc )

            else
                ( Set.insert x seen, acc ++ [ x ] )
        )
        ( Set.empty, [] )
        xs
        |> Tuple.second
