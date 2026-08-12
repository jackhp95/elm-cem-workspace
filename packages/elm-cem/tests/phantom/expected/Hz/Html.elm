module Hz.Html exposing
    ( attrSlot, blocked, duplicate, errorOnly, eventClash, global, placement, hzCapitalText, textElement
    , Element, Attr, Node, toHtml, toNode, mapMsg, mapNode
    )

{-| The loose, elm/html-like producer layer: one open-rowed constructor
per element, each owning `Ir.node "<tag>"`. This is the foundation the
`Hz-html` package exposes; every rich `Hz.<Component>` imports
its producer here and re-exposes it under a tightened signature. Depends
only on the IR substrate — no component module is imported.

The substrate types are re-exported here too, so a consumer of the
published package can write type annotations without importing
`HtmlIr.*` directly.

@docs attrSlot, blocked, duplicate, errorOnly, eventClash, global, placement, hzCapitalText, textElement
@docs Element, Attr, Node, toHtml, toNode, mapMsg, mapNode

-}

import Html
import HtmlIr.Attribute
import HtmlIr.Element
import HtmlIr.Internal as Ir
import HtmlIr.Node


{-| The loose `hz-attr-slot` producer — open attribute/child rows, elm/html call
shape. `Hz.AttrSlot` tightens it (closed rows, slot admittance, narrowed values).
-}
attrSlot :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
attrSlot attrs children =
    Ir.fromNode (Ir.node "hz-attr-slot" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `hz-blocked` producer — open attribute/child rows, elm/html call
shape. `Hz.Blocked` tightens it (closed rows, slot admittance, narrowed values).
-}
blocked :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
blocked attrs children =
    Ir.fromNode (Ir.node "hz-blocked" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `hz-duplicate` producer — open attribute/child rows, elm/html call
shape. `Hz.Duplicate` tightens it (closed rows, slot admittance, narrowed values).
-}
duplicate :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
duplicate attrs children =
    Ir.fromNode (Ir.node "hz-duplicate" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `hz-error-only` producer — open attribute/child rows, elm/html call
shape. `Hz.ErrorOnly` tightens it (closed rows, slot admittance, narrowed values).
-}
errorOnly :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
errorOnly attrs children =
    Ir.fromNode (Ir.node "hz-error-only" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `hz-event-clash` producer — open attribute/child rows, elm/html call
shape. `Hz.EventClash` tightens it (closed rows, slot admittance, narrowed values).
-}
eventClash :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
eventClash attrs children =
    Ir.fromNode (Ir.node "hz-event-clash" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `hz-global` producer — open attribute/child rows, elm/html call
shape. `Hz.Global` tightens it (closed rows, slot admittance, narrowed values).
-}
global :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
global attrs children =
    Ir.fromNode (Ir.node "hz-global" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `hz-placement` producer — open attribute/child rows, elm/html call
shape. `Hz.Placement` tightens it (closed rows, slot admittance, narrowed values).
-}
placement :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
placement attrs children =
    Ir.fromNode (Ir.node "hz-placement" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `hz-capital-text` producer — open attribute/child rows, elm/html call
shape. `Hz.Text` tightens it (closed rows, slot admittance, narrowed values).
-}
hzCapitalText :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
hzCapitalText attrs children =
    Ir.fromNode (Ir.node "hz-capital-text" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `hz-text` producer — open attribute/child rows, elm/html call
shape. `Hz.TextElement` tightens it (closed rows, slot admittance, narrowed values).
-}
textElement :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
textElement attrs children =
    Ir.fromNode (Ir.node "hz-text" attrs (List.map HtmlIr.Element.toNode children))


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
