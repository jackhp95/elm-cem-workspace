module Sl.Component.SplitPanel exposing (SplitPanelIs, SplitPanelAttrs, SplitPanelBuilder, SplitPanelAttrCaps, SplitPanelSlotCaps, SplitPanelChildAdmittedBy, SplitPanelPrimary, splitPanel, splitPanelPrimary, splitPanelDisabled, splitPanelPosition, splitPanelPositionInPixels, splitPanelSnap, splitPanelSnapThreshold, splitPanelVertical, splitPanelOnReposition)

{-| The **SplitPanel** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.SplitPanel`](Sl.Element.SplitPanel) as `splitPanel`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SplitPanelIs, SplitPanelAttrs, SplitPanelBuilder, SplitPanelAttrCaps, SplitPanelSlotCaps, SplitPanelChildAdmittedBy, SplitPanelPrimary, splitPanel, splitPanelPrimary, splitPanelDisabled, splitPanelPosition, splitPanelPositionInPixels, splitPanelSnap, splitPanelSnapThreshold, splitPanelVertical, splitPanelOnReposition

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.SplitPanel as SplitPanel_


{-| The `splitPanel` element of this family — delegates to [`Sl.Element.SplitPanel.component`](Sl.Element.SplitPanel#component).
-}
splitPanel :
    List (Attr SplitPanelAttrs msg)
    -> List (Element childAccepts (SplitPanelChildAdmittedBy childAdm) msg)
    -> Element (SplitPanelIs s) admittedBy msg
splitPanel =
    SplitPanel_.component


{-| See [`Sl.Element.SplitPanel.Is`](Sl.Element.SplitPanel#Is).
-}
type alias SplitPanelIs s =
    SplitPanel_.Is s


{-| See [`Sl.Element.SplitPanel.Attrs`](Sl.Element.SplitPanel#Attrs).
-}
type alias SplitPanelAttrs =
    SplitPanel_.Attrs


{-| See [`Sl.Element.SplitPanel.Builder`](Sl.Element.SplitPanel#Builder).
-}
type alias SplitPanelBuilder attrCaps slotCaps msg kind =
    SplitPanel_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.SplitPanel.AttrCaps`](Sl.Element.SplitPanel#AttrCaps).
-}
type alias SplitPanelAttrCaps =
    SplitPanel_.AttrCaps


{-| See [`Sl.Element.SplitPanel.SlotCaps`](Sl.Element.SplitPanel#SlotCaps).
-}
type alias SplitPanelSlotCaps =
    SplitPanel_.SlotCaps


{-| See [`Sl.Element.SplitPanel.ChildAdmittedBy`](Sl.Element.SplitPanel#ChildAdmittedBy).
-}
type alias SplitPanelChildAdmittedBy childAdm =
    SplitPanel_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.SplitPanel.Primary`](Sl.Element.SplitPanel#Primary).
-}
type alias SplitPanelPrimary =
    SplitPanel_.Primary


{-| See [`Sl.Element.SplitPanel.primary`](Sl.Element.SplitPanel#primary).
-}
splitPanelPrimary : Value SplitPanelPrimary -> Attr { c | primary : Supported } msg
splitPanelPrimary =
    SplitPanel_.primary


{-| See [`Sl.Element.SplitPanel.disabled`](Sl.Element.SplitPanel#disabled).
-}
splitPanelDisabled : Bool -> Attr { c | disabled : Supported } msg
splitPanelDisabled =
    SplitPanel_.disabled


{-| See [`Sl.Element.SplitPanel.position`](Sl.Element.SplitPanel#position).
-}
splitPanelPosition : Float -> Attr { c | position : Supported } msg
splitPanelPosition =
    SplitPanel_.position


{-| See [`Sl.Element.SplitPanel.positionInPixels`](Sl.Element.SplitPanel#positionInPixels).
-}
splitPanelPositionInPixels : Float -> Attr { c | positionInPixels : Supported } msg
splitPanelPositionInPixels =
    SplitPanel_.positionInPixels


{-| See [`Sl.Element.SplitPanel.snap`](Sl.Element.SplitPanel#snap).
-}
splitPanelSnap : String -> Attr { c | snap : Supported } msg
splitPanelSnap =
    SplitPanel_.snap


{-| See [`Sl.Element.SplitPanel.snapThreshold`](Sl.Element.SplitPanel#snapThreshold).
-}
splitPanelSnapThreshold : Float -> Attr { c | snapThreshold : Supported } msg
splitPanelSnapThreshold =
    SplitPanel_.snapThreshold


{-| See [`Sl.Element.SplitPanel.vertical`](Sl.Element.SplitPanel#vertical).
-}
splitPanelVertical : Bool -> Attr { c | vertical : Supported } msg
splitPanelVertical =
    SplitPanel_.vertical


{-| See [`Sl.Element.SplitPanel.onReposition`](Sl.Element.SplitPanel#onReposition).
-}
splitPanelOnReposition : msg -> Attr { c | onReposition : Supported } msg
splitPanelOnReposition =
    SplitPanel_.onReposition
