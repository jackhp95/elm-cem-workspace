module Or.Html exposing
    ( plain, widget
    , Element, Attr, Node, toHtml, toNode, mapMsg, mapNode
    )

{-| The loose, elm/html-like producer layer: one open-rowed constructor
per element, each owning `Ir.node "<tag>"`. This is the foundation the
`Or-html` package exposes; every rich `Or.<Component>` imports
its producer here and re-exposes it under a tightened signature. Depends
only on the IR substrate — no component module is imported.

The substrate types are re-exported here too, so a consumer of the
published package can write type annotations without importing
`HtmlIr.*` directly.

@docs plain, widget
@docs Element, Attr, Node, toHtml, toNode, mapMsg, mapNode

-}

import Html
import HtmlIr.Attribute
import HtmlIr.Element
import HtmlIr.Internal as Ir
import HtmlIr.Node


{-| The loose `or-plain` producer — open attribute/child rows, elm/html call
shape. `Or.Plain` tightens it (closed rows, slot admittance, narrowed values).
-}
plain :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
plain attrs children =
    Ir.fromNode (Ir.node "or-plain" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `or-widget` producer — open attribute/child rows, elm/html call
shape. `Or.Widget` tightens it (closed rows, slot admittance, narrowed values).
-}
widget :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
widget attrs children =
    Ir.fromNode (Ir.node "or-widget" attrs (List.map HtmlIr.Element.toNode children))


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
