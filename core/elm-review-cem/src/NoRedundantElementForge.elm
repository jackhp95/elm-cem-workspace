module NoRedundantElementForge exposing (rule)

{-| **The typed-producer redundancy backstop** (companion to
`NoInternalImportOutsideAllowed`).

`NoInternalImportOutsideAllowed` fences `HtmlIr.Internal` — the raw→phantom forge
— to a small allow-list of adapter modules (`Seam`/`Native`/`Kit`/…). Inside
those blessed modules the forge is legitimate; but it is legitimate only for what
the typed producer layer **cannot express**: custom elements, event escapes, and
arbitrary attributes/styles. A blessed module that forges a _plain HTML tag_
`TypedHtml.*` already provides is re-implementing the typed layer with a
**fully-open** attribute row (`List (Attr c msg)`, zero constraint) where the
typed producer offers a **closed, element-natural** one (`TypedHtml.label` is a
closed `LabelAttrs`; any other attr is a compile error).

This rule flags exactly that redundancy. It is **facts-driven and
namespace-agnostic**: the covered-tag set is enumerated from the passed
`List Cem.Facts.Fact` (`TypedHtml.Review.Facts.facts`), one entry per HTML tag.
The covered set is keyed on the **HTML tag** the forge writes as a literal, not
on the Elm producer name — so a fact whose `component` is `"main_"` (elm-cem
escapes `<main>` because a top-level `main` is the program entry) covers the tag
`"main"`, and a forged `Ir.node "main"` is flagged. Nothing is hardcoded.

    config =
        [ NoRedundantElementForge.rule TypedHtml.Review.Facts.facts
        ]

**Detection** (declaration-body traversal, like `ExtractToSeam`):

  - _Gate_ — the module must `import HtmlIr.Internal` (under any alias). Modules
    that don't touch the forge cannot re-implement it, so they are skipped whole.
  - _Local forge helpers_ — a top-level function whose body forges a node via
    `HtmlIr.Internal.node` (directly, or wrapped in `HtmlIr.Internal.fromNode`).
    The canonical one is `node tagName attrs kids = Ir.fromNode (Ir.node tagName …)`.
    Applying such a helper to a literal tag is the same as forging directly.
  - _Producers_ — a top-level function that applies a **forge** (either
    `HtmlIr.Internal.node` itself, or a local forge helper) to a tag argument that
    is a **literal string in the covered set** is flagged. This covers both the
    direct `a attrs kids = Ir.fromNode (Ir.node "a" …)` form and the point-free
    `div = node "div"` form.

**Precision — the escapes it must NOT flag** (keyed strictly on a literal tag ∈
covered set):

  - a variable/dynamic tag (`node tagName …`, `custom name = node name`) — not a
    literal, so unresolvable and silent;
  - a literal tag NOT in the covered set (`Ir.node "compass-passkey" …`) — a
    genuine custom element the typed layer cannot express;
  - the attribute/event escapes (`attribute`/`onClick`/`style`/`fieldLabel`) —
    they forge via `fromHtmlAttribute`/`addAttribute`, never `node`;
  - a tag value that comes from a `case`/`if`/helper return (unresolvable) —
    advisory silence, never a false positive.

**Advisory, no autofix.** Retargeting a producer to `TypedHtml.<tag>` narrows an
open row to a closed one, which **surfaces real type errors** (attrs that were
silently accepted on the wrong element). That needs human judgment; an autofix
would either hide the error or emit non-compiling code. So the rule only points.

@docs rule

-}

import Cem.Facts exposing (Fact)
import Cem.Internal.Facts as Facts
import Elm.Syntax.Declaration as Declaration exposing (Declaration)
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Import exposing (Import)
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Range exposing (Range)
import Review.ModuleNameLookupTable as Lookup exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)
import Set exposing (Set)


{-| Build the rule from the generated facts (`TypedHtml.Review.Facts.facts`). The
covered-tag `Set` is derived from each fact's HTML tag (`Facts.htmlTagOf`, which
reverses elm-cem's reserved-word escaping so `component = "main_"` yields the tag
`"main"`) — so the rule tracks whatever the typed-HTML producer layer actually
covers, with no hardcoded list.
-}
rule : List Fact -> Rule
rule facts =
    let
        coveredTags : Set String
        coveredTags =
            facts
                |> List.map Facts.htmlTagOf
                |> Set.fromList
    in
    Rule.newModuleRuleSchemaUsingContextCreator "NoRedundantElementForge" (initContext coveredTags)
        |> Rule.withImportVisitor importVisitor
        |> Rule.withDeclarationListVisitor (declarationListVisitor coveredTags)
        |> Rule.fromModuleRuleSchema



-- CONTEXT


type alias Context =
    { coveredTags : Set String
    , lookup : ModuleNameLookupTable
    , importsInternal : Bool
    }


{-| The one internal forge module, by fully-qualified name. The rule resolves the
head of every candidate application through the module-name lookup table, so a
local alias (`import HtmlIr.Internal as Ir`) is irrelevant — only the resolved
name matters.
-}
internalModuleName : ModuleName
internalModuleName =
    [ "HtmlIr", "Internal" ]


initContext : Set String -> Rule.ContextCreator () Context
initContext coveredTags =
    Rule.initContextCreator
        (\lookup () ->
            { coveredTags = coveredTags
            , lookup = lookup
            , importsInternal = False
            }
        )
        |> Rule.withModuleNameLookupTable



-- IMPORT GATE


importVisitor : Node Import -> Context -> ( List (Error {}), Context )
importVisitor node context =
    if Node.value (Node.value node).moduleName == internalModuleName then
        ( [], { context | importsInternal = True } )

    else
        ( [], context )



-- DECLARATION TRAVERSAL


declarationListVisitor : Set String -> List (Node Declaration) -> Context -> ( List (Error {}), Context )
declarationListVisitor _ declarations context =
    if not context.importsInternal then
        ( [], context )

    else
        let
            functions : List Function
            functions =
                List.filterMap asFunction declarations

            -- The names of local top-level functions whose body itself forges a
            -- node via `HtmlIr.Internal.node`. Applying one of these to a literal
            -- tag is redundant exactly as applying `Ir.node` directly is.
            localForgeHelpers : Set String
            localForgeHelpers =
                functions
                    |> List.filter (\f -> bodyForgesNode context.lookup f.body)
                    |> List.map .name
                    |> Set.fromList
        in
        ( List.filterMap (checkProducer context localForgeHelpers) functions
        , context
        )


type alias Function =
    { name : String
    , body : Node Expression
    }


asFunction : Node Declaration -> Maybe Function
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



-- FORGE DETECTION


{-| Does this expression forge a node through the internal forge — i.e. is it (or
does it wrap, via `HtmlIr.Internal.fromNode` / parens) an application whose head
resolves to `HtmlIr.Internal.node`?

This recognizes a _local forge helper_ body such as

    Ir.fromNode
        (Ir.node tagName attrs (List.map HtmlIr.Element.toNode kids))

regardless of whether the tag is a literal or (as here) a parameter. It is only
used to classify a helper as "a forger"; the literal-tag precision is applied
separately at each producer call site.

-}
bodyForgesNode : ModuleNameLookupTable -> Node Expression -> Bool
bodyForgesNode lookup expr =
    case Node.value expr of
        Expression.ParenthesizedExpression inner ->
            bodyForgesNode lookup inner

        Expression.Application (head :: args) ->
            if resolvesTo lookup internalModuleName "node" head then
                True

            else if resolvesTo lookup internalModuleName "fromNode" head then
                -- `Ir.fromNode (…)` — descend into its argument.
                List.any (bodyForgesNode lookup) args

            else
                False

        _ ->
            False


{-| Inspect a producer's body for a redundant forge of a covered literal tag.

The producer is flagged when its body applies a **forge** — either
`HtmlIr.Internal.node` directly, or a local forge helper — with a **literal
string tag argument in the covered set**. Both the direct form
(`Ir.fromNode (Ir.node "a" …)`) and the point-free form (`node "div"`) reduce to
an `Application` whose head is the forge and whose first argument is the tag.

Returns `Nothing` (advisory silence) when the tag is a variable, a non-literal
expression, or a literal that is not covered — every legitimate escape.

-}
checkProducer : Context -> Set String -> Function -> Maybe (Error {})
checkProducer context localForgeHelpers function =
    case redundantTag context localForgeHelpers function.body of
        Just ( tag, range ) ->
            Just (forgeError function.name tag range)

        Nothing ->
            Nothing


{-| The covered literal tag a producer body redundantly forges, if any, with the
range to report under. Unwraps parens / `Ir.fromNode`, then looks for an
`Application` whose head is a forge and whose first argument is a covered literal.
-}
redundantTag : Context -> Set String -> Node Expression -> Maybe ( String, Range )
redundantTag context localForgeHelpers expr =
    case Node.value expr of
        Expression.ParenthesizedExpression inner ->
            redundantTag context localForgeHelpers inner

        Expression.Application (head :: firstArg :: _) ->
            if resolvesTo context.lookup internalModuleName "fromNode" head then
                -- `Ir.fromNode (…)` wrapper: the forge is inside the argument.
                redundantTag context localForgeHelpers firstArg

            else if isForgeHead context localForgeHelpers head then
                literalCoveredTag context firstArg

            else
                Nothing

        _ ->
            Nothing


{-| Is `head` a forge — `HtmlIr.Internal.node` itself, or a local top-level helper
that forges a node?
-}
isForgeHead : Context -> Set String -> Node Expression -> Bool
isForgeHead context localForgeHelpers head =
    resolvesTo context.lookup internalModuleName "node" head
        || isLocalForgeHelper context localForgeHelpers head


{-| Does `head` reference a local forge helper (an unqualified name that resolves
to _this_ module and is in the forge-helper set)?
-}
isLocalForgeHelper : Context -> Set String -> Node Expression -> Bool
isLocalForgeHelper context localForgeHelpers head =
    case Node.value head of
        Expression.FunctionOrValue _ name ->
            Set.member name localForgeHelpers
                && (case Lookup.moduleNameFor context.lookup head of
                        -- elm-review reports a same-module top-level reference as `[]`.
                        Just [] ->
                            True

                        _ ->
                            False
                   )

        _ ->
            False


{-| If `expr` is a string literal whose value is a covered tag, return it with its
range; otherwise `Nothing` (variable tag, dynamic tag, or uncovered custom
element — all silent).
-}
literalCoveredTag : Context -> Node Expression -> Maybe ( String, Range )
literalCoveredTag context expr =
    case Node.value expr of
        Expression.Literal tag ->
            if Set.member tag context.coveredTags then
                Just ( tag, Node.range expr )

            else
                Nothing

        _ ->
            Nothing


{-| Does a function-reference node resolve (via the lookup table) to
`moduleName.name`?
-}
resolvesTo : ModuleNameLookupTable -> ModuleName -> String -> Node Expression -> Bool
resolvesTo lookup moduleName name node =
    case Node.value node of
        Expression.FunctionOrValue _ actualName ->
            actualName == name && Lookup.moduleNameFor lookup node == Just moduleName

        _ ->
            False



-- ERROR


forgeError : String -> String -> Range -> Error {}
forgeError producerName tag range =
    Rule.error
        { message = "`" ++ producerName ++ "` re-implements `TypedHtml." ++ tag ++ "` over the IR forge"
        , details =
            [ "This producer forges a plain `<" ++ tag ++ ">` through `HtmlIr.Internal`, but `TypedHtml." ++ tag ++ "` already provides that element with a closed, element-natural attribute row. The hand-rolled forge accepts a fully-open attribute row (any `Attr` on any element), so it re-implements the typed producer layer while dropping the very constraint that layer exists to give."
            , "Use `TypedHtml." ++ tag ++ "` and reserve `HtmlIr.Internal` for what the typed layer cannot express: custom elements, event escapes, and arbitrary attributes or styles. Retargeting is left to you (no autofix), because narrowing the open row to the closed one surfaces real type errors — attributes that were silently accepted on the wrong element — that need a human decision."
            ]
        }
        range
