module NoInternalImportOutsideAllowed exposing (rule)

{-| The **opaque-IR boundary backstop** (see docs/decisions.md §"Seam-discipline rules live here").

The IR core types (`Element`, `Node`, `Attr`, `Value`) cross from raw to
phantom-typed only through **`HtmlIr.Internal`** — the one curated forge module
(in `elm-html-intermediate-representation`) that exposes the opaque constructors
and the free phantom-asserting operations (`fromNode`, `attribute`/`property`/
`on`/`fromHtmlAttribute`, `token`, `fromHtml`). The **primary** fence is
structural: the public `HtmlIr.*` modules withhold those names, so a module that
only imports the public API literally cannot mint an `Element` from raw.

This rule is the coarse backstop on top of the structural fence: it flags any
`import <something>.Internal` from a module that is not allowed to hold the
escape. A module is allowed when its own name matches one of the configured
allow-list prefixes — the generated `M3e.*` namespace (trusted, produced by the
codegen) plus a team's designated `Seam`/escape modules:

    config =
        [ NoInternalImportOutsideAllowed.rule
            [ "M3e", "Seam", "Native", "Kit", "Layout" ]
        ]

An allow-list entry is a dotted module-name prefix: `"M3e"` matches `M3e`,
`M3e.Button`, `M3e.Html.Attr.Internal`, …; `"Kit"` matches `Kit` and
`Kit.Surface`. An empty list gates `*.Internal` everywhere.

Only imports whose **last** module segment is `Internal` are considered (so
`import M3e.Element.Internal` is gated, but `import M3e.Element` is not).

@docs rule

-}

import Elm.Syntax.Import exposing (Import)
import Elm.Syntax.Module as Module
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node)
import Review.Rule as Rule exposing (Error, Rule)


{-| Build the gate from the list of module-name prefixes allowed to import an
`*.Internal` module (dotted names).
-}
rule : List String -> Rule
rule allowed =
    Rule.newModuleRuleSchemaUsingContextCreator "NoInternalImportOutsideAllowed" (initContext allowed)
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
    ( [], { context | gated = not (isAllowed context.allowed currentModule) } )


importVisitor : Node Import -> Context -> ( List (Error {}), Context )
importVisitor node context =
    if not context.gated then
        ( [], context )

    else
        let
            imported =
                Node.value (Node.value node).moduleName
        in
        if isInternalModule imported then
            ( [ error imported (Node.range (Node.value node).moduleName) ], context )

        else
            ( [], context )


{-| An `*.Internal` module is one whose last dotted segment is exactly `Internal`.
-}
isInternalModule : ModuleName -> Bool
isInternalModule moduleName =
    List.head (List.reverse moduleName) == Just "Internal"


{-| A module is allowed when its name equals or is nested under (dot-boundary)
one of the allow-list prefixes.
-}
isAllowed : List String -> String -> Bool
isAllowed allowed currentModule =
    List.any
        (\prefix -> currentModule == prefix || String.startsWith (prefix ++ ".") currentModule)
        allowed


error : ModuleName -> { start : { row : Int, column : Int }, end : { row : Int, column : Int } } -> Error {}
error moduleName range =
    let
        qualified =
            String.join "." moduleName
    in
    Rule.error
        { message = "`" ++ qualified ++ "` imported outside an allowed module"
        , details =
            [ "`" ++ qualified ++ "` is an opaque-IR interior module: it exposes the raw-to-phantom constructors and free phantom-asserting operations that the public module deliberately withholds (see docs/decisions.md §\"Seam-discipline rules live here\")."
            , "Importing it here would let this module mint typed IR from raw and assert any phantom row, defeating the boundary. Reach for the public `" ++ dropInternal qualified ++ "` API, or move this crossing into a designated Seam/escape module in the allow-list."
            ]
        }
        range


{-| Drop the trailing `.Internal` segment for the suggestion in the message.
-}
dropInternal : String -> String
dropInternal qualified =
    if String.endsWith ".Internal" qualified then
        -- length of ".Internal"
        String.dropRight 9 qualified

    else
        qualified
