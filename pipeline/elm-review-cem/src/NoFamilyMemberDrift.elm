module NoFamilyMemberDrift exposing (rule, Family)

{-| Guard the component↔family mapping: a generated **family module**
(`<familyNamespace>.<F>`, e.g. `M3e.Component.Chip`) is a flat re-export of every
member component in family `F` — one `import <componentNamespace>.<Member>`
per member (see `elm-cem`'s `gen-family-package.js`, "FLAT SHAPE"). The set of
members is decided once, in the family CONFIG (`_families.families` in a
brand's `slots.json`, flattened to Elm data by a small generator script — the
same "JSON can't be read at review time" pattern `M3eUtilityNames` uses).

This rule catches the two ways the generated family module and the config can
drift apart:

  - a config-declared member has **no corresponding import** in the family
    module ("component missing from family" — the family module was
    regenerated from a config that no longer lists it, or was hand-edited);
  - the family module **imports a component the config doesn't declare** as a
    member of that family ("family referencing a dead/unlisted component" —
    the config dropped a member, or renamed one, and the module didn't catch
    up).

Namespace-agnostic, like `NoMissingComponentApiNames`: pass in both
namespaces and the flattened family config.

    NoFamilyMemberDrift.rule
        { componentNamespace = [ "M3e", "Element" ]
        , familyNamespace = [ "M3e", "Component" ]
        , families = M3e.Review.Families.families
        }

No autofix (v1) — same posture as `NoMissingComponentApiNames`.

@docs rule, Family

-}

import Dict exposing (Dict)
import Elm.Syntax.Import as Import
import Elm.Syntax.Module as Module
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Range exposing (Range)
import Review.Rule as Rule exposing (Error, Rule)
import Set exposing (Set)


{-| One family's config entry — its name (the leaf module segment under
`familyNamespace`, e.g. `"Chip"`) and its flattened member list (every
component the family module is expected to import, root included, e.g.
`[ "Chip", "AssistChip", "FilterChip", ... ]`).
-}
type alias Family =
    { family : String
    , members : List String
    }


type alias Config =
    { componentNamespace : List String
    , familyNamespace : List String
    , families : List Family
    }


{-| Module context: which family (if any) the current module is, its expected
member set from config, the module-name range (for "missing" errors), and
every `<componentNamespace>.<X>` import actually seen so far (leaf name ->
the import's range, for "extra" errors).
-}
type alias ModuleContext =
    { current : Maybe { family : String, expected : Set String, nameRange : Range }
    , seen : Dict String Range
    }


rule : Config -> Rule
rule config =
    Rule.newModuleRuleSchema "NoFamilyMemberDrift" initialContext
        |> Rule.withModuleDefinitionVisitor (moduleDefinitionVisitor config)
        |> Rule.withImportVisitor (importVisitor config)
        |> Rule.withFinalModuleEvaluation finalEvaluation
        |> Rule.fromModuleRuleSchema


initialContext : ModuleContext
initialContext =
    { current = Nothing, seen = Dict.empty }


moduleDefinitionVisitor : Config -> Node Module.Module -> ModuleContext -> ( List (Error {}), ModuleContext )
moduleDefinitionVisitor config node context =
    let
        moduleName : ModuleName
        moduleName =
            Module.moduleName (Node.value node)
    in
    case familyLeaf config.familyNamespace moduleName of
        Just leaf ->
            case findFamily leaf config.families of
                Just family ->
                    ( []
                    , { context
                        | current =
                            Just
                                { family = leaf
                                , expected = Set.fromList family.members
                                , nameRange = moduleNameRange (Node.value node)
                                }
                      }
                    )

                Nothing ->
                    -- A module under the family namespace with no matching
                    -- config entry is out of this rule's scope (it has
                    -- nothing to compare against); not this rule's job to
                    -- decide whether the family namespace itself is closed.
                    ( [], context )

        Nothing ->
            ( [], context )


importVisitor : Config -> Node Import.Import -> ModuleContext -> ( List (Error {}), ModuleContext )
importVisitor config node context =
    case context.current of
        Nothing ->
            ( [], context )

        Just _ ->
            let
                imported : ModuleName
                imported =
                    Node.value (Node.value node).moduleName
            in
            case componentLeaf config.componentNamespace imported of
                Just leaf ->
                    ( [], { context | seen = Dict.insert leaf (Node.range node) context.seen } )

                Nothing ->
                    ( [], context )


finalEvaluation : ModuleContext -> List (Error {})
finalEvaluation context =
    case context.current of
        Nothing ->
            []

        Just { family, expected, nameRange } ->
            let
                seenNames : Set String
                seenNames =
                    context.seen |> Dict.keys |> Set.fromList

                missing : List (Error {})
                missing =
                    Set.diff expected seenNames
                        |> Set.toList
                        |> List.map (missingError family nameRange)

                extra : List (Error {})
                extra =
                    Set.diff seenNames expected
                        |> Set.toList
                        |> List.filterMap
                            (\name ->
                                Dict.get name context.seen
                                    |> Maybe.map (extraError family name)
                            )
            in
            missing ++ extra


missingError : String -> Range -> String -> Error {}
missingError family nameRange member =
    Rule.error
        { message = "Family `" ++ family ++ "` does not import component `" ++ member ++ "`"
        , details =
            [ "The family config declares `" ++ member ++ "` a member of the `" ++ family ++ "` family, but this module has no `import ...Element." ++ member ++ "`."
            , "Either the family module is stale (regenerate it from the family config) or the config still lists a component this family no longer includes (fix the config)."
            ]
        }
        nameRange


extraError : String -> String -> Range -> Error {}
extraError family member range =
    Rule.error
        { message = "Family `" ++ family ++ "` imports component `" ++ member ++ "`, which is not a declared member"
        , details =
            [ "This module imports `" ++ member ++ "`, but the family config's `" ++ family ++ "` entry does not list it as a member."
            , "Either the import is stale (the component was dropped from this family — remove the import) or the family config is missing this member (add it)."
            ]
        }
        range


{-| The module-name token's own range, so an error is reported on the name
rather than the whole module-definition line.
-}
moduleNameRange : Module.Module -> Range
moduleNameRange m =
    case m of
        Module.NormalModule d ->
            Node.range d.moduleName

        Module.PortModule d ->
            Node.range d.moduleName

        Module.EffectModule d ->
            Node.range d.moduleName


{-| `Just leaf` when `moduleName` is `familyNamespace ++ [ leaf ]` (exactly one
segment past the namespace).
-}
familyLeaf : List String -> ModuleName -> Maybe String
familyLeaf familyNamespace moduleName =
    dropPrefix familyNamespace moduleName |> justOne


{-| `Just leaf` when `moduleName` is `componentNamespace ++ [ leaf ]`.
-}
componentLeaf : List String -> ModuleName -> Maybe String
componentLeaf componentNamespace moduleName =
    dropPrefix componentNamespace moduleName |> justOne


justOne : Maybe (List String) -> Maybe String
justOne maybeSegments =
    case maybeSegments of
        Just [ only ] ->
            Just only

        _ ->
            Nothing


dropPrefix : List String -> List String -> Maybe (List String)
dropPrefix prefix full =
    case ( prefix, full ) of
        ( [], rest ) ->
            Just rest

        ( p :: ps, f :: fs ) ->
            if p == f then
                dropPrefix ps fs

            else
                Nothing

        ( _ :: _, [] ) ->
            Nothing


findFamily : String -> List Family -> Maybe Family
findFamily leaf families =
    families |> List.filter (\f -> f.family == leaf) |> List.head
