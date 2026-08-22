module M3e.Component.OptionPanel exposing (OptionPanelIs, OptionPanelAttrs, OptionPanelBuilder, OptionPanelAttrCaps, OptionPanelSlotCaps, OptionPanelContent, OptionPanelLoadingSlot, OptionPanelChildAdmittedBy, OptionPanelScrollStrategy, optionPanel, optionPanelScrollStrategy, optionPanelAnchorOffset, optionPanelFitAnchorWidth, optionPanelOnBeforetoggle, optionPanelOnToggle, optionPanelLoading, optionPanelNoData, optionPanelChild)

{-| The **OptionPanel** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.OptionPanel`](M3e.Element.OptionPanel) as `optionPanel`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs OptionPanelIs, OptionPanelAttrs, OptionPanelBuilder, OptionPanelAttrCaps, OptionPanelSlotCaps, OptionPanelContent, OptionPanelLoadingSlot, OptionPanelChildAdmittedBy, OptionPanelScrollStrategy, optionPanel, optionPanelScrollStrategy, optionPanelAnchorOffset, optionPanelFitAnchorWidth, optionPanelOnBeforetoggle, optionPanelOnToggle, optionPanelLoading, optionPanelNoData, optionPanelChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.OptionPanel as OptionPanel_


{-| The `optionPanel` element of this family — delegates to [`M3e.Element.OptionPanel.component`](M3e.Element.OptionPanel#component).
-}
optionPanel :
    List (Attr OptionPanelAttrs msg)
    -> List (Element OptionPanelContent (OptionPanelChildAdmittedBy childAdm) msg)
    -> Element (OptionPanelIs s) admittedBy msg
optionPanel =
    OptionPanel_.component


{-| See [`M3e.Element.OptionPanel.Is`](M3e.Element.OptionPanel#Is).
-}
type alias OptionPanelIs s =
    OptionPanel_.Is s


{-| See [`M3e.Element.OptionPanel.Attrs`](M3e.Element.OptionPanel#Attrs).
-}
type alias OptionPanelAttrs =
    OptionPanel_.Attrs


{-| See [`M3e.Element.OptionPanel.Builder`](M3e.Element.OptionPanel#Builder).
-}
type alias OptionPanelBuilder attrCaps slotCaps msg kind =
    OptionPanel_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.OptionPanel.AttrCaps`](M3e.Element.OptionPanel#AttrCaps).
-}
type alias OptionPanelAttrCaps =
    OptionPanel_.AttrCaps


{-| See [`M3e.Element.OptionPanel.SlotCaps`](M3e.Element.OptionPanel#SlotCaps).
-}
type alias OptionPanelSlotCaps =
    OptionPanel_.SlotCaps


{-| See [`M3e.Element.OptionPanel.Content`](M3e.Element.OptionPanel#Content).
-}
type alias OptionPanelContent =
    OptionPanel_.Content


{-| See [`M3e.Element.OptionPanel.LoadingSlot`](M3e.Element.OptionPanel#LoadingSlot).
-}
type alias OptionPanelLoadingSlot =
    OptionPanel_.LoadingSlot


{-| See [`M3e.Element.OptionPanel.ChildAdmittedBy`](M3e.Element.OptionPanel#ChildAdmittedBy).
-}
type alias OptionPanelChildAdmittedBy childAdm =
    OptionPanel_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.OptionPanel.ScrollStrategy`](M3e.Element.OptionPanel#ScrollStrategy).
-}
type alias OptionPanelScrollStrategy =
    OptionPanel_.ScrollStrategy


{-| See [`M3e.Element.OptionPanel.scrollStrategy`](M3e.Element.OptionPanel#scrollStrategy).
-}
optionPanelScrollStrategy : Value OptionPanelScrollStrategy -> Attr { c | scrollStrategy : Supported } msg
optionPanelScrollStrategy =
    OptionPanel_.scrollStrategy


{-| See [`M3e.Element.OptionPanel.anchorOffset`](M3e.Element.OptionPanel#anchorOffset).
-}
optionPanelAnchorOffset : Float -> Attr { c | anchorOffset : Supported } msg
optionPanelAnchorOffset =
    OptionPanel_.anchorOffset


{-| See [`M3e.Element.OptionPanel.fitAnchorWidth`](M3e.Element.OptionPanel#fitAnchorWidth).
-}
optionPanelFitAnchorWidth : Bool -> Attr { c | fitAnchorWidth : Supported } msg
optionPanelFitAnchorWidth =
    OptionPanel_.fitAnchorWidth


{-| See [`M3e.Element.OptionPanel.onBeforetoggle`](M3e.Element.OptionPanel#onBeforetoggle).
-}
optionPanelOnBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
optionPanelOnBeforetoggle =
    OptionPanel_.onBeforetoggle


{-| See [`M3e.Element.OptionPanel.onToggle`](M3e.Element.OptionPanel#onToggle).
-}
optionPanelOnToggle : msg -> Attr { c | onToggle : Supported } msg
optionPanelOnToggle =
    OptionPanel_.onToggle


{-| See [`M3e.Element.OptionPanel.loading`](M3e.Element.OptionPanel#loading).
-}
optionPanelLoading : Element OptionPanelLoadingSlot admittedBy msg -> Element free freeAdmittedBy msg
optionPanelLoading =
    OptionPanel_.loading


{-| See [`M3e.Element.OptionPanel.noData`](M3e.Element.OptionPanel#noData).
-}
optionPanelNoData : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
optionPanelNoData =
    OptionPanel_.noData


{-| See [`M3e.Element.OptionPanel.child`](M3e.Element.OptionPanel#child).
-}
optionPanelChild : Element OptionPanelContent admittedBy msg -> Element free freeAdmittedBy msg
optionPanelChild =
    OptionPanel_.child
