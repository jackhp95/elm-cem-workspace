module NoMissingComponentApiNames exposing (rule)

{-| Guard the generated component-API naming convention: every component module
under a configured namespace must expose its standard constructor, `component`.

In the four-package shape, every component module emits exactly one
constructor — `component` — regardless of whether the component has required
content (two arities: bare `component attrs children` when nothing's required,
`component : record -> ...` when something is). The loose Html producer lives at
the barrel (`<root>.button`) and the pipeline lives in `<root>.Build.<Comp>`;
only the `component` name is required to be present in the component module here.

Namespace-agnostic: the component namespace is passed in, so this rule assumes no
particular design system. A brand wires it with its own namespace, e.g.

    NoMissingComponentApiNames.rule { componentNamespace = [ "Brand", "Component" ] }

The rename ships through the generator; this rule is drift prevention — it catches
a hand-edited exception or a stale-generator regression. No autofix (v1).

@docs rule

-}

import Elm.Syntax.Exposing as Exposing
import Elm.Syntax.Module as Module
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Range exposing (Range)
import Review.Rule as Rule exposing (Error, Rule)
import Set exposing (Set)


{-| The drift guard for a brand's component-module API names. `componentNamespace`
is the module-name prefix that identifies a component module — everything one
segment deeper is a component (e.g. `[ "Brand", "Component" ]` matches
`Brand.Component.Button`).
-}
rule : { componentNamespace : List String } -> Rule
rule config =
    Rule.newModuleRuleSchema "NoMissingComponentApiNames" ()
        |> Rule.withSimpleModuleDefinitionVisitor (moduleDefinitionVisitor config.componentNamespace)
        |> Rule.fromModuleRuleSchema


moduleDefinitionVisitor : List String -> Node Module.Module -> List (Error {})
moduleDefinitionVisitor componentNamespace node =
    let
        moduleName : ModuleName
        moduleName =
            Module.moduleName (Node.value node)
    in
    if not (isComponentModule componentNamespace moduleName) then
        []

    else
        let
            ctorName : String
            ctorName =
                "component"

            exposed : Set String
            exposed =
                case Module.exposingList (Node.value node) of
                    Exposing.All _ ->
                        -- `exposing (..)` exposes everything; treat as
                        -- satisfying the constructor (generated modules never
                        -- use it, but be permissive).
                        Set.singleton ctorName

                    Exposing.Explicit list ->
                        Set.fromList (List.filterMap exposedFunctionName list)

            qualified : String
            qualified =
                String.join "." moduleName
        in
        if Set.member ctorName exposed then
            []

        else
            [ Rule.error
                { message = "`" ++ qualified ++ "` does not expose its constructor `" ++ ctorName ++ "`"
                , details =
                    [ "Every component module must expose its constructor, `" ++ ctorName ++ "` — the single standard constructor every component emits (bare when nothing's required, record-arg when something is)."
                    , "This is normally emitted by the generator; a missing name means the module was hand-edited or produced by a stale generator. Regenerate the bindings."
                    ]
                }
                (moduleNameRange (Node.value node))
            ]


{-| The range of the module-name token itself, so the error is reported on the
name rather than the whole module-definition line.
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


{-| `True` if `moduleName` is a component module under `componentNamespace` (the
namespace followed by exactly one more segment).
-}
isComponentModule : List String -> ModuleName -> Bool
isComponentModule componentNamespace moduleName =
    case dropPrefix componentNamespace moduleName of
        Just [ _ ] ->
            True

        _ ->
            False


{-| Drop `prefix` from the front of `full`, returning the remaining segments — or
`Nothing` if `full` does not start with `prefix`.
-}
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


exposedFunctionName : Node Exposing.TopLevelExpose -> Maybe String
exposedFunctionName node =
    case Node.value node of
        Exposing.FunctionExpose name ->
            Just name

        _ ->
            Nothing
