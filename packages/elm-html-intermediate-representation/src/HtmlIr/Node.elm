module HtmlIr.Node exposing
    ( Node
    , node, keyedNode, text
    , lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8
    , addAttribute, map
    , toHtml
    )

{-| The untyped intermediate tree every [`Element`](HtmlIr-Element#Element)
wraps. A `Node` is a tag node, a text leaf, or a raw-`Html` escape (the escape
constructor is fenced in [`HtmlIr.Internal`](HtmlIr-Internal)). Construction is
structural rather than pre-rendered, so typed layers can rearrange and
re-attribute content before [`toHtml`](#toHtml) collapses it at the render
boundary.

Everything here is safe: a bare `Node` carries no phantom claims and fits no
typed slot — only the fenced `HtmlIr.Internal.fromNode` can promote one to an
`Element`.

@docs Node
@docs node, keyedNode, text
@docs lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8
@docs addAttribute, map
@docs toHtml

-}

import Html exposing (Html)
import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as I


{-| The opaque untyped IR node.
-}
type alias Node msg =
    I.Node msg


{-| Build a tag node from a tag name, attributes, and children — the general
constructor behind every element (native tags and custom elements alike). The
attributes' capability rows are erased; they were checked where the caller's
typed attribute list unified.
-}
node : String -> List (Attr capability msg) -> List (Node msg) -> Node msg
node =
    I.node


{-| Build a tag node whose children carry diff keys (`VirtualDom.keyedNode`) —
for lists that reorder/insert/remove, where unkeyed diffing breaks animation
and state retention.
-}
keyedNode : String -> List (Attr capability msg) -> List ( String, Node msg ) -> Node msg
keyedNode =
    I.keyedNode


{-| A text leaf.
-}
text : String -> Node msg
text =
    I.text


{-| Memoise a subtree while its inputs are referentially unchanged. The body
returns raw `Html` — a typed subtree is `\model -> HtmlIr.Element.toHtml (myView
model)` — and **must be a stable top-level function** with stable arguments, or
it silently never memoises (see [`HtmlIr.Internal.lazy`](HtmlIr-Internal#lazy)).
Lift the result into a slot with `HtmlIr.Internal.fromNode`.
-}
lazy : (a -> Html msg) -> a -> Node msg
lazy =
    I.lazy


{-| [`lazy`](#lazy) for a two-argument view.
-}
lazy2 : (a -> b -> Html msg) -> a -> b -> Node msg
lazy2 =
    I.lazy2


{-| [`lazy`](#lazy) for a three-argument view.
-}
lazy3 : (a -> b -> c -> Html msg) -> a -> b -> c -> Node msg
lazy3 =
    I.lazy3


{-| [`lazy`](#lazy) for a four-argument view.
-}
lazy4 : (a -> b -> c -> d -> Html msg) -> a -> b -> c -> d -> Node msg
lazy4 =
    I.lazy4


{-| [`lazy`](#lazy) for a five-argument view.
-}
lazy5 : (a -> b -> c -> d -> e -> Html msg) -> a -> b -> c -> d -> e -> Node msg
lazy5 =
    I.lazy5


{-| [`lazy`](#lazy) for a six-argument view.
-}
lazy6 : (a -> b -> c -> d -> e -> g -> Html msg) -> a -> b -> c -> d -> e -> g -> Node msg
lazy6 =
    I.lazy6


{-| [`lazy`](#lazy) for a seven-argument view.
-}
lazy7 : (a -> b -> c -> d -> e -> g -> h -> Html msg) -> a -> b -> c -> d -> e -> g -> h -> Node msg
lazy7 =
    I.lazy7


{-| [`lazy`](#lazy) for an eight-argument view.
-}
lazy8 : (a -> b -> c -> d -> e -> g -> h -> i -> Html msg) -> a -> b -> c -> d -> e -> g -> h -> i -> Node msg
lazy8 =
    I.lazy8


{-| Prepend one attribute. `Text` (and raw) leaves are promoted to a `<span>`
holding the attribute — never silently dropped.
-}
addAttribute : Attr capability msg -> Node msg -> Node msg
addAttribute =
    I.addAttribute


{-| Map the message type, structurally.
-}
map : (a -> b) -> Node a -> Node b
map =
    I.mapNode


{-| Collapse the tree to `Html` — the render boundary.
-}
toHtml : Node msg -> Html msg
toHtml =
    I.toHtml
