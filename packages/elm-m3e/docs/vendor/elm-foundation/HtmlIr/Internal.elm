module HtmlIr.Internal exposing
    ( Element, Node, Attr, Value
    , fromNode, element
    , attribute, property, styles, on, fromHtmlAttribute, fromHtmlAttributes
    , none, recast
    , token
    , fromHtml
    , node, keyedNode, text, addAttribute, toHtml
    , lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8
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
@docs lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8
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
facts, children), a text leaf, or a raw-`Html` escape. Construction stays
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
-}
node : String -> List (Attr capability msg) -> List (Node msg) -> Node msg
node tag attrs children =
    Tag tag (factsOf attrs) children


{-| Build a tag node whose children carry diff keys (`VirtualDom.keyedNode`) —
for lists that reorder/insert/remove, where unkeyed diffing breaks animation
and state retention. Safe for the same reason as [`node`](#node).
-}
keyedNode : String -> List (Attr capability msg) -> List ( String, Node msg ) -> Node msg
keyedNode tag attrs children =
    KeyedTag tag (factsOf attrs) children


{-| A text leaf.
-}
text : String -> Node msg
text =
    Text


{-| Memoise a subtree: skip re-rendering while its inputs are referentially
unchanged (`VirtualDom.lazy`). The body returns raw `Html`, not an `Element` —
a typed subtree is `\model -> HtmlIr.Element.toHtml (myView model)` — because
memoisation compares the function and each argument by **reference**; any
per-render wrapper (an inline lambda, a packed tuple/record) allocates fresh and
silently never memoises. So the body **must be a stable top-level function** and
each argument a stable reference — exactly what `elm/html`'s `lazy` requires.
Lift the result into a slot with [`fromNode`](#fromNode). Safe: mints no row.
-}
lazy : (a -> Html msg) -> a -> Node msg
lazy f a =
    Raw (VirtualDom.lazy f a)


{-| [`lazy`](#lazy) for a two-argument view.
-}
lazy2 : (a -> b -> Html msg) -> a -> b -> Node msg
lazy2 f a b =
    Raw (VirtualDom.lazy2 f a b)


{-| [`lazy`](#lazy) for a three-argument view.
-}
lazy3 : (a -> b -> c -> Html msg) -> a -> b -> c -> Node msg
lazy3 f a b c =
    Raw (VirtualDom.lazy3 f a b c)


{-| [`lazy`](#lazy) for a four-argument view.
-}
lazy4 : (a -> b -> c -> d -> Html msg) -> a -> b -> c -> d -> Node msg
lazy4 f a b c d =
    Raw (VirtualDom.lazy4 f a b c d)


{-| [`lazy`](#lazy) for a five-argument view.
-}
lazy5 : (a -> b -> c -> d -> e -> Html msg) -> a -> b -> c -> d -> e -> Node msg
lazy5 f a b c d e =
    Raw (VirtualDom.lazy5 f a b c d e)


{-| [`lazy`](#lazy) for a six-argument view.
-}
lazy6 : (a -> b -> c -> d -> e -> g -> Html msg) -> a -> b -> c -> d -> e -> g -> Node msg
lazy6 f a b c d e g =
    Raw (VirtualDom.lazy6 f a b c d e g)


{-| [`lazy`](#lazy) for a seven-argument view.
-}
lazy7 : (a -> b -> c -> d -> e -> g -> h -> Html msg) -> a -> b -> c -> d -> e -> g -> h -> Node msg
lazy7 f a b c d e g h =
    Raw (VirtualDom.lazy7 f a b c d e g h)


{-| [`lazy`](#lazy) for an eight-argument view.
-}
lazy8 : (a -> b -> c -> d -> e -> g -> h -> i -> Html msg) -> a -> b -> c -> d -> e -> g -> h -> i -> Node msg
lazy8 f a b c d e g h i =
    Raw (VirtualDom.lazy8 f a b c d e g h i)


{-| Prepend one attribute to a node. A `Text` or `Raw` leaf cannot carry an
attribute, so each is promoted to a `<span>` that holds it — the attribute is
never silently dropped (`text "x"` given `slot="s"` becomes
`<span slot="s">x</span>`).

An **absent** attribute ([`none`](#none)) is a no-op: it leaves a tag node
untouched and does not promote a leaf to a `<span>` to hold nothing.

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
upsert ( key, value ) declarations =
    case declarations of
        [] ->
            [ ( key, value ) ]

        (( existingKey, _ ) as head) :: rest ->
            if existingKey == key then
                ( key, value ) :: rest

            else
                head :: upsert ( key, value ) rest


{-| Scrub, then [`upsert`](#upsert) — fused so a rejected declaration costs no
`Maybe` and the accepted ones cost no intermediate list.

`String.filter` builds a fresh string character by character, which is far too
expensive to run unconditionally on every declaration of every node on every
render (it measured as the single largest cost in the merge). `String.contains`
is a native `indexOf`, so the common case — nothing to strip — pays three cheap
scans and allocates nothing.

-}
addDeclaration : ( String, String ) -> List ( String, String ) -> List ( String, String )
addDeclaration ( key, value ) declarations =
    let
        key_ =
            if String.contains ";" key || String.contains ":" key then
                String.filter (\c -> c /= ';' && c /= ':') key

            else
                key
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
                (String.join ";" (List.map (\( key, value ) -> key ++ ":" ++ value) declarations))
            ]
