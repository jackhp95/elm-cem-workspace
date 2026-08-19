module HtmlIr.Element exposing
    ( Element
    , key
    , lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8
    , addClass, attrIf, when, testId
    , toNode, map
    )

{-| The phantom-typed element every library on this substrate shares. An
`Element accepts admittedBy msg` is a piece of renderable content whose two
phantom rows record, respectively, which slot kinds it may occupy
(`accepts`, parent → child) and which parent contexts it is valid inside
(`admittedBy`, child → parent). Because every brand package (native HTML, any
generated design system) produces this **same** type, their content nests
without conversion; the rows are what let the compiler reject a child in a slot
that does not admit it, or an element under a parent it does not allow.

This module is the safe surface: constructing an `Element` — which asserts its
rows — is only possible through a brand's typed constructors or the fenced
forge in [`HtmlIr.Internal`](HtmlIr-Internal) (see its trust-model note).

@docs Element


# Diff keys

@docs key


# Lazy (memoised) subtrees

@docs lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8


# Decorators

@docs addClass, attrIf, when, testId


# Unwrap and map

@docs toNode, map

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as I
import HtmlIr.Node exposing (Node)


{-| The opaque two-row phantom element. Rows are never inspected at runtime.
-}
type alias Element accepts admittedBy msg =
    I.Element accepts admittedBy msg


{-| Unwrap to the underlying untyped [`Node`](HtmlIr-Node#Node) — the safe
out-bound direction (rows are discarded, never re-asserted). Render it with
[`HtmlIr.Node.toHtml`](HtmlIr-Node#toHtml).
-}
toNode : Element accepts admittedBy msg -> Node msg
toNode =
    I.toNode


{-| Map the message type. Structural: the tree is not rendered, rows and
rearrangeability are preserved.
-}
map : (a -> b) -> Element accepts admittedBy a -> Element accepts admittedBy b
map =
    I.mapElement


{-| Attach a diff key to a child so its parent container renders as a keyed node
(state / animation survive reorders). Identity on both phantom rows — a keyed
chip is still a chip.

    chipSet []
        [ chip [] [] |> key "1"
        , chip [] [] |> key "2"
        ]

-}
key : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg
key =
    I.key


{-| Memoise a subtree while its inputs are referentially unchanged. Element-in /
Element-out: the result keeps its phantom rows and drops into any slot. The view
function **must be a stable top-level binding** and each argument a stable
reference, or it silently never memoises.
-}
lazy : (a -> Element accepts admittedBy msg) -> a -> Element accepts admittedBy msg
lazy =
    I.lazy


{-| [`lazy`](#lazy) for a two-argument view.
-}
lazy2 : (a -> b -> Element accepts admittedBy msg) -> a -> b -> Element accepts admittedBy msg
lazy2 =
    I.lazy2


{-| [`lazy`](#lazy) for a three-argument view.
-}
lazy3 : (a -> b -> c -> Element accepts admittedBy msg) -> a -> b -> c -> Element accepts admittedBy msg
lazy3 =
    I.lazy3


{-| [`lazy`](#lazy) for a four-argument view.
-}
lazy4 : (a -> b -> c -> d -> Element accepts admittedBy msg) -> a -> b -> c -> d -> Element accepts admittedBy msg
lazy4 =
    I.lazy4


{-| [`lazy`](#lazy) for a five-argument view.
-}
lazy5 : (a -> b -> c -> d -> e -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> Element accepts admittedBy msg
lazy5 =
    I.lazy5


{-| [`lazy`](#lazy) for a six-argument view.
-}
lazy6 : (a -> b -> c -> d -> e -> g -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> Element accepts admittedBy msg
lazy6 =
    I.lazy6


{-| [`lazy`](#lazy) for a seven-argument view.
-}
lazy7 : (a -> b -> c -> d -> e -> g -> h -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> h -> Element accepts admittedBy msg
lazy7 =
    I.lazy7


{-| [`lazy`](#lazy) for an eight-argument view — but this variant **does not
memoise**; it re-renders every time. The Element→Html bridge only has room for
seven memoised data arguments, so the eighth forces a fresh closure each render
and defeats the reference check. For real memoisation, fold the extra state into
one of the first seven arguments and use [`lazy7`](#lazy7). Details in
[`HtmlIr.Internal.lazy8`](HtmlIr-Internal#lazy8).
-}
lazy8 : (a -> b -> c -> d -> e -> g -> h -> i -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> h -> i -> Element accepts admittedBy msg
lazy8 =
    I.lazy8


{-| Add a `class`, participating in the `class` merge. Phantom rows preserved.
-}
addClass : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg
addClass =
    I.addClass


{-| Conditionally attach an attribute — applied when the flag is `True`, a no-op
when `False`. Phantom rows preserved.
-}
attrIf : Bool -> Attr capability msg -> Element accepts admittedBy msg -> Element accepts admittedBy msg
attrIf =
    I.attrIf


{-| Keep an element only when the flag is `True`; `False` collapses it to an
empty node that renders nothing.
-}
when : Bool -> Element accepts admittedBy msg -> Element accepts admittedBy msg
when =
    I.when


{-| Stamp a `data-testid` for test hooks. Phantom rows preserved.
-}
testId : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg
testId =
    I.testId
