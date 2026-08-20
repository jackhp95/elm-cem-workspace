module NoMergedPipeAndSetter exposing (rule)

{-| Flags a module that exposes both a `with<X>` pipe **and** a plain `<x>` value
for the same concept in the same exposing list — which would merge the pipe
family (from a builder module like `M3e.<Component>.Build`) and the setter family
(from a component module like `M3e.<Component>`) into one flat namespace.

This protects the K5/#58 structural guarantee: pipes live in
`M3e.<Component>.Build`, setters live in `M3e.<Component>`. Any barrel or adapter
that re‑exports both into one module recreates the collision.

Generated component and builder modules (`M3e.Button`, `M3e.Button.Build`) are
excluded via `allowedModules` — they are the intended source of each family,
not a merge.

    config =
        [ NoMergedPipeAndSetter.rule
            { allowedModules = [ "M3e", "Sl", "Wa" ] }
        ]

The rule is facts‑free and namespace‑agnostic. It checks every exposed value in
every module whose name does NOT start with one of the `allowedModules` prefixes.
A hit is a pair `withDisabled` + `disabled` (or `withLabel` + `label`, etc.) in
the same exposing list.

@docs rule

-}

import Cem.Internal.Gate as Gate
import Elm.Syntax.Exposing exposing (Exposing(..), TopLevelExpose(..))
import Elm.Syntax.Module as Module
import Elm.Syntax.Node as Node
import Elm.Syntax.Range exposing (Range)
import Review.Rule as Rule exposing (Error, Rule)
import Set exposing (Set)


{-| Build the rule. Provide the list of dotted module-name prefixes whose modules
are allowed to co‑expose pipes and matching bare values (typically your generated
brand roots like `"M3e"`, `"Sl"`, `"Wa"`).
-}
rule : { allowedModules : List String } -> Rule
rule config =
    Rule.newModuleRuleSchema "NoMergedPipeAndSetter" config.allowedModules
        |> Rule.withModuleDefinitionVisitor moduleDefinitionVisitor
        |> Rule.fromModuleRuleSchema


moduleDefinitionVisitor : Node.Node Module.Module -> List String -> ( List (Error {}), List String )
moduleDefinitionVisitor node allowedModules =
    let
        mod =
            Node.value node

        moduleName =
            mod |> Module.moduleName |> String.join "."
    in
    if Gate.isAllowed allowedModules moduleName then
        ( [], allowedModules )

    else
        let
            exposingNode : Exposing
            exposingNode =
                Module.exposingList mod

            ( errors, _ ) =
                findMergedInExposing exposingNode
        in
        ( errors, allowedModules )


findMergedInExposing : Exposing -> ( List (Error {}), Set String )
findMergedInExposing exposing_ =
    case exposing_ of
        All _ ->
            ( [], Set.empty )

        Explicit nodes ->
            let
                items =
                    List.filterMap extractNameAndRange nodes
            in
            ( findMerged items, Set.empty )


type alias NamedItem =
    { name : String
    , range : Range
    }


extractNameAndRange : Node.Node TopLevelExpose -> Maybe NamedItem
extractNameAndRange (Node.Node range expose) =
    case expose of
        FunctionExpose name ->
            Just { name = name, range = range }

        InfixExpose name ->
            Just { name = name, range = range }

        TypeOrAliasExpose name ->
            Just { name = name, range = range }

        TypeExpose { name } ->
            Just { name = name, range = range }


{-| For each `with<X>` in the list, check if `<lowercaseFirstLetter(X)>` is also
present. Collect errors for any match.

Heuristic: "with" followed by an uppercase letter is a pipe. The corresponding
setter is the same stem with the first letter lowered (disabled ← withDisabled).

-}
findMerged : List NamedItem -> List (Error {})
findMerged items =
    let
        pipes : List NamedItem
        pipes =
            List.filterMap
                (\n ->
                    if isPipe n.name then
                        Just n

                    else
                        Nothing
                )
                items

        setterNames : Set String
        setterNames =
            List.map (.name >> String.toLower) items |> Set.fromList
    in
    List.filterMap
        (\{ name, range } ->
            let
                stem =
                    String.dropLeft 4 name
            in
            if stem /= "" && isUpperFirst stem && Set.member (String.toLower stem) setterNames then
                Just (error name stem range)

            else
                Nothing
        )
        pipes


isPipe : String -> Bool
isPipe name =
    String.startsWith "with" name && String.length name > 4 && isUpperFirst (String.dropLeft 4 name)


isUpperFirst : String -> Bool
isUpperFirst str =
    case String.uncons str of
        Just ( c, _ ) ->
            c >= 'A' && c <= 'Z'

        Nothing ->
            False


error : String -> String -> Range -> Error {}
error pipe stem range =
    Rule.error
        { message = "`" ++ pipe ++ "` pipe and `" ++ stem ++ "` setter must not be in the same module"
        , details =
            [ "The K5/#58 structural guarantee requires pipes (with<X> family) to live in M3e.<Component>.Build modules and bare setters (<x> family) to live in M3e.<Component> modules. Merging both into one module recreates the name collision the 3‑package split was designed to avoid."
            , "Remove the `" ++ pipe ++ "` pipe or the `" ++ stem ++ "` setter from this module, or split the exposing list so that this module exposes only one family."
            ]
        }
        range
