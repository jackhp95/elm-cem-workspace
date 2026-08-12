module Hz exposing
    ( attrSlot, blocked, duplicate, errorOnly, eventClash, global, placement, hzCapitalText, textElement
    , text
    , Element, Attr, Node, toHtml, toNode, mapMsg, mapNode
    )

{-| The general surface: every component constructor in the elm/html call
shape, one import. Signatures reference each component's aliases — reach for
`Hz.<Component>` when you want the strict per-component surface (required
content, builder, narrowed values), and `Hz.Attributes` / `Hz.Events` /
`Hz.Values` for the shared vocabulary.

`toHtml` is the render bridge to `elm/html`.

@docs attrSlot, blocked, duplicate, errorOnly, eventClash, global, placement, hzCapitalText, textElement
@docs text
@docs Element, Attr, Node, toHtml, toNode, mapMsg, mapNode

-}

import Html
import HtmlIr.Attribute
import HtmlIr.Element
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared)
import HtmlIr.Node
import Hz.AttrSlot
import Hz.Blocked
import Hz.Duplicate
import Hz.ErrorOnly
import Hz.EventClash
import Hz.Global
import Hz.Placement
import Hz.Text
import Hz.TextElement


{-| See `Hz.AttrSlot.view`.
-}
attrSlot :
    List (Attr Hz.AttrSlot.Attrs msg)
    -> List (Element childAccepts (Hz.AttrSlot.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.AttrSlot.Is s) admittedBy msg
attrSlot =
    Hz.AttrSlot.view


{-| See `Hz.Blocked.view`.
-}
blocked :
    List (Attr Hz.Blocked.Attrs msg)
    -> List (Element Hz.Blocked.Content (Hz.Blocked.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.Blocked.Is s) admittedBy msg
blocked =
    Hz.Blocked.view


{-| See `Hz.Duplicate.view`.
-}
duplicate :
    List (Attr Hz.Duplicate.Attrs msg)
    -> List (Element Hz.Duplicate.Content (Hz.Duplicate.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.Duplicate.Is s) admittedBy msg
duplicate =
    Hz.Duplicate.view


{-| See `Hz.ErrorOnly.view`.
-}
errorOnly :
    List (Attr Hz.ErrorOnly.Attrs msg)
    -> List (Element childAccepts (Hz.ErrorOnly.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.ErrorOnly.Is s) admittedBy msg
errorOnly =
    Hz.ErrorOnly.view


{-| See `Hz.EventClash.view`.
-}
eventClash :
    List (Attr Hz.EventClash.Attrs msg)
    -> List (Element Hz.EventClash.Content (Hz.EventClash.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.EventClash.Is s) admittedBy msg
eventClash =
    Hz.EventClash.view


{-| See `Hz.Global.view`.
-}
global :
    List (Attr Hz.Global.Attrs msg)
    -> List (Element Hz.Global.Content (Hz.Global.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.Global.Is s) admittedBy msg
global =
    Hz.Global.view


{-| See `Hz.Placement.view`.
-}
placement :
    List (Attr Hz.Placement.Attrs msg)
    -> List (Element Hz.Placement.Content (Hz.Placement.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.Placement.Is s) admittedBy msg
placement =
    Hz.Placement.view


{-| See `Hz.Text.view`.
-}
hzCapitalText :
    List (Attr Hz.Text.Attrs msg)
    -> List (Element Hz.Text.Content (Hz.Text.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.Text.Is s) admittedBy msg
hzCapitalText =
    Hz.Text.view


{-| See `Hz.TextElement.view`.
-}
textElement :
    List (Attr Hz.TextElement.Attrs msg)
    -> List (Element Hz.TextElement.Content (Hz.TextElement.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.TextElement.Is s) admittedBy msg
textElement =
    Hz.TextElement.view


{-| The shared text atom — admissible into any library's opted-in slot.
-}
text : String -> Element { s | sharedText : Shared } admittedBy msg
text value_ =
    Ir.fromNode (Ir.text value_)


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
