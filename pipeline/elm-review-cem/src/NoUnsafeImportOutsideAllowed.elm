module NoUnsafeImportOutsideAllowed exposing (rule)

{-| The **escape-surface boundary backstop** (see docs/decisions.md §"Seam-discipline rules live here").

Each brand's generated `*.Unsafe` / `*.Unsafe.Attributes` modules are the loud,
greppable, legacy-interop escape surface: they wrap raw `Html` (`fromHtml`,
`fromHtmlAttribute`) and re-kind elements/attributes with FREE phantom rows
(`recast`, `recastAttr`), so the compiler checks nothing about the result. They
are the brand-level companion to the `*.Internal` forge fenced by
[`NoInternalImportOutsideAllowed`](NoInternalImportOutsideAllowed).

This rule flags any `import <brand>.Unsafe` (or `<brand>.Unsafe.Attributes`) from
a module that is not allowed to hold the escape. A module is allowed when its own
name matches one of the configured allow-list prefixes — the generated `M3e.*`
namespace (trusted, produced by the codegen) plus a team's designated
`Seam`/escape modules:

    config =
        [ NoUnsafeImportOutsideAllowed.rule
            [ "M3e", "Seam", "Native", "Kit", "Layout" ]
        ]

An allow-list entry is a dotted module-name prefix: `"M3e"` matches `M3e`,
`M3e.Button`, …; `"Kit"` matches `Kit` and `Kit.Surface`. An empty list gates
`*.Unsafe` everywhere.

Only imports with an `Unsafe` **last or second-to-last** segment are considered,
so `import M3e.Unsafe` and `import TypedHtml.Unsafe.Attributes` are gated, but
`import M3e.Unsafely.Fine` is not.

@docs rule

-}

import Cem.Internal.Gate as Gate
import Elm.Syntax.Import exposing (Import)
import Elm.Syntax.Module as Module
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node)
import Review.Rule as Rule exposing (Error, Rule)


{-| Build the gate from the list of module-name prefixes allowed to import a
`*.Unsafe` module (dotted names).
-}
rule : List String -> Rule
rule allowed =
    Rule.newModuleRuleSchemaUsingContextCreator "NoUnsafeImportOutsideAllowed" (initContext allowed)
        |> Rule.withModuleDefinitionVisitor moduleDefinitionVisitor
        |> Rule.withImportVisitor importVisitor
        |> Rule.fromModuleRuleSchema


type alias Context =
    { allowed : List String
    , gated : Bool
    }


initContext : List String -> Rule.ContextCreator () Context
initContext allowed =
    Rule.initContextCreator
        (\() ->
            { allowed = allowed
            , gated = True
            }
        )


moduleDefinitionVisitor : Node Module.Module -> Context -> ( List (Error {}), Context )
moduleDefinitionVisitor node context =
    let
        currentModule =
            Node.value node
                |> Module.moduleName
                |> String.join "."
    in
    ( [], { context | gated = not (Gate.isAllowed context.allowed currentModule) } )


importVisitor : Node Import -> Context -> ( List (Error {}), Context )
importVisitor node context =
    if not context.gated then
        ( [], context )

    else
        let
            imported =
                Node.value (Node.value node).moduleName
        in
        if isUnsafeModule imported then
            ( [ error imported (Node.range (Node.value node).moduleName) ], context )

        else
            ( [], context )


{-| A `*.Unsafe` module is one whose last dotted segment is exactly `Unsafe`
(e.g. `M3e.Unsafe`) or whose second-to-last segment is `Unsafe` (e.g.
`TypedHtml.Unsafe.Attributes`).
-}
isUnsafeModule : ModuleName -> Bool
isUnsafeModule moduleName =
    case List.reverse moduleName of
        last :: rest ->
            last == "Unsafe" || List.head rest == Just "Unsafe"

        [] ->
            False


error : ModuleName -> { start : { row : Int, column : Int }, end : { row : Int, column : Int } } -> Error {}
error moduleName range =
    let
        qualified =
            String.join "." moduleName
    in
    Rule.error
        { message = "`" ++ qualified ++ "` imported outside an allowed module"
        , details =
            [ "`" ++ qualified ++ "` is a loud legacy-interop escape surface: it wraps raw `Html` and re-kinds elements with FREE phantom rows, so the compiler checks nothing about the result (see docs/decisions.md §\"Seam-discipline rules live here\")."
            , "Importing it here scatters unchecked escapes through feature code. Reach for the typed `" ++ brandRoot moduleName ++ "` API, or move this crossing into a designated Seam/escape module in the allow-list."
            ]
        }
        range


{-| The brand root: the module-name segments up to (not including) the first
`Unsafe` segment. `M3e.Unsafe` -> `M3e`; `TypedHtml.Unsafe.Attributes` -> `TypedHtml`.
-}
brandRoot : ModuleName -> String
brandRoot moduleName =
    moduleName
        |> takeWhileNot "Unsafe"
        |> String.join "."


takeWhileNot : String -> List String -> List String
takeWhileNot stop segments =
    case segments of
        [] ->
            []

        first :: rest ->
            if first == stop then
                []

            else
                first :: takeWhileNot stop rest
