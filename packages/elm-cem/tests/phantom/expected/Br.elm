module Br exposing
    ( barren
    , Element, Attr, Node, toHtml, toNode, mapMsg, mapNode
    )

{-| The general surface: every component constructor in the elm/html call
shape, one import. Signatures reference each component's aliases — reach for
`Br.<Component>` when you want the strict per-component surface (required
content, builder, narrowed values), and `Br.Attributes` / `Br.Events` /
`Br.Values` for the shared vocabulary.

`toHtml` is the render bridge to `elm/html`.

@docs barren
@docs Element, Attr, Node, toHtml, toNode, mapMsg, mapNode

-}

import Br.Barren
import Html
import HtmlIr.Attribute
import HtmlIr.Element
import HtmlIr.Node


{-| See `Br.Barren.view`.
-}
barren :
    List (Attr Br.Barren.Attrs msg)
    -> List (Element Br.Barren.Content (Br.Barren.ChildAdmittedBy childAdm) msg)
    -> Element (Br.Barren.Is s) admittedBy msg
barren =
    Br.Barren.view


{-| The typed IR element every constructor here produces. Re-exported so callers never import `HtmlIr.Element` directly.
-}
type alias Element accepts admittedBy msg =
    HtmlIr.Element.Element accepts admittedBy msg


{-| A typed attribute. Re-exported so callers never import `HtmlIr.Attribute` directly.
-}
type alias Attr capability msg =
    HtmlIr.Attribute.Attr capability msg


{-| The untyped IR node an `Element` wraps — the erased form, carrying no phantom claims. Re-exported for the boundaries that must store renderable content in a monomorphic field (a framework `View` record, a cache); lift it back with `<Lib>.Unsafe.fromNode`.
-}
type alias Node msg =
    HtmlIr.Node.Node msg


{-| Render any element from this library to `elm/html`.
-}
toHtml : Element accepts admittedBy msg -> Html.Html msg
toHtml =
    HtmlIr.Element.toNode >> HtmlIr.Node.toHtml


{-| Erase an element to its untyped [`Node`](#Node) — the safe out-bound direction; the phantom rows are discarded, never re-asserted.
-}
toNode : Element accepts admittedBy msg -> Node msg
toNode =
    HtmlIr.Element.toNode


{-| Map the `msg` type of any element from this library (the typed IR's `Html.map`). Structural: the tree is not rendered, rows are preserved.
-}
mapMsg : (a -> b) -> Element accepts admittedBy a -> Element accepts admittedBy b
mapMsg =
    HtmlIr.Element.map


{-| [`mapMsg`](#mapMsg) for an erased [`Node`](#Node).
-}
mapNode : (a -> b) -> Node a -> Node b
mapNode =
    HtmlIr.Node.map
