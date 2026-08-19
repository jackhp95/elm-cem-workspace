module HtmlIr.Node exposing
    ( Node
    , node, keyedNode, text
    , isKeyed, toKeyedPair
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
@docs isKeyed, toKeyedPair
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

If any child carries a diff key (via [`HtmlIr.Element.key`](HtmlIr-Element#key)),
the whole child list is auto-upgraded to a keyed node, with `String.fromInt
index` filling in for unkeyed children. See
[`HtmlIr.Internal.node`](HtmlIr-Internal#node).

-}
node : String -> List (Attr capability msg) -> List (Node msg) -> Node msg
node =
    I.node


{-| Build a tag node whose children carry diff keys (`VirtualDom.keyedNode`) —
the low-level keyed primitive for lists that reorder/insert/remove, where
unkeyed diffing breaks animation and state retention. Prefer
[`HtmlIr.Element.key`](HtmlIr-Element#key) on children (which lets `node`
auto-upgrade) when you want to keep a typed container's child-kind constraint.
-}
keyedNode : String -> List (Attr capability msg) -> List ( String, Node msg ) -> Node msg
keyedNode =
    I.keyedNode


{-| A text leaf.
-}
text : String -> Node msg
text =
    I.text


{-| Whether a node carries an explicit diff key — the predicate that triggers
[`node`](#node)'s keyed auto-upgrade.
-}
isKeyed : Node msg -> Bool
isKeyed =
    I.isKeyed


{-| Pair a child with its diff key for a keyed node: the explicit key if the
child carries one, otherwise the positional `String.fromInt index` fallback.
-}
toKeyedPair : Int -> Node msg -> ( String, Node msg )
toKeyedPair =
    I.toKeyedPair


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
