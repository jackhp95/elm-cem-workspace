module NoSeamOutsideAllowedModules exposing (rule)

{-| Generalized **seam gate** (successor to the Ui-era `NoRawLayoutOutsideLayoutModule`).

The seam modules are the single sanctioned holes in the type system (see
docs/decisions.md §"Seam-discipline rules live here"): they turn raw `Html` into a
`Node`/`Element`/`Attr` and coerce a well-typed value to a different phantom row. They exist so the seam between the
typed component IR and raw Elm html is _possible_ — but each use throws away a
guarantee, so a
codebase usually wants them **contained** to a few blessed modules (a
`Native`/`Layout`-style adapter layer) rather than sprinkled through feature code.

This rule flags any reference to a configured seam module's functions from a module
not in the configured allow-list. Point-free uses (`List.map Seam.asElement`) are
caught too.

    config =
        [ NoSeamOutsideAllowedModules.rule
            { seamModules = [ "Seam", "Seam.Internal" ]
            , allowedModules = [ "Native", "Layout", "Kit" ]
            }
        ]

`seamModules` is a list of dotted module names whose functions are considered seams.
Allow-list entries are dotted module-name **prefixes**: `"Kit"` allows `Kit` and
every `Kit.*` submodule (`Kit.Surface`, `Kit.Shape`, …); `"Ui.Layout"` allows just
that module and its descendants. An empty allow-list gates the seam everywhere.

This rule shares its `allowedModules` field with `ExtractToSeam` so both rules can be
driven from a single config record — a single source of truth for which modules are
seams and which are blessed. The `seamModules` field extends the discipline to cover
multiple seam modules (e.g. both the public `Seam` and its internal stamper layer
`Seam.Internal`).

**Brand crossings — one sanctioned form**

  - **`recast`** (in your seam module) — the general brand escape: crosses any kinds
    but makes no semantic claim. Caught and gated by this rule.

A composition that needs a specific kind-crossing has two sanctioned routes,
neither of which is a second escape-hatch module: widen the relevant `admits`
list directly in config, when that does not conflict with the design system's
own guidance; or reach for `recast`, gated here like any other seam, when it
genuinely does conflict and needs an explicit, reviewed exception. (`elm-cem`
briefly had a config-declared `_coerce` block that emitted named crossing
functions into a `<Lib>.Coerce` module, living in an allow-listed module and so
NOT gated by this rule; it was removed after review found it added a second,
narrower, ungated escape hatch alongside `recast` for no real benefit.)

> **Migration note:** if you were using the old `rule : List String -> Rule` signature,
> wrap your allow-list in a record:
>
>     -- Before (old signature)
>     NoSeamOutsideAllowedModules.rule [ "Native", "Layout" ]
>
>     -- After (new signature)
>     NoSeamOutsideAllowedModules.rule
>         { seamModules = [ "Seam" ]
>         , allowedModules = [ "Native", "Layout" ]
>         }

@docs rule

-}

import Cem.Internal.Gate as Gate
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node)
import Review.ModuleNameLookupTable as Lookup exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)


{-| Build the gate from a config record.

  - `seamModules` — the dotted names of modules whose functions count as seams
    (e.g. `[ "Seam", "Seam.Internal" ]`). Typically one module; use multiple to
    gate a layered seam (public contract + internal stampers).
  - `allowedModules` — dotted module-name prefixes allowed to use the seam.
    Matches the `allowedModules` field in `ExtractToSeam.rule`'s config — share
    one config record between both rules for a single source of truth.

-}
rule : { seamModules : List String, allowedModules : List String } -> Rule
rule config =
    let
        parsedSeamModules : List ModuleName
        parsedSeamModules =
            List.map (String.split ".") config.seamModules
    in
    Rule.newModuleRuleSchemaUsingContextCreator "NoSeamOutsideAllowedModules" (initContext parsedSeamModules config.allowedModules)
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


type alias Context =
    { lookup : ModuleNameLookupTable
    , gated : Bool
    , seamModules : List ModuleName
    }


initContext : List ModuleName -> List String -> Rule.ContextCreator () Context
initContext seamModules allowed =
    Rule.initContextCreator
        (\lookup moduleName () ->
            { lookup = lookup
            , gated = not (Gate.isAllowed allowed (String.join "." moduleName))
            , seamModules = seamModules
            }
        )
        |> Rule.withModuleNameLookupTable
        |> Rule.withModuleName


expressionVisitor : Node Expression -> Context -> ( List (Error {}), Context )
expressionVisitor node context =
    if not context.gated then
        ( [], context )

    else
        case Node.value node of
            Expression.FunctionOrValue _ name ->
                case Lookup.moduleNameFor context.lookup node of
                    Just moduleName ->
                        if List.member moduleName context.seamModules then
                            ( [ error moduleName name (Node.range node) ], context )

                        else
                            ( [], context )

                    Nothing ->
                        ( [], context )

            _ ->
                ( [], context )


error : ModuleName -> String -> { start : { row : Int, column : Int }, end : { row : Int, column : Int } } -> Error {}
error moduleName name range =
    let
        qualified =
            String.join "." moduleName ++ "." ++ name
    in
    Rule.error
        { message = "`" ++ qualified ++ "` used outside an allowed module"
        , details =
            [ "`" ++ qualified ++ "` is a seam that discards a type guarantee — it should be contained to the adapter modules in this rule's allow-list, not used in feature code."
            , "Move this into an allowed module (a Native/Layout-style layer), or reach for a typed component API that doesn't need the escape hatch."
            ]
        }
        range
