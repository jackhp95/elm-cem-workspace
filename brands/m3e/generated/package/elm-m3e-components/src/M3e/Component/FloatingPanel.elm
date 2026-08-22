module M3e.Component.FloatingPanel exposing (FloatingPanelIs, FloatingPanelAttrs, FloatingPanelBuilder, FloatingPanelAttrCaps, FloatingPanelSlotCaps, FloatingPanelChildAdmittedBy, FloatingPanelScrollStrategy, floatingPanel, floatingPanelScrollStrategy, floatingPanelAnchorOffset, floatingPanelFitAnchorWidth, floatingPanelOnBeforetoggle, floatingPanelOnToggle, floatingPanelChild)

{-| The **FloatingPanel** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.FloatingPanel`](M3e.Element.FloatingPanel) as `floatingPanel`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs FloatingPanelIs, FloatingPanelAttrs, FloatingPanelBuilder, FloatingPanelAttrCaps, FloatingPanelSlotCaps, FloatingPanelChildAdmittedBy, FloatingPanelScrollStrategy, floatingPanel, floatingPanelScrollStrategy, floatingPanelAnchorOffset, floatingPanelFitAnchorWidth, floatingPanelOnBeforetoggle, floatingPanelOnToggle, floatingPanelChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.FloatingPanel as FloatingPanel_


{-| The `floatingPanel` element of this family — delegates to [`M3e.Element.FloatingPanel.component`](M3e.Element.FloatingPanel#component).
-}
floatingPanel :
    List (Attr FloatingPanelAttrs msg)
    -> List (Element childAccepts (FloatingPanelChildAdmittedBy childAdm) msg)
    -> Element (FloatingPanelIs s) admittedBy msg
floatingPanel =
    FloatingPanel_.component


{-| See [`M3e.Element.FloatingPanel.Is`](M3e.Element.FloatingPanel#Is).
-}
type alias FloatingPanelIs s =
    FloatingPanel_.Is s


{-| See [`M3e.Element.FloatingPanel.Attrs`](M3e.Element.FloatingPanel#Attrs).
-}
type alias FloatingPanelAttrs =
    FloatingPanel_.Attrs


{-| See [`M3e.Element.FloatingPanel.Builder`](M3e.Element.FloatingPanel#Builder).
-}
type alias FloatingPanelBuilder attrCaps slotCaps msg kind =
    FloatingPanel_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.FloatingPanel.AttrCaps`](M3e.Element.FloatingPanel#AttrCaps).
-}
type alias FloatingPanelAttrCaps =
    FloatingPanel_.AttrCaps


{-| See [`M3e.Element.FloatingPanel.SlotCaps`](M3e.Element.FloatingPanel#SlotCaps).
-}
type alias FloatingPanelSlotCaps =
    FloatingPanel_.SlotCaps


{-| See [`M3e.Element.FloatingPanel.ChildAdmittedBy`](M3e.Element.FloatingPanel#ChildAdmittedBy).
-}
type alias FloatingPanelChildAdmittedBy childAdm =
    FloatingPanel_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.FloatingPanel.ScrollStrategy`](M3e.Element.FloatingPanel#ScrollStrategy).
-}
type alias FloatingPanelScrollStrategy =
    FloatingPanel_.ScrollStrategy


{-| See [`M3e.Element.FloatingPanel.scrollStrategy`](M3e.Element.FloatingPanel#scrollStrategy).
-}
floatingPanelScrollStrategy : Value FloatingPanelScrollStrategy -> Attr { c | scrollStrategy : Supported } msg
floatingPanelScrollStrategy =
    FloatingPanel_.scrollStrategy


{-| See [`M3e.Element.FloatingPanel.anchorOffset`](M3e.Element.FloatingPanel#anchorOffset).
-}
floatingPanelAnchorOffset : Float -> Attr { c | anchorOffset : Supported } msg
floatingPanelAnchorOffset =
    FloatingPanel_.anchorOffset


{-| See [`M3e.Element.FloatingPanel.fitAnchorWidth`](M3e.Element.FloatingPanel#fitAnchorWidth).
-}
floatingPanelFitAnchorWidth : Bool -> Attr { c | fitAnchorWidth : Supported } msg
floatingPanelFitAnchorWidth =
    FloatingPanel_.fitAnchorWidth


{-| See [`M3e.Element.FloatingPanel.onBeforetoggle`](M3e.Element.FloatingPanel#onBeforetoggle).
-}
floatingPanelOnBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
floatingPanelOnBeforetoggle =
    FloatingPanel_.onBeforetoggle


{-| See [`M3e.Element.FloatingPanel.onToggle`](M3e.Element.FloatingPanel#onToggle).
-}
floatingPanelOnToggle : msg -> Attr { c | onToggle : Supported } msg
floatingPanelOnToggle =
    FloatingPanel_.onToggle


{-| See [`M3e.Element.FloatingPanel.child`](M3e.Element.FloatingPanel#child).
-}
floatingPanelChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
floatingPanelChild =
    FloatingPanel_.child
