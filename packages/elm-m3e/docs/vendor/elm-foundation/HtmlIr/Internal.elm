module HtmlIr.Internal exposing
    ( Element, Node, Attr, Value
    , fromNode, element
    , attribute, property, styles, on, fromHtmlAttribute, fromHtmlAttributes
    , none, recast
    , token
    , fromHtml
    , node, keyedNode, text, addAttribute, toHtml
    , isKeyed, toKeyedPair, key
    , lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8
    , addClass, attrIf, when, testId
    , tagOf, keysOf, childrenOf, classesOf
    , toNode, mapElement, mapNode, mapAttribute, toHtmlAttributes, toString
    )

{-| The **curated forge** of the intermediate representation — the single most
dangerous surface in the system. Read this module top to bottom before touching
anything; it is deliberately small so a human can audit it once.


# Trust model — read this first

Every type in this package is opaque and every _public_ module
([`HtmlIr.Element`](HtmlIr-Element), [`HtmlIr.Node`](HtmlIr-Node),
[`HtmlIr.Attribute`](HtmlIr-Attribute), [`HtmlIr.Value`](HtmlIr-Value)) exposes
only operations that **preserve or discard** phantom rows. This module is the
one place rows are **minted**: [`fromNode`](#fromNode) invents an `Element`'s
two rows, [`attribute`](#attribute)/[`property`](#property)/[`styles`](#styles)/
[`on`](#on)/[`fromHtmlAttribute`](#fromHtmlAttribute)/[`none`](#none) invent an
`Attr`'s capability row, [`recast`](#recast) replaces one, and
[`token`](#token) invents a `Value`'s tag row. Whoever imports this module can
assert any phantom claim about any content — including smuggling raw `Html`
(via [`fromHtml`](#fromHtml) then [`fromNode`](#fromNode)) into a slot that was
typed to accept only text.

Elm's `exposed-modules` gate is binary: this module must be exposed so that
_generated_ brand packages (which live in other packages) can build on the IR,
and once exposed, **any** consumer can import it. There is no
"generated-code-only" visibility in Elm and no compiler-sound alternative
(proven — see elm-cem#39 and the `/tmp/irpkg` attack cases). The trusted /
untrusted line is therefore held by exactly one thing:

> **The `NoInternalImportOutsideAllowed` rule in `jackhp95/elm-review-cem` is
> load-bearing.** A project that does not install it gets element↔attribute,
> enum, and nesting safety only for code that stays off this module; a project
> that installs it gets the full guarantee. Documentation must never claim
> "compiler-guaranteed" without this caveat.

Curation rules for this module (frozen at 1.0):

  - Functions and opaque types only — **no data constructors** are ever
    exposed, so the forge surface is exactly the functions listed here, not the
    representation.
  - **No userland-shaped conveniences.** Opinionated operations (slot
    placement, kind branding, coercion, event delegation) are compositions of
    these levers, built _above_ the IR by brand packages — see the composition
    table in the README. Generality-as-obscurity is the safety feature.


# Merge semantics

An `Attr` holds a **list** of facts, and `class` / `style` facts are structural
(inspectable) rather than pre-built. That is what lets a node's attribute list
**merge** instead of clobber:

    [ class "a", class "b" ]  -->  class="a b"
    [ style "color" "red", style "padding" "1px" ]
        -->  style="color:red;padding:1px"

elm/virtual-dom does this for `class` alone, hardcoded in its fact accumulator
(`_VirtualDom_organizeFacts`, `key === 'class'`), and cannot be extended to
`style` — two `style` attributes silently reduce to the last one. Merging here
covers both, and `style` gains what elm/html's kernel path cannot express:
CSS custom properties (`--x`, which `domNode.style[k] = v` ignores) and
`!important` (which CSSOM property setters drop).

The merge is total for facts minted here. Anything entering through
[`fromHtmlAttribute`](#fromHtmlAttribute) is an opaque `VirtualDom.Attribute`
that cannot be inspected, so a smuggled `Html.Attributes.class` lands in the
kernel's separate `className` bucket and still double-writes in authoring
order. Merge is exact for generated setters, best-effort across the escape.


# Types

@docs Element, Node, Attr, Value


# Element forge

@docs fromNode, element


# Attribute forge

@docs attribute, property, styles, on, fromHtmlAttribute, fromHtmlAttributes
@docs none, recast


# Value forge

@docs token


# Raw-Html escape

@docs fromHtml


# Safe operations (definition site)

These are re-exported by the public modules; they live here only because the
opaque representations do. None of them mint a row.

@docs node, keyedNode, text, addAttribute, toHtml
@docs isKeyed, toKeyedPair, key
@docs lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8


# Decorator combinators

Post-hoc rewrites over a typed `Element`, built on [`addAttribute`](#addAttribute).
Each preserves the element's phantom rows (`when`'s empty branch invents fresh
rows, as any producer does).

@docs addClass, attrIf, when, testId


# Structural-test accessors

`Node` is opaque, so tests cannot pattern-match it. These read-only accessors let
a suite assert IR structure (tag, keys, children, classes) without exposing the
representation.

@docs tagOf, keysOf, childrenOf, classesOf


# Message-map and unwrap

@docs toNode, mapElement, mapNode, mapAttribute, toHtmlAttributes, toString

-}

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Encode
import VirtualDom



-- TYPES


{-| A phantom-typed wrapper around a [`Node`](#Node), carrying **two** phantom
rows plus `msg`:

  - `accepts` — the kind row: which slot kinds this element produces /
    which child kinds a container's slot demands (parent → child).
  - `admittedBy` — the context row: which parent contexts this element
    declares itself valid inside (child → parent).

Composition unifies both edges: child-kind ⊆ parent-accepted-kinds AND
parent-context ∈ child-admittedBy. Producers keep `accepts` open and
`admittedBy` closed; containers demand a closed `accepts` on children and
inject an open demand for their own context into each child's `admittedBy`.
An **open** `admittedBy` on a producer means "valid anywhere" — enforcement
requires the closed row (proven: an open row unifies with any demand).

Neither row is ever inspected at runtime.

-}
type Element accepts admittedBy msg
    = Element (Node msg)


{-| The untyped intermediate tree every `Element` wraps: a tag node (name,
facts, children), a keyed tag node, a **keyed marker** wrapping a single node (a
child that has declared a diff key via [`key`](#key), lifted into a
`KeyedTag` by the parent's [`node`](#node) auto-upgrade), a text leaf, or a
raw-`Html` escape. Construction stays
structural — not pre-rendered `VirtualDom` — so the typed layers above can
rearrange, re-attribute, and message-map content before anything is rendered.

Tag nodes hold **unmerged facts**, not finished `VirtualDom.Attribute`s, so
that [`addAttribute`](#addAttribute) participates in the `class` / `style`
merge instead of appending a second, clobbering copy. Merging happens once, in
[`toHtml`](#toHtml).

-}
type Node msg
    = Tag String (List (Fact msg)) (List (Node msg))
    | KeyedTag String (List (Fact msg)) (List ( String, Node msg ))
    | Keyed String (Node msg)
    | Text String
    | Raw (Html msg)


{-| A phantom-typed attribute: a list of DOM-facing facts carrying a
`capability` row recording which element capabilities admit it
(`{ c | href : Supported }`, `{ c | onClick : Supported }`, …). Producers keep
the row open; an element constructor closes it. The row is never inspected at
runtime.

The list is what makes an **absent** attribute representable ([`none`](#none) is
`[]`, so a `False` boolean setter emits nothing at all rather than an inert
placeholder fact) and what lets one setter emit several facts — a property plus
its backing attributes, say.

-}
type Attr capability msg
    = Attr (List (Fact msg))


{-| One DOM-facing fact. `FReady` is a finished `VirtualDom.Attribute` that
streams through untouched; only `class` and `style` need to stay structural,
because they are the only two that merge. Keeping everything else pre-built is
load-bearing for performance — storing every attribute structurally and
rebuilding it during the merge measured 2.2–2.4× slower than passing it
through (see `bench/`).
-}
type Fact msg
    = FReady (VirtualDom.Attribute msg)
    | FClass String
    | FStyle (List ( String, String ))


{-| A phantom-tagged string token — the enum-value currency. A `Value tags`
carries an open row of the enum tags it represents (`{ v | filled : Supported }`);
a typed setter closes the row to the values its attribute admits.
-}
type Value tags
    = Value String



-- ELEMENT FORGE


{-| Wrap a `Node` as an `Element`, **inventing both phantom rows** — the caller
asserts any `accepts` kinds and any `admittedBy` contexts it likes. This is the
free assertion the whole fence exists for: combined with [`fromHtml`](#fromHtml)
it lets arbitrary `Html` claim to be anything (e.g. a `<script>` claiming to be
a text atom).

Legitimate callers: generated brand constructors (which pair it with an honest
closed row derived from config), and the brand-level escapes built on it
(`coerce`, slot placement).

-}
fromNode : Node msg -> Element accepts admittedBy msg
fromNode =
    Element


{-| Forge an `Element` straight from a tag name — [`node`](#node) fused with
[`fromNode`](#fromNode), so a custom element is a slot-ready `Element` in one call
instead of two. Like `fromNode` it **invents both phantom rows**, so the result
drops into any slot. Children are `Node`s (row-erased, hence freely mixable) — lift
an `Element` child with [`toNode`](#toNode).

For genuine web components / custom tags that have no generated brand constructor.

-}
element : String -> List (Attr capability msg) -> List (Node msg) -> Element accepts admittedBy msg
element tag attrs children =
    fromNode (node tag attrs children)



-- ATTRIBUTE FORGE


{-| Mint an `Attr` from a plain `name="value"` pair, **inventing its capability
row**. Generated setters pair this with an honest row (`href` claims
`{ c | href : Supported }`); a dishonest caller can claim anything.

`"class"` is routed to a structural fact so it merges (see _Merge semantics_).
`"style"` is **not**: splitting a raw declaration block would have to parse CSS,
and `;`/`:` occur inside `url(data:…)` values, so a style string set this way
clobbers rather than merges. Use [`styles`](#styles) for the merging form.

-}
attribute : String -> String -> Attr capability msg
attribute name value =
    if name == "class" then
        Attr [ FClass value ]

    else
        Attr [ FReady (Html.Attributes.attribute name value) ]


{-| Mint an `Attr` that sets a JavaScript **property** (not a content
attribute), inventing its capability row. This is the custom-elements workhorse:
rich values cross into a web component as properties.

Note the kernel rewrites the keys `innerHTML`, `outerHTML` and `formAction` to
`data-`-prefixed names, and blanks any string or array value that looks like a
`javascript:` / `data:text/html` URI (`_VirtualDom_noInnerHtmlOrFormAction`,
`_VirtualDom_noJavaScriptOrHtmlJson`). Neither is defeatable from Elm.

-}
property : String -> Json.Encode.Value -> Attr capability msg
property name value =
    Attr [ FReady (Html.Attributes.property name value) ]


{-| Mint an `Attr` from inline-style **declarations**, inventing its capability
row. Declarations merge across every setter on a node, last-wins per property,
in first-appearance order (see _Merge semantics_).

A `;` cannot appear in a property or value and a `:` cannot appear in a
property: either would let one declaration terminate itself and inject a
sibling the caller never wrote. Both are stripped, and declarations with an
empty property are dropped.

-}
styles : List ( String, String ) -> Attr capability msg
styles declarations =
    Attr [ FStyle declarations ]


{-| Mint an event-listener `Attr`, inventing its capability row. Generated
event setters pair this with an honest row (`onClick` claims
`{ c | onClick : Supported }`, closed by interactive elements only). For
handlers needing `stopPropagation`/`preventDefault`, wrap the corresponding
`Html.Events` constructor with [`fromHtmlAttribute`](#fromHtmlAttribute).
-}
on : String -> Json.Decode.Decoder msg -> Attr capability msg
on event decoder =
    Attr [ FReady (Html.Events.on event decoder) ]


{-| Wrap **any** `Html.Attribute` as an `Attr`, inventing its capability row —
the fully general attribute entry point. Covers everything the conveniences
above don't: custom event handlers, namespaced attributes.

The wrapped attribute is opaque, so it cannot participate in the `class` /
`style` merge — see _Merge semantics_.

-}
fromHtmlAttribute : Html.Attribute msg -> Attr capability msg
fromHtmlAttribute a =
    Attr [ FReady a ]


{-| [`fromHtmlAttribute`](#fromHtmlAttribute) for several attributes at once,
minting a single `Attr` that carries all of them. The multi-fact case the list
representation exists for: one typed setter standing in for a property plus its
backing attributes.
-}
fromHtmlAttributes : List (Html.Attribute msg) -> Attr capability msg
fromHtmlAttributes =
    Attr << List.map FReady


{-| The **absent** attribute — contributes nothing to the rendered element,
while still claiming a capability row so a `False` boolean setter can claim the
row its `True` branch claims.

This replaces the `Html.Attributes.style "" ""` idiom, which is a real `STYLE`
fact: visible to `Test.Html.Query`, and enough to force a style-bucket diff on
every node carrying a false boolean.

-}
none : Attr capability msg
none =
    Attr []


{-| Replace an `Attr`'s capability row, **inventing the new one** — the
capability-**forget** primitive, and how a brand implements its loud `delegate`
escape. Structural: no round-trip through `Html.Attribute`, so no fact is lost
even for a multi-fact `Attr`.
-}
recast : Attr aCapability msg -> Attr bCapability msg
recast (Attr facts) =
    Attr facts



-- VALUE FORGE


{-| Mint a `Value` from its string, **inventing its tag row**. Generated token
definitions pair this with an honest row (`filled = token "filled"` at
`{ v | filled : Supported }`); a dishonest caller can make `"garbage"` claim
any enum.
-}
token : String -> Value tags
token =
    Value



-- RAW-HTML ESCAPE


{-| Wrap raw `Html` as a `Node` — the point where untyped content enters the
IR. Inert on its own (a `Node` fits no typed slot), dangerous next to
[`fromNode`](#fromNode). Exists so the native brand can offer ONE loud,
greppable legacy-interop escape for incremental migration; nothing generated
should emit it on a normal path.
-}
fromHtml : Html msg -> Node msg
fromHtml =
    Raw



-- SAFE OPERATIONS (definition site)


{-| Build a tag node. Safe: the result is an untyped `Node`; only
[`fromNode`](#fromNode) can promote it to a typed `Element`. The attributes'
capability rows are erased here — they were checked when the caller's closed
attribute list unified.

**Auto-upgrade to keyed diffing.** If **any** child carries an explicit diff key
(a [`Keyed`](#Node) marker minted by [`key`](#key)), the whole child list is
promoted to a `KeyedTag`: keyed children keep their key, unkeyed children fall
back to `String.fromInt index` ([`toKeyedPair`](#toKeyedPair)). Mixing keyed and
unkeyed children is a documented code smell — it degrades to positional keys
rather than silently dropping the keying (see design decision D2). With no keyed
child the node stays a plain `Tag`, exactly as before.

-}
node : String -> List (Attr capability msg) -> List (Node msg) -> Node msg
node tag attrs children =
    if List.any isKeyed children then
        KeyedTag tag (factsOf attrs) (List.indexedMap toKeyedPair children)

    else
        Tag tag (factsOf attrs) children


{-| Whether a node carries an explicit diff key (a [`Keyed`](#Node) marker) —
the predicate that triggers [`node`](#node)'s keyed auto-upgrade.
-}
isKeyed : Node msg -> Bool
isKeyed n =
    case n of
        Keyed _ _ ->
            True

        _ ->
            False


{-| Pair a child with its diff key for a `KeyedTag`: the explicit key if the
child is a [`Keyed`](#Node) marker (unwrapping the marker), otherwise the
positional `String.fromInt index` fallback.
-}
toKeyedPair : Int -> Node msg -> ( String, Node msg )
toKeyedPair index n =
    case n of
        Keyed k inner ->
            ( k, inner )

        _ ->
            ( String.fromInt index, n )


{-| Build a tag node whose children carry diff keys (`VirtualDom.keyedNode`) —
for lists that reorder/insert/remove, where unkeyed diffing breaks animation
and state retention. Safe for the same reason as [`node`](#node).
-}
keyedNode : String -> List (Attr capability msg) -> List ( String, Node msg ) -> Node msg
keyedNode tag attrs children =
    KeyedTag tag (factsOf attrs) children


{-| Attach a diff key to a child `Element` — the child-level keying primitive
(design decision D1). The key rides along inside the container's normal,
phantom-checked children slot; the container's [`node`](#node) constructor spots
the [`Keyed`](#Node) marker and auto-upgrades the whole list to a `KeyedTag`.
Attaching the key to the child (rather than re-attaching children to the
container after the fact) keeps the container's "these children must be chips"
kind constraint intact.

Identity on both phantom rows: a keyed chip is still a chip.

    M3e.chipSet []
        [ M3e.chip [] [] |> key "1"
        , M3e.chip [] [] |> key "2"
        ]

-}
key : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg
key k (Element n) =
    Element (Keyed k n)


{-| A text leaf.
-}
text : String -> Node msg
text =
    Text


{-| Memoise a subtree: skip re-rendering while its inputs are referentially
unchanged (`VirtualDom.lazy`). Element-in / Element-out, so the result keeps its
phantom rows and drops into any slot — no `fromNode` lift, no leaked raw `Html`.

Memoisation compares the view function and each argument by **reference**, so
the view function **must be a stable top-level binding** and each argument a
stable reference; any per-render wrapper (an inline lambda, a packed
tuple/record) allocates fresh and silently never memoises. Exactly what
`elm/html`'s `lazy` requires.

The Element→Html bridge is threaded through a module-level `renderThunk` so it
stays stable across renders — a fresh `\a -> toHtml (viewFn a)` closure per
render would bust memoisation. The memo key is `(renderThunk, viewFn, arg)`, all
stable.

-}
lazy : (a -> Element accepts admittedBy msg) -> a -> Element accepts admittedBy msg
lazy viewFn a =
    fromNode (Raw (VirtualDom.lazy2 renderThunk viewFn a))


{-| [`lazy`](#lazy) for a two-argument view.
-}
lazy2 : (a -> b -> Element accepts admittedBy msg) -> a -> b -> Element accepts admittedBy msg
lazy2 viewFn a b =
    fromNode (Raw (VirtualDom.lazy3 renderThunk2 viewFn a b))


{-| [`lazy`](#lazy) for a three-argument view.
-}
lazy3 : (a -> b -> c -> Element accepts admittedBy msg) -> a -> b -> c -> Element accepts admittedBy msg
lazy3 viewFn a b c =
    fromNode (Raw (VirtualDom.lazy4 renderThunk3 viewFn a b c))


{-| [`lazy`](#lazy) for a four-argument view.
-}
lazy4 : (a -> b -> c -> d -> Element accepts admittedBy msg) -> a -> b -> c -> d -> Element accepts admittedBy msg
lazy4 viewFn a b c d =
    fromNode (Raw (VirtualDom.lazy5 renderThunk4 viewFn a b c d))


{-| [`lazy`](#lazy) for a five-argument view.
-}
lazy5 : (a -> b -> c -> d -> e -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> Element accepts admittedBy msg
lazy5 viewFn a b c d e =
    fromNode (Raw (VirtualDom.lazy6 renderThunk5 viewFn a b c d e))


{-| [`lazy`](#lazy) for a six-argument view.
-}
lazy6 : (a -> b -> c -> d -> e -> g -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> Element accepts admittedBy msg
lazy6 viewFn a b c d e g =
    fromNode (Raw (VirtualDom.lazy7 renderThunk6 viewFn a b c d e g))


{-| [`lazy`](#lazy) for a seven-argument view.
-}
lazy7 : (a -> b -> c -> d -> e -> g -> h -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> h -> Element accepts admittedBy msg
lazy7 viewFn a b c d e g h =
    fromNode (Raw (VirtualDom.lazy8 renderThunk7 viewFn a b c d e g h))


{-| [`lazy`](#lazy) for an eight-argument view — but **this variant does not
memoise at all**. It re-renders on every render, exactly as if you had not
wrapped the view.

The reason is structural. `VirtualDom.lazy8` has eight memo slots and compares
all of them by reference. This bridge must spend one slot on the stable
`renderThunk`, leaving only seven for data — but the view here takes eight data
arguments. To make the numbers fit, the eighth argument (`i`) is closed over in
a lambda that is allocated fresh on **every** render, and that lambda occupies
one of the compared slots. Because a freshly-allocated closure never matches the
previous render's reference, the memo check fails every time and the subtree is
always recomputed. There is no partial gating on the first seven arguments: one
mismatched slot forces a full recompute, so their values are irrelevant.

For real memoisation, pack the extra state into one of the first seven arguments
(for example a stable record) and use [`lazy7`](#lazy7). `lazy8` exists only to
keep the API surface complete; do not rely on it to skip work.

-}
lazy8 : (a -> b -> c -> d -> e -> g -> h -> i -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> h -> i -> Element accepts admittedBy msg
lazy8 viewFn a b c d e g h i =
    fromNode (Raw (VirtualDom.lazy8 renderThunk7 (\p q r s t u v -> viewFn p q r s t u v i) a b c d e g h))


{-| Stable Element→Html bridge for [`lazy`](#lazy). Module-level so its reference
is constant across renders — the load-bearing detail that keeps memoisation
alive.
-}
renderThunk : (a -> Element accepts admittedBy msg) -> a -> Html msg
renderThunk viewFn a =
    toHtml (toNode (viewFn a))


renderThunk2 : (a -> b -> Element accepts admittedBy msg) -> a -> b -> Html msg
renderThunk2 viewFn a b =
    toHtml (toNode (viewFn a b))


renderThunk3 : (a -> b -> c -> Element accepts admittedBy msg) -> a -> b -> c -> Html msg
renderThunk3 viewFn a b c =
    toHtml (toNode (viewFn a b c))


renderThunk4 : (a -> b -> c -> d -> Element accepts admittedBy msg) -> a -> b -> c -> d -> Html msg
renderThunk4 viewFn a b c d =
    toHtml (toNode (viewFn a b c d))


renderThunk5 : (a -> b -> c -> d -> e -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> Html msg
renderThunk5 viewFn a b c d e =
    toHtml (toNode (viewFn a b c d e))


renderThunk6 : (a -> b -> c -> d -> e -> g -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> Html msg
renderThunk6 viewFn a b c d e g =
    toHtml (toNode (viewFn a b c d e g))


renderThunk7 : (a -> b -> c -> d -> e -> g -> h -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> h -> Html msg
renderThunk7 viewFn a b c d e g h =
    toHtml (toNode (viewFn a b c d e g h))


{-| Prepend one attribute to a node. A `Text` or `Raw` leaf cannot carry an
attribute, so each is promoted to a `<span>` that holds it — the attribute is
never silently dropped (`text "x"` given `slot="s"` becomes
`<span slot="s">x</span>`).

An **absent** attribute ([`none`](#none)) is a no-op: it leaves a tag node
untouched and does not promote a leaf to a `<span>` to hold nothing.

A [`Keyed`](#Node) marker is transparent: the attribute is applied to the node
it wraps, so a keyed child keeps its diff key while gaining the attribute.

Prepending means lowest precedence, matching the kernel's last-wins rule for
duplicate names: a prepended `class` lands first in the merged list, and a
prepended `style` declaration is overridden by an existing one for the same
property.

-}
addAttribute : Attr capability msg -> Node msg -> Node msg
addAttribute (Attr facts) n =
    case facts of
        [] ->
            n

        _ ->
            case n of
                Tag tag existing children ->
                    Tag tag (facts ++ existing) children

                KeyedTag tag existing children ->
                    KeyedTag tag (facts ++ existing) children

                Keyed k inner ->
                    Keyed k (addAttribute (Attr facts) inner)

                Text s ->
                    Tag "span" facts [ Text s ]

                Raw h ->
                    Tag "span" facts [ Raw h ]


{-| Collapse a node tree to `Html` — the render boundary, and where the
`class` / `style` merge happens.
-}
toHtml : Node msg -> Html msg
toHtml n =
    case n of
        Tag tag facts children ->
            VirtualDom.node tag (mergeFacts facts) (List.map toHtml children)

        KeyedTag tag facts children ->
            VirtualDom.keyedNode tag (mergeFacts facts) (List.map (Tuple.mapSecond toHtml) children)

        Keyed _ inner ->
            toHtml inner

        Text s ->
            VirtualDom.text s

        Raw h ->
            h


{-| Unwrap an `Element` to its `Node`. Safe out-bound: rows are discarded,
never re-asserted.
-}
toNode : Element accepts admittedBy msg -> Node msg
toNode (Element n) =
    n


{-| Map an element's message type. Structural — rows and tree shape are
preserved (contrast the retired runtime, which rendered eagerly on map).
-}
mapElement : (a -> b) -> Element accepts admittedBy a -> Element accepts admittedBy b
mapElement f (Element n) =
    Element (mapNode f n)


{-| Map a node's message type, structurally: tag nodes map their facts and
recurse; `Raw` maps with `VirtualDom.map` (lazy in the virtual-dom). No branch
renders.
-}
mapNode : (a -> b) -> Node a -> Node b
mapNode f n =
    case n of
        Tag tag facts children ->
            Tag tag (List.map (mapFact f) facts) (List.map (mapNode f) children)

        KeyedTag tag facts children ->
            KeyedTag tag (List.map (mapFact f) facts) (List.map (Tuple.mapSecond (mapNode f)) children)

        Keyed k inner ->
            Keyed k (mapNode f inner)

        Text s ->
            Text s

        Raw h ->
            Raw (VirtualDom.map f h)


{-| Map an attribute's message type. Capability row preserved.
-}
mapAttribute : (a -> b) -> Attr capability a -> Attr capability b
mapAttribute f (Attr facts) =
    Attr (List.map (mapFact f) facts)


{-| Unwrap to the underlying `Html.Attribute`s — the safe out-bound direction.
A list because an `Attr` may carry none ([`none`](#none)) or several; `class` /
`style` facts within the one `Attr` are merged, exactly as they would be on a
node.
-}
toHtmlAttributes : Attr capability msg -> List (Html.Attribute msg)
toHtmlAttributes (Attr facts) =
    mergeFacts facts


{-| A value token's underlying string. Safe out-bound.
-}
toString : Value tags -> String
toString (Value s) =
    s



-- DECORATOR COMBINATORS


{-| Add a `class` to an element, participating in the `class` merge (see _Merge
semantics_). Phantom rows are preserved.
-}
addClass : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg
addClass name (Element n) =
    Element (addAttribute (attribute "class" name) n)


{-| Conditionally attach an attribute: apply it when the flag is `True`, leave
the element untouched when `False`. The `capability` row is fully polymorphic —
it never has to unify with the element's rows, because [`addAttribute`](#addAttribute)
erases it — so this threads generically for any `Attr`. Phantom rows preserved.

    button [] [ text "Submit" ]
        |> attrIf loading disabled

-}
attrIf : Bool -> Attr capability msg -> Element accepts admittedBy msg -> Element accepts admittedBy msg
attrIf cond attr (Element n) =
    if cond then
        Element (addAttribute attr n)

    else
        Element n


{-| Keep an element only when the flag is `True`; a `False` flag collapses it to
an **empty node** (`Text ""`), which renders nothing. The empty branch mints
fresh phantom rows (as any producer does), so it drops into the same slot the
kept element would.
-}
when : Bool -> Element accepts admittedBy msg -> Element accepts admittedBy msg
when cond el =
    if cond then
        el

    else
        Element (Text "")


{-| Stamp a `data-testid` attribute for structural / end-to-end test hooks.
Phantom rows preserved.
-}
testId : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg
testId value (Element n) =
    Element (addAttribute (attribute "data-testid" value) n)



-- STRUCTURAL-TEST ACCESSORS


{-| The tag name of a node, if it is a tag node (`Tag` or `KeyedTag`); `Nothing`
for a text leaf, raw escape, or bare [`Keyed`](#Node) marker (unwrap the marker
first). For asserting IR structure in tests without exposing the representation.
-}
tagOf : Node msg -> Maybe String
tagOf n =
    case n of
        Tag tag _ _ ->
            Just tag

        KeyedTag tag _ _ ->
            Just tag

        Keyed _ inner ->
            tagOf inner

        Text _ ->
            Nothing

        Raw _ ->
            Nothing


{-| The diff keys of a node's children, in order — non-empty only for a
`KeyedTag` (the shape [`node`](#node) auto-upgrades to). `[]` for any other node.
Lets a suite assert `keysOf (toNode view) == [ "1", "2" ]`.
-}
keysOf : Node msg -> List String
keysOf n =
    case n of
        KeyedTag _ _ children ->
            List.map Tuple.first children

        Keyed _ inner ->
            keysOf inner

        _ ->
            []


{-| The children of a node, in order — with any keys stripped, so a `KeyedTag`'s
children come back as bare nodes. `[]` for a leaf or raw escape.
-}
childrenOf : Node msg -> List (Node msg)
childrenOf n =
    case n of
        Tag _ _ children ->
            children

        KeyedTag _ _ children ->
            List.map Tuple.second children

        Keyed _ inner ->
            childrenOf inner

        Text _ ->
            []

        Raw _ ->
            []


{-| The `class` names on a node, in authoring order — reading the structural
`FClass` facts before the merge. `[]` for a leaf, raw escape, or a node with no
class facts.
-}
classesOf : Node msg -> List String
classesOf n =
    case n of
        Tag _ facts _ ->
            classNamesOf facts

        KeyedTag _ facts _ ->
            classNamesOf facts

        Keyed _ inner ->
            classesOf inner

        Text _ ->
            []

        Raw _ ->
            []


classNamesOf : List (Fact msg) -> List String
classNamesOf facts =
    List.filterMap
        (\fact ->
            case fact of
                FClass c ->
                    Just c

                _ ->
                    Nothing
        )
        facts



-- MERGE (internal)


{-| Flatten a closed attribute list to facts, erasing capability rows.

A single `foldr` rather than `List.concatMap`, which elm/core defines as
`concat (map f list)` — two passes and an intermediate list of lists, on a path
that runs once per node per render.

-}
factsOf : List (Attr capability msg) -> List (Fact msg)
factsOf =
    List.foldr (\(Attr facts) acc -> facts ++ acc) []


mapFact : (a -> b) -> Fact a -> Fact b
mapFact f fact =
    case fact of
        FReady a ->
            FReady (VirtualDom.mapAttribute f a)

        FClass c ->
            FClass c

        FStyle ds ->
            FStyle ds


{-| Render facts to attributes, merging `class` and `style`.

Every other name needs no merge pass here: the kernel's accumulator already
resolves duplicates by last-wins (`subFacts[key] = value`), so ready facts
stream through in order and only the two mergeable kinds are accumulated.

Deliberately unconditional. A pre-scan that skips accumulation when a node has
no duplicate `class`/`style` measured _slower_ than always merging — in both an
allocating and an allocation-free form — because the scan costs more than the
work it avoids.

-}
mergeFacts : List (Fact msg) -> List (VirtualDom.Attribute msg)
mergeFacts facts =
    let
        step fact ( ready, classes, declarations ) =
            case fact of
                FReady a ->
                    ( a :: ready, classes, declarations )

                FClass c ->
                    ( ready
                    , if String.isEmpty c then
                        classes

                      else
                        c :: classes
                    , declarations
                    )

                FStyle ds ->
                    ( ready
                    , classes
                    , List.foldl addDeclaration declarations ds
                    )

        ( readyRev, classesRev, declarations_ ) =
            List.foldl step ( [], [], [] ) facts
    in
    -- readyRev is reversed by the accumulating fold; re-reversing it onto the
    -- merged tail restores authoring order in a single pass.
    List.foldl (::) (classAttribute classesRev ++ styleAttribute declarations_) readyRev


{-| Last-wins per property, keeping first-appearance position so the emitted
declaration block is stable across renders — a reordered `style` string would
cost a spurious `setAttribute` on every diff.

An assoc list rather than a `Dict`: at realistic declaration counts it measured
equal or faster, and it avoids allocating red-black tree nodes per insert.

-}
upsert : ( String, String ) -> List ( String, String ) -> List ( String, String )
upsert ( propKey, value ) declarations =
    case declarations of
        [] ->
            [ ( propKey, value ) ]

        (( existingKey, _ ) as head) :: rest ->
            if existingKey == propKey then
                ( propKey, value ) :: rest

            else
                head :: upsert ( propKey, value ) rest


{-| Scrub, then [`upsert`](#upsert) — fused so a rejected declaration costs no
`Maybe` and the accepted ones cost no intermediate list.

`String.filter` builds a fresh string character by character, which is far too
expensive to run unconditionally on every declaration of every node on every
render (it measured as the single largest cost in the merge). `String.contains`
is a native `indexOf`, so the common case — nothing to strip — pays three cheap
scans and allocates nothing.

-}
addDeclaration : ( String, String ) -> List ( String, String ) -> List ( String, String )
addDeclaration ( propKey, value ) declarations =
    let
        key_ =
            if String.contains ";" propKey || String.contains ":" propKey then
                String.filter (\c -> c /= ';' && c /= ':') propKey

            else
                propKey
    in
    if String.isEmpty key_ then
        declarations

    else
        upsert
            ( key_
            , if String.contains ";" value then
                String.filter (\c -> c /= ';') value

              else
                value
            )
            declarations


classAttribute : List String -> List (VirtualDom.Attribute msg)
classAttribute classesRev =
    case classesRev of
        [] ->
            []

        [ only ] ->
            [ Html.Attributes.attribute "class" only ]

        many ->
            [ Html.Attributes.attribute "class" (String.join " " (List.reverse many)) ]


styleAttribute : List ( String, String ) -> List (VirtualDom.Attribute msg)
styleAttribute declarations =
    case declarations of
        [] ->
            []

        _ ->
            [ Html.Attributes.attribute "style"
                (String.join ";" (List.map (\( propKey, value ) -> propKey ++ ":" ++ value) declarations))
            ]
