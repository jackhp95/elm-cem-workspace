module Cem.PreferBarrel exposing (rule, ruleWith)

{-| Opt-in autofix: rewrite the strict Standard per-component facet
(`<root>.<Comp>.*`) to the flat `<root>` barrel, driven by `Cem.Facts`.

This is the exact inverse of `PreferComponentModules` (barrel → per-component). It is
NOT meant for the shipped `ReviewConfig`; it exists so a docs harness (and any
consumer who prefers a single flat import) can barrelise a Standard example with
`elm-review --fix`.

Four rewrite classes, all resolved through the `ModuleNameLookupTable` so only the
genuine `<root>.<Comp>.*` / `<root>.Token.*` facets are touched — never
`<root>.Html.*`, `<root>.Record.*`, `<root>.Build.*`, `<root>.Raw.*`, or
`<root>.Aria`:

  - Constructor: `<root>.<Comp>.view` → `<root>.<noun>` (the barrel constructor).
    A VARIANT-GROUP module (`<root>.Progress`, members `circular`/`linear`) has no
    `view`; its member constructors (listed in `fact.groupConstructors`) are
    re-exposed flat under their own names, so `<root>.Progress.circular` →
    `<root>.circular`.
  - Attr: `<root>.<Comp>.<attr>` → `<root>.<barrelAttr>` via `attrRewrites` (the
    barrel↔per-component map, read right-to-left here). A setter with NO
    `attrRewrites` entry is left per-component — including the multi-type scalars
    `value`/`name`, whose bare barrel form is only correct for the dominant type,
    so no bare fallback is guessed. The generator supplies a capability-correct
    entry (`Slider.value` → `attrValueFloat`) for the ones that have a safe form.
  - Slot: `<root>.<Comp>.<setter>` → `<root>.<genericSlot>` via the parallel
    `slotRewrites`/`slotUpgrades` pair (per-component setter → generic barrel
    slot, e.g. `<root>.Button.child` → `<root>.slotDefault`).
  - Value token: `<root>.Token.<token>` → `<root>.<token>` — but ONLY for tokens
    the barrel actually re-exposes. A barrel that re-exposes NO value tokens (every
    one would collide with a same-named boolean attr, e.g. `filled`) leaves the
    production `rule` inert for this class; `ruleWith` injects a re-expose set for
    tests and for a future barrel that surfaces non-colliding tokens.

@docs rule, ruleWith

-}

import Cem.Facts exposing (Fact)
import Cem.Internal.Facts as Facts
import Dict exposing (Dict)
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Import exposing (Import)
import Elm.Syntax.Module as Module
import Elm.Syntax.Node as Node exposing (Node)
import Review.Fix as Fix
import Review.ModuleNameLookupTable as Lookup exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)
import Set exposing (Set)


{-| Build from the generated facts (`Cem.Facts`). No value tokens are re-exposed
by an unconfigured barrel, so the `<root>.Token.*` class never fires.
-}
rule : List Fact -> Rule
rule facts =
    ruleWith Set.empty facts


{-| Like `rule`, but with an explicit set of `<root>.Value` token names the barrel
re-exposes under the barrel root (enabling the `<root>.Token.<token>` →
`<root>.<token>` class). Used by the tests to pin that class, and by any library
whose barrel does surface non-colliding tokens.
-}
ruleWith : Set String -> List Fact -> Rule
ruleWith reExposedValues facts =
    Rule.newModuleRuleSchemaUsingContextCreator "PreferBarrel" (initContext reExposedValues facts)
        |> Rule.withModuleDefinitionVisitor moduleDefinitionVisitor
        |> Rule.withImportVisitor importVisitor
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


type alias Context =
    { lookup : ModuleNameLookupTable
    , byModule : Dict String Fact
    , reExposedValues : Set String
    , namespaces : List (List String)
    , importedModules : Set (List String)
    , insertionRow : Int
    }


initContext : Set String -> List Fact -> Rule.ContextCreator () Context
initContext reExposedValues facts =
    Rule.initContextCreator
        (\lookup () ->
            { lookup = lookup
            , byModule =
                facts
                    |> List.map (\f -> ( f.module_, f ))
                    |> Dict.fromList
            , reExposedValues = reExposedValues
            , namespaces = Facts.namespaces facts
            , importedModules = Set.empty
            , insertionRow = 1
            }
        )
        |> Rule.withModuleNameLookupTable


{-| The `(namespace, remainder)` for the first namespace whose prefix matches
`moduleParts` — so a reference is resolved under the right library's root even
when several libraries' facts were concatenated.
-}
matchNamespace : List (List String) -> List String -> Maybe ( List String, List String )
matchNamespace namespaces moduleParts =
    namespaces
        |> List.filterMap (\ns -> Facts.dropPrefix ns moduleParts |> Maybe.map (\rem -> ( ns, rem )))
        |> List.head


{-| Track the module-definition line so `importFixIfMissing` has a fallback
insertion point when a module has no imports at all. Mirrors `PreferComponentModules`.
-}
moduleDefinitionVisitor : Node Module.Module -> Context -> ( List (Error {}), Context )
moduleDefinitionVisitor node context =
    ( [], { context | insertionRow = (Node.range node).end.row } )


{-| Record every imported module (so we never re-add the barrel import) and keep
the insertion row at the last import, so an inserted `import <root>` lands after
the existing imports. Mirrors `PreferComponentModules`.
-}
importVisitor : Node Import -> Context -> ( List (Error {}), Context )
importVisitor node context =
    ( []
    , { context
        | importedModules = Set.insert (Node.value (Node.value node).moduleName) context.importedModules
        , insertionRow = (Node.range node).end.row
      }
    )


expressionVisitor : Node Expression -> Context -> ( List (Error {}), Context )
expressionVisitor node context =
    case Node.value node of
        -- An enum setter applied to a LITERAL token — `<root>.<Comp>.<enumAttr>
        -- <root>.Token.<tok>` — collapses to the single combined constant
        -- `<root>.<enumAttr><Tok>` (`variantFilled`). A DYNAMIC arg (a bare
        -- variable / computed expression) has no static value to fold, so it is
        -- left per-component. Handled at the Application node so the whole call is
        -- replaced in one fix.
        Expression.Application (fnNode :: argNode :: []) ->
            case combinedCollapse context fnNode argNode of
                Just err ->
                    ( [ err ], context )

                Nothing ->
                    ( [], context )

        Expression.FunctionOrValue _ name ->
            case Lookup.moduleNameFor context.lookup node of
                Just moduleParts ->
                    ( errorsFor context node name moduleParts, context )

                Nothing ->
                    ( [], context )

        _ ->
            ( [], context )


{-| If `fnNode` resolves to a component's enum setter (`<root>.<Comp>.<enumAttr>`)
and `argNode` resolves to one of that enum's valid tokens (`<root>.Token.<tok>`),
fold the whole application to the barrel combined `<root>.<enumAttr><Tok>`.
-}
combinedCollapse : Context -> Node Expression -> Node Expression -> Maybe (Error {})
combinedCollapse context fnNode argNode =
    case ( Node.value fnNode, Node.value (unwrapParens argNode) ) of
        ( Expression.FunctionOrValue _ attrName, Expression.FunctionOrValue _ tokenName ) ->
            case Lookup.moduleNameFor context.lookup fnNode of
                Just fnModule ->
                    case Dict.get (String.join "." fnModule) context.byModule of
                        Just fact ->
                            let
                                rootParts =
                                    Facts.factNamespaceParts fact

                                root =
                                    Facts.factNamespace fact
                            in
                            if Maybe.andThen (Facts.dropPrefix rootParts) (Lookup.moduleNameFor context.lookup (unwrapParens argNode)) == Just [ "Token" ] then
                                combinedName fact attrName tokenName
                                    |> Maybe.map
                                        (\combined ->
                                            barrelError context
                                                rootParts
                                                (applicationNode fnNode argNode)
                                                (String.join "." fnModule ++ "." ++ attrName ++ " " ++ root ++ ".Token." ++ tokenName)
                                                (root ++ "." ++ combined)
                                                "enum value"
                                        )

                            else
                                Nothing

                        Nothing ->
                            Nothing

                Nothing ->
                    Nothing

        _ ->
            Nothing


{-| The combined constant name for `<root>.<enumAttr><Tok>`, or `Nothing` if
`attrName` is not one of `fact`'s enum attributes or `tokenName` is not one of its
valid tokens. `fact.enums` keys are the per-component setter identifiers (keyword
attrs carry a trailing `_`, e.g. `type_`); the combined base strips that so it
matches the barrel (`typeButton`, not `type_Button`).
-}
combinedName : Fact -> String -> String -> Maybe String
combinedName fact attrName tokenName =
    fact.enums
        |> List.filter (\( a, _ ) -> a == attrName)
        |> List.head
        |> Maybe.andThen
            (\( _, tokens ) ->
                if List.member tokenName tokens then
                    Just (dropTrailingUnderscore attrName ++ capitalizeFirst tokenName)

                else
                    Nothing
            )


dropTrailingUnderscore : String -> String
dropTrailingUnderscore s =
    if String.endsWith "_" s then
        String.dropRight 1 s

    else
        s


capitalizeFirst : String -> String
capitalizeFirst s =
    case String.uncons s of
        Just ( c, rest ) ->
            String.cons (Char.toUpper c) rest

        Nothing ->
            s


unwrapParens : Node Expression -> Node Expression
unwrapParens node =
    case Node.value node of
        Expression.ParenthesizedExpression inner ->
            unwrapParens inner

        _ ->
            node


{-| A synthetic node spanning `fn arg`, used as the fix range for a collapse.
-}
applicationNode : Node Expression -> Node Expression -> Node Expression
applicationNode fnNode argNode =
    Node.Node
        { start = (Node.range fnNode).start
        , end = (Node.range argNode).end
        }
        (Expression.Application [ fnNode, argNode ])


errorsFor : Context -> Node Expression -> String -> List String -> List (Error {})
errorsFor context node name moduleParts =
    case matchNamespace context.namespaces moduleParts of
        Just ( ns, [ "Token" ] ) ->
            let
                root =
                    String.join "." ns
            in
            if Set.member name context.reExposedValues then
                [ barrelError context ns node (root ++ ".Token." ++ name) (root ++ "." ++ name) "value token" ]

            else
                []

        Just ( ns, [ "Aria" ] ) ->
            case ariaUniversalBarrel name of
                Just barrelName ->
                    let
                        root =
                            String.join "." ns
                    in
                    [ barrelError context ns node (root ++ ".Aria." ++ name) (root ++ "." ++ barrelName) "aria setter" ]

                Nothing ->
                    []

        _ ->
            case Dict.get (String.join "." moduleParts) context.byModule of
                Just fact ->
                    barrelReplacement fact name
                        |> Maybe.map
                            (\( replacement, kind ) ->
                                [ barrelError context (Facts.factNamespaceParts fact) node (fact.module_ ++ "." ++ name) replacement kind ]
                            )
                        |> Maybe.withDefault []

                Nothing ->
                    []


{-| Given a per-component reference name, decide its flat barrel form (and a label
for the message), or `Nothing` if the name has no barrel equivalent.
-}
barrelReplacement : Fact -> String -> Maybe ( String, String )
barrelReplacement fact name =
    if name == "view" then
        Just ( Facts.factNamespace fact ++ "." ++ fact.component, "constructor" )

    else if List.member name fact.groupConstructors then
        -- A variant-group member constructor (`<root>.Progress.circular`). The
        -- barrel re-exposes it flat under the SAME name (identity), so the flat
        -- form is just `<root>.<name>`.
        Just ( Facts.factNamespace fact ++ "." ++ name, "constructor" )

    else
        case attrBarrelName fact name of
            Just barrelName ->
                Just ( Facts.factNamespace fact ++ "." ++ barrelName, "attribute setter" )

            Nothing ->
                case slotBarrelName fact name of
                    Just generic ->
                        Just ( Facts.factNamespace fact ++ "." ++ generic, "slot setter" )

                    Nothing ->
                        -- No scalar `value`/`name` fallback: those attributes are
                        -- multi-type across components (`value : String` on some,
                        -- `Float` on others), so the bare barrel `<root>.value` is
                        -- only correct for the dominant type. Since a usage rule
                        -- cannot see which capability a per-component setter carries,
                        -- and a wrong guess produces non-compiling code, leave every
                        -- setter without an explicit `attrRewrites` entry on the
                        -- per-component facet. The generator maps the ones that DO
                        -- have a safe barrel form (`Slider.value` → `attrValueFloat`)
                        -- via `attrRewrites`, handled by `attrBarrelName` above.
                        Nothing


{-| The universal `<root>.Aria.<setter>` functions are re-exposed flat under the
barrel as `aria<Setter>` (`<root>.Aria.label` → `<root>.ariaLabel`).
-}
ariaUniversalBarrel : String -> Maybe String
ariaUniversalBarrel name =
    case name of
        "label" ->
            Just "ariaLabel"

        "labelledby" ->
            Just "ariaLabelledby"

        "describedby" ->
            Just "ariaDescribedby"

        "hidden" ->
            Just "ariaHidden"

        _ ->
            Nothing


{-| `attrRewrites` maps barrel name → per-component name; read it right-to-left.

IDENTITY entries (barrel name == per-component name) are skipped. The barrel's
disambiguation scheme RENAMES every interchangeable setter (a scalar `disabled`
becomes `attrDisabled`), so a setter the barrel kept under its own name is NOT
the same function — it is a generic re-export with a different signature
(events: the per-component `onClick : msg -> …` convenience vs the barrel
`onClick : Decoder msg -> …`). Rewriting those changes the required argument
type and breaks compilation, so they must stay on the per-component facet.

-}
attrBarrelName : Fact -> String -> Maybe String
attrBarrelName fact name =
    fact.attrRewrites
        |> List.filter (\( barrel, perComp ) -> perComp == name && barrel /= perComp)
        |> List.head
        |> Maybe.map Tuple.first


{-| `slotRewrites` (slotName → per-component setter) and `slotUpgrades`
(generic barrel setter → specific barrel setter) are emitted as parallel
lists, so zipping them maps a per-component setter to its generic barrel form.
-}
slotBarrelName : Fact -> String -> Maybe String
slotBarrelName fact name =
    List.map2 (\( _, perComp ) ( generic, _ ) -> ( perComp, generic ))
        fact.slotRewrites
        fact.slotUpgrades
        |> List.filter (\( perComp, _ ) -> perComp == name)
        |> List.head
        |> Maybe.map Tuple.second


barrelError : Context -> List String -> Node Expression -> String -> String -> String -> Error {}
barrelError context rootParts node original replacement kind =
    let
        root =
            String.join "." rootParts
    in
    Rule.errorWithFix
        { message =
            "`" ++ original ++ "` can be flattened to the barrel " ++ kind ++ " `" ++ replacement ++ "`"
        , details =
            [ "The `"
                ++ root
                ++ "` barrel re-exports this "
                ++ kind
                ++ " so a single `import "
                ++ root
                ++ "` covers the whole example. The per-component facet stays available for callers who want the tighter type."
            ]
        }
        (Node.range node)
        (Fix.replaceRangeBy (Node.range node) replacement
            :: importFixIfMissing context rootParts
        )


{-| Every barrel replacement targets a `<root>.*` reference, so the fix is only
sound if the module imports the barrel root. Insert `import <root>` after the
existing imports when it is absent (idempotent: a no-op once imported). This is
the mirror image of `PreferComponentModules.importFixIfMissing`, and is what makes
the two rules genuine inverses in a module that starts from a single-facet
import — the case the round-trip fixtures did not exercise.
-}
importFixIfMissing : Context -> List String -> List Fix.Fix
importFixIfMissing context rootParts =
    if Set.member rootParts context.importedModules then
        []

    else
        [ Fix.insertAt
            { row = context.insertionRow + 1, column = 1 }
            ("import " ++ String.join "." rootParts ++ "\n")
        ]
