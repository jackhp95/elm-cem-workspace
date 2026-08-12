module Cem.Internal.Facts exposing
    ( CallSite, callSite
    , buildIndex, find
    , TracedList, tracedList
    , camelize, capitalize
    , rootParts, namespaces, factNamespaceParts, factNamespace, factComponentSegment, htmlTagOf, safeValue
    , factKey, siteKey
    , isTopLayerModule, dropPrefix, remainderUnder
    , namedSlotSetters, fillsDefaultSlot
    , attrBarrelName, ariaBarrelName, barrelSlotSetter
    )

{-| Shared helpers for the codegen-aware rules that consume `Cem.Facts`.

Everything here is namespace-agnostic: the library's root namespace is derived
from a fact's `module_` field (e.g. `"Lib.Button"` → `["Lib"]`), never
hardcoded. Rules pass the derived `rootParts` into `callSite` / `isTopLayerModule`.

@docs CallSite, callSite
@docs buildIndex, find
@docs TracedList, tracedList
@docs camelize, capitalize
@docs rootParts, namespaces, factNamespaceParts, factNamespace, factComponentSegment, htmlTagOf, safeValue
@docs factKey, siteKey
@docs isTopLayerModule, dropPrefix, remainderUnder
@docs namedSlotSetters, fillsDefaultSlot
@docs attrBarrelName, ariaBarrelName, barrelSlotSetter

-}

import Cem.Facts exposing (Facet(..), Fact)
import Dict exposing (Dict)
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node)
import Review.ModuleNameLookupTable as Lookup exposing (ModuleNameLookupTable)


{-| The library's root namespace parts, derived from the first fact's Standard
module (`"Lib.Button"` → `["Lib"]`). Empty facts → `[]`.

**Superseded by `namespaces` for rule wiring.** A single `rootParts` only sees the
FIRST fact's namespace, so a consumer that concatenates two libraries' facts
(`M3e … ++ TypedHtml …`) would have the second library silently ignored. Rules
now group by `namespaces` and resolve call sites against every namespace present.
Kept for the odd single-namespace helper and back-compat.

-}
rootParts : List Fact -> List String
rootParts facts =
    case facts of
        f :: _ ->
            factNamespaceParts f

        [] ->
            []


{-| Every DISTINCT namespace (and its ancestor prefixes) present in the
facts, sorted longest-first. Includes ancestors so that sibling sub-trees
(e.g. `M3e.Unsafe.Attributes` alongside `M3e.Component.Button`) share the
common root (`M3e`). Longest-first ordering ensures `callSiteUnder` matches
the most specific root before falling through to a shorter barrel prefix.
-}
namespaces : List Fact -> List (List String)
namespaces facts =
    let
        allPrefixes ns =
            case ns of
                [] ->
                    []

                _ ->
                    ns :: allPrefixes (dropLast ns)

        unique =
            List.foldl
                (\fact acc ->
                    let
                        prefixes =
                            allPrefixes (factNamespaceParts fact)
                    in
                    List.foldl
                        (\p a ->
                            if List.member p a then
                                a

                            else
                                a ++ [ p ]
                        )
                        acc
                        prefixes
                )
                []
                facts
    in
    List.sortWith (\a b -> compare (List.length b) (List.length a)) unique


{-| A namespace-qualified index key for a fact (`"M3e.Button"` fact →
`"M3e\u{0000}button"`). Keying rule indices on this instead of the bare component
noun keeps two libraries' same-noun components (`M3e`'s `button` and `TypedHtml`'s
`<button>`) distinct.
-}
factKey : Fact -> String
factKey fact =
    factNamespace fact ++ "\u{0000}" ++ fact.component


{-| The `factKey` a resolved call site should look up: its matched namespace plus
its component noun.
-}
siteKey : CallSite -> String
siteKey site =
    String.join "." site.namespace ++ "\u{0000}" ++ site.noun


{-| The namespace parts of a single fact's Standard module — all segments but
the last (`"Lib.Button"` → `["Lib"]`, `"My.Lib.Button"` → `["My", "Lib"]`).
-}
factNamespaceParts : Fact -> List String
factNamespaceParts fact =
    fact.module_
        |> String.split "."
        |> dropLast


{-| The dotted namespace of a single fact (`"Lib.Button"` → `"Lib"`).
-}
factNamespace : Fact -> String
factNamespace fact =
    String.join "." (factNamespaceParts fact)


{-| The HTML tag a typed-HTML producer fact covers, reversing elm-cem's
reserved-word escaping.

elm-cem's `safeValue` appends a trailing `_` to any tag that is an Elm reserved
VALUE name — the keywords plus `main` (a top-level `main` is the program entry
and `elm publish` rejects a non-`Html` one) — so the Elm producer for `<main>`
is `main_`, and `component = "main_"` in the fact. The raw HTML tag, however, is
still `"main"`. `NoRedundantElementForge` must key its covered-tag set on THIS —
the HTML tag the forge writes as a literal (`Ir.node "main"`) — not on the
escaped `component` producer name, or a forged `<main>` (and `<object>`, etc.)
would never match and never be flagged.

Only the exact reserved-word escaping is reversed (a trailing `_` whose base is a
reserved value), so a component genuinely named `foo_` is left untouched.

-}
htmlTagOf : Fact -> String
htmlTagOf fact =
    let
        c =
            fact.component
    in
    if String.endsWith "_" c then
        let
            base =
                String.dropRight 1 c
        in
        if List.member base reservedValues then
            base

        else
            c

    else
        c


{-| The forward direction of the escaping `htmlTagOf` reverses: the Elm VALUE
name the generator emits for a name taken from HTML (`"type"` → `"type_"`,
`"dir"` → `"dir"`). Mirrors `elm-cem/codegen/Naming.elm:safeValue`, so a rule
that has an HTML attribute/tag name in hand can ask for the setter name the
generator would have produced instead of listing the exceptions itself.
-}
safeValue : String -> String
safeValue name =
    if List.member name reservedValues then
        name ++ "_"

    else
        name


{-| Elm reserved VALUE names elm-cem's `safeValue` escapes with a trailing `_`
when derived from an HTML tag (mirrors `elm-cem/codegen/Naming.elm:reservedValues`).
-}
reservedValues : List String
reservedValues =
    [ "main"
    , "type"
    , "module"
    , "where"
    , "import"
    , "as"
    , "exposing"
    , "port"
    , "let"
    , "in"
    , "if"
    , "then"
    , "else"
    , "case"
    , "of"
    , "infix"
    , "alias"
    , "effect"
    , "command"
    , "subscription"
    ]


{-| The PascalCase last segment of a fact's Standard module
(`"Lib.Button"` → `"Button"`).
-}
factComponentSegment : Fact -> String
factComponentSegment fact =
    fact.module_
        |> String.split "."
        |> List.reverse
        |> List.head
        |> Maybe.withDefault ""


dropLast : List a -> List a
dropLast xs =
    case List.reverse xs of
        _ :: rest ->
            List.reverse rest

        [] ->
            []


{-| If `prefix` is a prefix of `full`, return the remaining segments; else Nothing.
`dropPrefix ["Lib"] ["Lib", "Record", "Button"]` → `Just ["Record", "Button"]`.
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


{-| A resolved top-layer call site: which component + which top-shape facet, and
under which of the passed namespaces it resolved (so index lookups and emitted
module names use the right library's root).
-}
type alias CallSite =
    { noun : String
    , facet : Facet
    , namespace : List String
    }


{-| Resolve a function-reference AST node to a top-layer call site, if any,
against ANY of the passed namespaces (so concatenated multi-library facts each
take effect). A resolved module belongs to exactly one namespace, so the first
namespace whose prefix matches wins.

With `namespaces = [ ["Lib"] ]`, handles four forms:

  - `Lib.Button.view` → `{ noun = "button", facet = Standard, namespace = ["Lib"] }`
  - `Lib.Record.Button.view` → `{ noun = "button", facet = Record, … }`
  - `Lib.button` (barrel) → `{ noun = "button", facet = Standard, … }`
  - `Lib.Record.button` (Record barrel) → `{ noun = "button", facet = Record, … }`

Returns `Nothing` for non-top-layer references (`Lib.Html.*`, `Html.*`, etc.).

-}
callSite : List (List String) -> ModuleNameLookupTable -> Node Expression -> Maybe CallSite
callSite roots lookup fnNode =
    case Node.value fnNode of
        Expression.FunctionOrValue _ name ->
            case Lookup.moduleNameFor lookup fnNode of
                Just moduleName ->
                    firstJust (\root -> callSiteUnder root name moduleName) roots

                Nothing ->
                    Nothing

        _ ->
            Nothing


callSiteUnder : List String -> String -> ModuleName -> Maybe CallSite
callSiteUnder root name moduleName =
    case dropPrefix root moduleName of
        Just [] ->
            Just { noun = name, facet = Standard, namespace = root }

        Just [ "Record" ] ->
            Just { noun = name, facet = Record, namespace = root }

        Just [ comp ] ->
            if name == "view" then
                Just { noun = decapitalize comp, facet = Standard, namespace = root }

            else
                Nothing

        Just [ "Record", comp ] ->
            if name == "view" then
                Just { noun = decapitalize comp, facet = Record, namespace = root }

            else
                Nothing

        _ ->
            -- Barrel case: moduleName is a parent of root (e.g. M3e re-exports
            -- M3e.Component.IconButton.iconButton as M3e.iconButton). The
            -- resolved module is shorter than the namespace, but the function
            -- name still matches the component noun — use the full root so the
            -- index key aligns with factKey.
            case moduleName of
                [] ->
                    Nothing

                _ ->
                    case dropPrefix moduleName root of
                        Just _ ->
                            Just { noun = name, facet = Standard, namespace = root }

                        Nothing ->
                            Nothing


firstJust : (a -> Maybe b) -> List a -> Maybe b
firstJust f xs =
    case xs of
        [] ->
            Nothing

        x :: rest ->
            case f x of
                Just y ->
                    Just y

                Nothing ->
                    firstJust f rest


{-| Does `node`'s resolved module belong to the Standard top facet for
`componentNoun`, under ANY of the passed namespaces? True for a barrel root
itself (`root`), or the component module (`root ++ [Capitalized componentNoun]`).
-}
isTopLayerModule : List (List String) -> ModuleNameLookupTable -> Node Expression -> String -> Bool
isTopLayerModule roots lookup node componentNoun =
    case Lookup.moduleNameFor lookup node of
        Just moduleName ->
            List.any (\root -> isTopLayerModuleUnder root moduleName componentNoun) roots

        Nothing ->
            False


{-| The segments of a node's resolved module remaining after stripping the FIRST
matching namespace prefix among `roots` (`M3e.Token` under `[["M3e"]]` →
`Just ["Token"]`). Namespace-agnostic replacement for
`Maybe.andThen (dropPrefix root) (moduleNameFor …)` when several namespaces are
in play; the caller inspects the remainder's shape (`[]`, `["Token"]`, …).
-}
remainderUnder : List (List String) -> ModuleNameLookupTable -> Node Expression -> Maybe (List String)
remainderUnder roots lookup node =
    case Lookup.moduleNameFor lookup node of
        Just moduleName ->
            firstJust (\root -> dropPrefix root moduleName) roots

        Nothing ->
            Nothing


isTopLayerModuleUnder : List String -> ModuleName -> String -> Bool
isTopLayerModuleUnder root moduleName componentNoun =
    case dropPrefix root moduleName of
        Just [] ->
            True

        Just [ comp ] ->
            comp == capitalize componentNoun

        _ ->
            False


{-| The content-setter names of a component's NAMED slots — every `slotRewrites`
target whose source slot is not the default (`unnamed`/`default`). These are the
setters that place a child in a _named_ slot (e.g. `card`'s `header`/`actions`);
everything else in a content list is a raw default child.
-}
namedSlotSetters : Fact -> List String
namedSlotSetters fact =
    fact.slotRewrites
        |> List.filter (\( from, _ ) -> from /= "unnamed" && from /= "default")
        |> List.concatMap
            (\( from, perComponent ) ->
                -- Both facets: the per-component setter (`header`) AND the
                -- generic barrel setter (`slotHeader`) name the SAME named
                -- slot, so default-slot detection must exclude either form.
                perComponent
                    :: (barrelSlotSetter fact from
                            |> Maybe.map List.singleton
                            |> Maybe.withDefault []
                       )
            )


{-| Does a content-list element fill a component's DEFAULT (`unnamed`) slot?

In the top-layer idiom, raw default children live directly in the content list
(e.g. `SliderThumb.view …`, `ButtonSegment.view …`, a userland `Kit.text …`) —
they are NOT wrapped in a `<Comp>.child` setter. So an element fills the default
slot unless it is one of the component's own NAMED-slot setters (head name in
`namedSetters` AND resolving to the component's top-layer module). Every other
element — another component's `view`, a native element, a userland helper — is a
raw default child.

-}
fillsDefaultSlot : List (List String) -> ModuleNameLookupTable -> List String -> String -> Node Expression -> Bool
fillsDefaultSlot roots lookup namedSetters componentNoun element =
    let
        isNamedSetterHead node =
            case Node.value node of
                Expression.FunctionOrValue _ name ->
                    List.member name namedSetters
                        && isTopLayerModule roots lookup node componentNoun

                _ ->
                    False
    in
    case Node.value element of
        Expression.Application (setterNode :: _) ->
            not (isNamedSetterHead setterNode)

        Expression.FunctionOrValue _ _ ->
            not (isNamedSetterHead element)

        _ ->
            -- literals, parenthesized/other expressions: a raw default child
            True


{-| Build a namespace-qualified index (`factKey` → fact) from a facts list, so
components with the same noun in two libraries stay distinct.
-}
buildIndex : List Fact -> Dict String Fact
buildIndex facts =
    facts
        |> List.map (\f -> ( factKey f, f ))
        |> Dict.fromList


{-| Look up the fact a resolved call site names (matched namespace + noun).
-}
find : CallSite -> Dict String Fact -> Maybe Fact
find site index =
    Dict.get (siteKey site) index


{-| The result of tracing a list expression. `known` are the elements the
tracer could resolve statically; `unresolved` is `True` iff some parts of the
expression couldn't be traced (bare functions from other modules, opaque
`List.map` etc.).
-}
type alias TracedList =
    { known : List (Node Expression)
    , unresolved : Bool
    }


{-| Progressive list-content resolver.

Handles:

  - `[a, b, c]` → all elements, `unresolved = False`.
  - `[a] ++ [b]` → elements from both sides, `unresolved = False`.
  - `[a] ++ dynamic` → elements from literal side, `unresolved = True`.
  - `List.append a b` → equivalent to `++`.
  - `List.concat [[a], [b]]` → flattened elements.
  - `List.map f items` → 1 known (the setter/mapper head), `unresolved = True`.
  - `List.concatMap f items` → same as `List.map`.
  - `elem :: rest` → head element plus resolved tail.
  - `case x of { Branch -> [...] }` → union of all branch elements, `unresolved = True`.
  - `if cond then a else b` → union of both branch elements, `unresolved = True`.
  - Bare variable references resolved via the supplied `scope`.

Callers supply a `scope` dict mapping variable names to their bound
expressions (e.g. let bindings collected by a declaration visitor).

-}
tracedList : ModuleNameLookupTable -> Dict String (Node Expression) -> Node Expression -> TracedList
tracedList lookup scope node =
    tracedListWith lookup scope Dict.empty node


{-| Internal — `seen` accumulates variable names already being followed so a
cyclic reference (`x = y; y = x`) doesn't infinite-loop.
-}
tracedListWith :
    ModuleNameLookupTable
    -> Dict String (Node Expression)
    -> Dict String Bool
    -> Node Expression
    -> TracedList
tracedListWith lookup scope seen node =
    case Node.value node of
        Expression.ListExpr elements ->
            { known = elements, unresolved = False }

        Expression.OperatorApplication "++" _ left right ->
            concatTraced
                (tracedListWith lookup scope seen left)
                (tracedListWith lookup scope seen right)

        Expression.Application (fnNode :: args) ->
            resolveApp lookup scope seen fnNode args

        Expression.ParenthesizedExpression inner ->
            tracedListWith lookup scope seen inner

        Expression.OperatorApplication "::" _ head tail ->
            let
                tailTraced =
                    tracedListWith lookup scope seen tail
            in
            { known = head :: tailTraced.known
            , unresolved = tailTraced.unresolved
            }

        Expression.CaseExpression { cases } ->
            let
                branchTraces =
                    List.map (\( _, branchExpr ) -> tracedListWith lookup scope seen branchExpr) cases
            in
            { known = List.concatMap .known branchTraces
            , unresolved = True
            }

        Expression.IfBlock _ thenExpr elseExpr ->
            let
                thenTraced =
                    tracedListWith lookup scope seen thenExpr

                elseTraced =
                    tracedListWith lookup scope seen elseExpr
            in
            { known = thenTraced.known ++ elseTraced.known
            , unresolved = True
            }

        Expression.FunctionOrValue _ name ->
            if Dict.member name seen then
                { known = [], unresolved = True }

            else
                case Dict.get name scope of
                    Just referred ->
                        tracedListWith lookup scope (Dict.insert name True seen) referred

                    Nothing ->
                        { known = [], unresolved = True }

        _ ->
            { known = [], unresolved = True }


resolveApp :
    ModuleNameLookupTable
    -> Dict String (Node Expression)
    -> Dict String Bool
    -> Node Expression
    -> List (Node Expression)
    -> TracedList
resolveApp lookup scope seen fnNode args =
    case ( Node.value fnNode, Lookup.moduleNameFor lookup fnNode, args ) of
        ( Expression.FunctionOrValue _ "append", Just [ "List" ], [ a, b ] ) ->
            concatTraced
                (tracedListWith lookup scope seen a)
                (tracedListWith lookup scope seen b)

        ( Expression.FunctionOrValue _ "concat", Just [ "List" ], [ inner ] ) ->
            case Node.value inner of
                Expression.ListExpr parts ->
                    List.foldl
                        (\part acc ->
                            concatTraced acc (tracedListWith lookup scope seen part)
                        )
                        { known = [], unresolved = False }
                        parts

                _ ->
                    { known = [], unresolved = True }

        ( Expression.FunctionOrValue _ "map", Just [ "List" ], [ mapperNode, _ ] ) ->
            resolveListMapMapper mapperNode

        ( Expression.FunctionOrValue _ "concatMap", Just [ "List" ], [ mapperNode, _ ] ) ->
            resolveListMapMapper mapperNode

        _ ->
            { known = [], unresolved = True }


{-| Inspect the mapper argument of `List.map mapper items`.

Returns the "setter node" representing what each list element looks like, with
`unresolved = True` since we can't know how many items the list produces at
static analysis time.

Handles three mapper shapes:

  - `ContentPane.child` — bare function reference → the fnNode itself as known.
  - `\x -> Lib.child x` — lambda with single-Application body → the head of the
    Application is the setter.
  - `(navItem current)` — partial application → the outer Application node itself
    is the setter (we record it as one known element with `unresolved`).
  - Anything else → empty known, `unresolved = True`.

-}
resolveListMapMapper : Node Expression -> TracedList
resolveListMapMapper mapperNode =
    case Node.value mapperNode of
        Expression.FunctionOrValue _ _ ->
            { known = [ mapperNode ], unresolved = True }

        Expression.LambdaExpression lambda ->
            case Node.value lambda.expression of
                Expression.Application (setterNode :: _) ->
                    { known = [ setterNode ], unresolved = True }

                Expression.FunctionOrValue _ _ ->
                    { known = [], unresolved = True }

                _ ->
                    { known = [], unresolved = True }

        Expression.Application (headFn :: _) ->
            { known = [ headFn ], unresolved = True }

        Expression.ParenthesizedExpression inner ->
            resolveListMapMapper inner

        _ ->
            { known = [], unresolved = True }


concatTraced : TracedList -> TracedList -> TracedList
concatTraced a b =
    { known = a.known ++ b.known
    , unresolved = a.unresolved || b.unresolved
    }


{-| Convert a hyphenated string to camelCase (e.g. `"aria-label"` → `"ariaLabel"`).
-}
camelize : String -> String
camelize s =
    case String.split "-" s of
        [] ->
            s

        first :: rest ->
            first ++ String.concat (List.map capitalize rest)


{-| Uppercase the first character of a string.
-}
capitalize : String -> String
capitalize s =
    case String.uncons s of
        Just ( c, rest ) ->
            String.cons (Char.toUpper c) rest

        Nothing ->
            s


decapitalize : String -> String
decapitalize s =
    case String.uncons s of
        Just ( c, rest ) ->
            String.cons (Char.toLower c) rest

        Nothing ->
            s


{-| The flat barrel setter name for an attribute, given its per-component setter
name (`"disabled"` → `Just "attrDisabled"`, `"value"` → `Just "value"`), or
`Nothing` if the barrel does not re-expose one. Reads `fact.attrRewrites`
(barrel ↔ per-component, right-to-left) with the bare `value`/`name` scalar
fallback the barrel re-exposes unprefixed.

This is the exact mapping `PreferBarrel` rewrites _toward_, so any rule that
must recognise an attribute regardless of facet can accept both
`<root>.<Comp>.<perComponent>` and `<root>.<barrelName>`.

-}
attrBarrelName : Fact -> String -> Maybe String
attrBarrelName fact perComponentSetter =
    case
        fact.attrRewrites
            |> List.filter (\( _, perComp ) -> perComp == perComponentSetter)
            |> List.head
    of
        Just ( barrel, _ ) ->
            Just barrel

        Nothing ->
            case perComponentSetter of
                "value" ->
                    Just "value"

                "name" ->
                    Just "name"

                _ ->
                    Nothing


{-| The flat barrel setter name for a universal ARIA attribute, given the part
after the `aria-` prefix (`"label"` → `"ariaLabel"`). The barrel re-exposes each
`<root>.Aria.<x>` setter under this camel name, so it is the barrel-facet
satisfier for a required `aria-<x>` attribute.
-}
ariaBarrelName : String -> String
ariaBarrelName ariaSuffix =
    "aria" ++ capitalize ariaSuffix


{-| The generic barrel slot setter for a slot name (`"label"` →
`Just "slotLabel"`), by zipping the parallel `slotRewrites`/`slotUpgrades`
lists. This is the form `PreferBarrel` generalizes a per-component slot setter
to, so a rule can recognise a filled slot on the barrel facet. `Nothing` when
the slot has no upgrade entry.
-}
barrelSlotSetter : Fact -> String -> Maybe String
barrelSlotSetter fact slotName =
    List.map2 (\( slot, _ ) ( generic, _ ) -> ( slot, generic ))
        fact.slotRewrites
        fact.slotUpgrades
        |> List.filter (\( slot, _ ) -> slot == slotName)
        |> List.head
        |> Maybe.map Tuple.second
