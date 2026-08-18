module Cem.Internal.Facts exposing
    ( CallSite, callSite
    , buildIndex, find
    , TracedList, tracedList
    , camelize, capitalize
    , rootParts, namespaces, barrelNamespaceParts, barrelRootParts, barrelRoot, hasRecordFormConstructor, factNamespaceParts, factNamespace, factComponentSegment, htmlTagOf, safeValue
    , factKey, siteKey
    , isTopLayerModule, dropPrefix, remainderUnder
    , namedSlotSetters, fillsDefaultSlot
    , attrBarrelName, ariaBarrelName, barrelSlotSetter
    , resolveRecordFields
    , decapitalize
    )

{-| Shared helpers for the codegen-aware rules that consume `Cem.Facts`.

Everything here is namespace-agnostic: the library's root namespace is derived
from a fact's `module_` field (e.g. `"Lib.Button"` → `["Lib"]`), never
hardcoded. Rules pass the derived `rootParts` into `callSite` / `isTopLayerModule`.

@docs CallSite, callSite
@docs buildIndex, find
@docs TracedList, tracedList
@docs camelize, capitalize
@docs rootParts, namespaces, barrelNamespaceParts, barrelRootParts, barrelRoot, hasRecordFormConstructor, factNamespaceParts, factNamespace, factComponentSegment, htmlTagOf, safeValue
@docs factKey, siteKey
@docs isTopLayerModule, dropPrefix, remainderUnder
@docs namedSlotSetters, fillsDefaultSlot
@docs attrBarrelName, ariaBarrelName, barrelSlotSetter
@docs resolveRecordFields

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


{-| Every DISTINCT namespace present in the facts, in first-seen order
(`M3e.Button … ++ TypedHtml.Div …` → `[ ["M3e"], ["TypedHtml"] ]`). This is what
rules resolve call sites against, so concatenated multi-library facts each take
effect instead of only the first library's.

When a component module lives under an intermediate sub-namespace (e.g.
`M3e.Component.Button` → namespace `["M3e", "Component"]`), the barrel functions
(`M3e.toHtml`, `M3e.iconButton`, `M3e.Unsafe.*`) live at the root (`["M3e"]`).
Both must be included so call-site resolution handles barrel calls AND per-component
calls. `barrelNamespaceParts` derives the barrel root generically: any namespace
with two or more segments has an intermediate, and the barrel root is all-but-last.
This handles ANY future intermediate segment without code changes here.

-}
namespaces : List Fact -> List (List String)
namespaces facts =
    List.foldl
        (\fact acc ->
            let
                ns =
                    factNamespaceParts fact

                barrel =
                    barrelNamespaceParts ns

                acc1 =
                    if List.member ns acc then
                        acc

                    else
                        acc ++ [ ns ]
            in
            case barrel of
                Just barrelNs ->
                    if List.member barrelNs acc1 then
                        acc1

                    else
                        -- Barrel root goes FIRST: barrel calls are resolved
                        -- before per-component calls, matching firstJust order.
                        barrelNs :: acc1

                Nothing ->
                    acc1
        )
        []
        facts


{-| When a component namespace has MORE than one segment, return all-but-last
as the barrel root namespace. `["M3e", "Component"]` → `Just ["M3e"]`.
Single-segment namespaces (`["M3e"]`) return `Nothing` — they are already
at the root, no intermediate segment exists.

**Design choice — pragmatic single-brand-root assumption:** every brand
supported by elm-cem has a SINGLE-segment root (`"M3e"`, `"TypedHtml"`,
`"HtmlIr"`, etc.). An intermediate segment always occupies exactly ONE
position between the brand root and the component leaf. Therefore,
`dropLast ns` when `List.length ns >= 2` correctly yields the barrel root.
This avoids hardcoding individual segment names (`"Component"`, `"Build"`)
so any FUTURE intermediate segment (e.g. `"Layout"`, `"Overlay"`) is
handled automatically without code changes here.

If a hypothetical brand ever used a multi-segment root (e.g. `My.Lib.Button`
with no intermediate → namespace `["My","Lib"]`), this would WRONGLY derive
`["My"]` as a barrel root. That case doesn't exist today; the
`RealFactsShapeTest` meta-guard will catch it if the assumption is ever
violated by a future facts shape.

-}
barrelNamespaceParts : List String -> Maybe (List String)
barrelNamespaceParts ns =
    case ns of
        _ :: _ :: _ ->
            -- At least two segments → intermediate exists; barrel root = all-but-last.
            Just (dropLast ns)

        _ ->
            -- Zero or one segment → already at root, no intermediate.
            Nothing


{-| The BARREL ROOT namespace parts for a single fact — the namespace where the
flat barrel (`Lib.button`, `Lib.attrDisabled`, `Lib.slotDefault`) lives.

For a single-package shape (`module_ = "Lib.Button"` → namespace `["Lib"]`) the
barrel is already at the namespace root, so this is just `["Lib"]`. For a
four-package shape with an intermediate segment (`module_ = "Lib.Component.Button"`
→ namespace `["Lib", "Component"]`) the barrel lives one level UP, at `["Lib"]` —
so `barrelNamespaceParts` strips the intermediate. Rules that compute a flat
barrel replacement MUST use this, not `factNamespaceParts`/`factNamespace`, or
they emit `Lib.Component.button` (a module that does not exist) instead of the real
barrel `Lib.button`.

-}
barrelRootParts : Fact -> List String
barrelRootParts fact =
    let
        ns =
            factNamespaceParts fact
    in
    barrelNamespaceParts ns
        |> Maybe.withDefault ns


{-| The flat barrel root a fact's replacements target, dotted (`"Lib"`), NOT the
fact's own namespace (`"Lib.Component"`). In a four-package shape the per-component
modules live under an intermediate segment (`Lib.Component.Button`) while the flat
barrel (`Lib.button`, `Lib.Aria`, `Lib.Token`) lives one level up at the root;
`barrelRootParts` strips that intermediate. Using `factNamespace` where a barrel
root is meant is the bug that made both barrel-autofix rules emit the nonexistent
`Lib.Component.button` / `Lib.Component.Aria` — see the two rules' constructor and
aria/token branches.
-}
barrelRoot : Fact -> String
barrelRoot fact =
    String.join "." (barrelRootParts fact)


{-| Does this component's `component` constructor take a required-fields RECORD as
its first argument (the record-form smart ctor), rather than being the plain
`attrs -> children` loose producer?

In the four-package shape the canonical `<root>.Component.<X>.component` is a
record-form smart ctor (`{ content, ariaLabel, action } -> attrs -> children -> …`)
whenever the component has required content, required attributes, or an action —
and it is NOT the same function as the loose barrel producer `<root>.<x>`
(`attrs -> children`). The two barrel-autofix rules are exact inverses, and BOTH
must treat this pair asymmetrically: `PreferBarrel` must not flatten the
record-form ctor to the loose producer, and `PreferComponentModules` must not
specialise the loose barrel producer to the record-form ctor — either rewrite is
a type error. Only when the component has NO required fields does `component`
coincide with the loose producer (`Lib.Component.Icon.component = Lib.icon`), and
only then is the rewrite signature-preserving and worth suggesting.

-}
hasRecordFormConstructor : Fact -> Bool
hasRecordFormConstructor fact =
    not (List.isEmpty fact.requiredSlots)
        || not (List.isEmpty fact.requiredAttrs)
        || fact.usesAction


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

  - `Lib.Component.Button.component` → `{ noun = "button", facet = Standard, namespace = ["Lib"] }`
  - `Lib.button` (barrel Html producer) → `{ noun = "button", facet = Standard, … }`

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
            -- The per-component constructor is the module's single `component`
            -- ctor (`Lib.Component.Button.component`), two-arity: a leading
            -- required-content record iff the component has required pieces,
            -- bare `component attrs children` otherwise. One name across every
            -- component module (the elm-cem four-package generator emits exactly
            -- `component`).
            if name == "component" then
                Just { noun = decapitalize comp, facet = Standard, namespace = root }

            else
                Nothing

        Just [ "Record", comp ] ->
            if name == "component" then
                Just { noun = decapitalize comp, facet = Record, namespace = root }

            else
                Nothing

        _ ->
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
(e.g. `SliderThumb.component …`, `ButtonSegment.component …`, a userland `Kit.text …`) —
they are NOT wrapped in a `<Comp>.child` setter. So an element fills the default
slot unless it is one of the component's own NAMED-slot setters (head name in
`namedSetters` AND resolving to the component's top-layer module). Every other
element — another component's `component`, a native element, a userland helper — is a
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

When a component namespace has a barrel root (e.g. `["M3e","Component"]` →
barrel `["M3e"]`), the fact is also indexed under the barrel key so that barrel
call sites (`M3e.iconButton`, resolved via namespace `["M3e"]`) find the right
fact. Both keys point at the same fact — the canonical entry is the `factKey`
one; the barrel key is an alias.

-}
buildIndex : List Fact -> Dict String Fact
buildIndex facts =
    facts
        |> List.concatMap
            (\f ->
                let
                    ns =
                        factNamespaceParts f

                    canonical =
                        ( factKey f, f )
                in
                case barrelNamespaceParts ns of
                    Just barrelNs ->
                        let
                            barrelKey =
                                String.join "." barrelNs ++ "\u{0000}" ++ f.component
                        in
                        [ canonical, ( barrelKey, f ) ]

                    Nothing ->
                        [ canonical ]
            )
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


{-| Lowercase the first character of a string.
-}
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


{-| Resolve a call argument to the field-name -> value-expression map of the
record LITERAL it statically is, following simple let-bound variable
references (with cycle protection) the same way `tracedList` follows
list-valued ones. Returns `Nothing` for anything else (a function call, a
piped/point-free argument, an unbound or external variable) — callers should
stay silent (advisory posture) rather than false-positive on those.

In the four-package shape, every required slot (singular or the repeatable
default slot) is threaded through the `component` ctor's leading record — a rule that wants to
know what content a call statically provides for a given field must resolve
this record, not just the trailing content-list argument.

-}
resolveRecordFields : Dict String (Node Expression) -> Node Expression -> Maybe (Dict String (Node Expression))
resolveRecordFields scope node =
    resolveRecordFieldsWith scope Dict.empty node


resolveRecordFieldsWith : Dict String (Node Expression) -> Dict String Bool -> Node Expression -> Maybe (Dict String (Node Expression))
resolveRecordFieldsWith scope seen node =
    case Node.value node of
        Expression.RecordExpr setters ->
            setters
                |> List.map
                    (\setter ->
                        let
                            ( nameNode, valueNode ) =
                                Node.value setter
                        in
                        ( Node.value nameNode, valueNode )
                    )
                |> Dict.fromList
                |> Just

        Expression.ParenthesizedExpression inner ->
            resolveRecordFieldsWith scope seen inner

        Expression.FunctionOrValue [] name ->
            if Dict.member name seen then
                Nothing

            else
                Dict.get name scope
                    |> Maybe.andThen (resolveRecordFieldsWith scope (Dict.insert name True seen))

        _ ->
            Nothing
