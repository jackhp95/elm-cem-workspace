module Sl.Component.Popup exposing (PopupIs, PopupAttrs, PopupBuilder, PopupAttrCaps, PopupSlotCaps, PopupChildAdmittedBy, PopupArrowPlacement, PopupAutoSize, PopupFlipFallbackStrategy, PopupPlacement, PopupStrategy, PopupSync, popup, popupArrowPlacement, popupAutoSize, popupFlipFallbackStrategy, popupPlacement, popupStrategy, popupSync, popupActive, popupAnchor, popupArrow, popupArrowPadding, popupAutoSizePadding, popupAutosizeboundary, popupDistance, popupFlip, popupFlipFallbackPlacements, popupFlipPadding, popupFlipboundary, popupHoverBridge, popupShift, popupShiftPadding, popupShiftboundary, popupSkidding, popupOnReposition)

{-| The **Popup** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Popup`](Sl.Element.Popup) as `popup`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs PopupIs, PopupAttrs, PopupBuilder, PopupAttrCaps, PopupSlotCaps, PopupChildAdmittedBy, PopupArrowPlacement, PopupAutoSize, PopupFlipFallbackStrategy, PopupPlacement, PopupStrategy, PopupSync, popup, popupArrowPlacement, popupAutoSize, popupFlipFallbackStrategy, popupPlacement, popupStrategy, popupSync, popupActive, popupAnchor, popupArrow, popupArrowPadding, popupAutoSizePadding, popupAutosizeboundary, popupDistance, popupFlip, popupFlipFallbackPlacements, popupFlipPadding, popupFlipboundary, popupHoverBridge, popupShift, popupShiftPadding, popupShiftboundary, popupSkidding, popupOnReposition

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Popup as Popup_


{-| The `popup` element of this family — delegates to [`Sl.Element.Popup.component`](Sl.Element.Popup#component).
-}
popup :
    List (Attr PopupAttrs msg)
    -> List (Element childAccepts (PopupChildAdmittedBy childAdm) msg)
    -> Element (PopupIs s) admittedBy msg
popup =
    Popup_.component


{-| See [`Sl.Element.Popup.Is`](Sl.Element.Popup#Is).
-}
type alias PopupIs s =
    Popup_.Is s


{-| See [`Sl.Element.Popup.Attrs`](Sl.Element.Popup#Attrs).
-}
type alias PopupAttrs =
    Popup_.Attrs


{-| See [`Sl.Element.Popup.Builder`](Sl.Element.Popup#Builder).
-}
type alias PopupBuilder attrCaps slotCaps msg kind =
    Popup_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Popup.AttrCaps`](Sl.Element.Popup#AttrCaps).
-}
type alias PopupAttrCaps =
    Popup_.AttrCaps


{-| See [`Sl.Element.Popup.SlotCaps`](Sl.Element.Popup#SlotCaps).
-}
type alias PopupSlotCaps =
    Popup_.SlotCaps


{-| See [`Sl.Element.Popup.ChildAdmittedBy`](Sl.Element.Popup#ChildAdmittedBy).
-}
type alias PopupChildAdmittedBy childAdm =
    Popup_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Popup.ArrowPlacement`](Sl.Element.Popup#ArrowPlacement).
-}
type alias PopupArrowPlacement =
    Popup_.ArrowPlacement


{-| See [`Sl.Element.Popup.arrowPlacement`](Sl.Element.Popup#arrowPlacement).
-}
popupArrowPlacement : Value PopupArrowPlacement -> Attr { c | arrowPlacement : Supported } msg
popupArrowPlacement =
    Popup_.arrowPlacement


{-| See [`Sl.Element.Popup.AutoSize`](Sl.Element.Popup#AutoSize).
-}
type alias PopupAutoSize =
    Popup_.AutoSize


{-| See [`Sl.Element.Popup.autoSize`](Sl.Element.Popup#autoSize).
-}
popupAutoSize : Value PopupAutoSize -> Attr { c | autoSize : Supported } msg
popupAutoSize =
    Popup_.autoSize


{-| See [`Sl.Element.Popup.FlipFallbackStrategy`](Sl.Element.Popup#FlipFallbackStrategy).
-}
type alias PopupFlipFallbackStrategy =
    Popup_.FlipFallbackStrategy


{-| See [`Sl.Element.Popup.flipFallbackStrategy`](Sl.Element.Popup#flipFallbackStrategy).
-}
popupFlipFallbackStrategy : Value PopupFlipFallbackStrategy -> Attr { c | flipFallbackStrategy : Supported } msg
popupFlipFallbackStrategy =
    Popup_.flipFallbackStrategy


{-| See [`Sl.Element.Popup.Placement`](Sl.Element.Popup#Placement).
-}
type alias PopupPlacement =
    Popup_.Placement


{-| See [`Sl.Element.Popup.placement`](Sl.Element.Popup#placement).
-}
popupPlacement : Value PopupPlacement -> Attr { c | placement : Supported } msg
popupPlacement =
    Popup_.placement


{-| See [`Sl.Element.Popup.Strategy`](Sl.Element.Popup#Strategy).
-}
type alias PopupStrategy =
    Popup_.Strategy


{-| See [`Sl.Element.Popup.strategy`](Sl.Element.Popup#strategy).
-}
popupStrategy : Value PopupStrategy -> Attr { c | strategy : Supported } msg
popupStrategy =
    Popup_.strategy


{-| See [`Sl.Element.Popup.Sync`](Sl.Element.Popup#Sync).
-}
type alias PopupSync =
    Popup_.Sync


{-| See [`Sl.Element.Popup.sync`](Sl.Element.Popup#sync).
-}
popupSync : Value PopupSync -> Attr { c | sync : Supported } msg
popupSync =
    Popup_.sync


{-| See [`Sl.Element.Popup.active`](Sl.Element.Popup#active).
-}
popupActive : Bool -> Attr { c | active : Supported } msg
popupActive =
    Popup_.active


{-| See [`Sl.Element.Popup.anchor`](Sl.Element.Popup#anchor).
-}
popupAnchor : String -> Attr { c | anchor : Supported } msg
popupAnchor =
    Popup_.anchor


{-| See [`Sl.Element.Popup.arrow`](Sl.Element.Popup#arrow).
-}
popupArrow : Bool -> Attr { c | arrow : Supported } msg
popupArrow =
    Popup_.arrow


{-| See [`Sl.Element.Popup.arrowPadding`](Sl.Element.Popup#arrowPadding).
-}
popupArrowPadding : Float -> Attr { c | arrowPadding : Supported } msg
popupArrowPadding =
    Popup_.arrowPadding


{-| See [`Sl.Element.Popup.autoSizePadding`](Sl.Element.Popup#autoSizePadding).
-}
popupAutoSizePadding : Float -> Attr { c | autoSizePadding : Supported } msg
popupAutoSizePadding =
    Popup_.autoSizePadding


{-| See [`Sl.Element.Popup.autosizeboundary`](Sl.Element.Popup#autosizeboundary).
-}
popupAutosizeboundary : String -> Attr { c | autosizeboundary : Supported } msg
popupAutosizeboundary =
    Popup_.autosizeboundary


{-| See [`Sl.Element.Popup.distance`](Sl.Element.Popup#distance).
-}
popupDistance : Float -> Attr { c | distance : Supported } msg
popupDistance =
    Popup_.distance


{-| See [`Sl.Element.Popup.flip`](Sl.Element.Popup#flip).
-}
popupFlip : Bool -> Attr { c | flip : Supported } msg
popupFlip =
    Popup_.flip


{-| See [`Sl.Element.Popup.flipFallbackPlacements`](Sl.Element.Popup#flipFallbackPlacements).
-}
popupFlipFallbackPlacements : String -> Attr { c | flipFallbackPlacements : Supported } msg
popupFlipFallbackPlacements =
    Popup_.flipFallbackPlacements


{-| See [`Sl.Element.Popup.flipPadding`](Sl.Element.Popup#flipPadding).
-}
popupFlipPadding : Float -> Attr { c | flipPadding : Supported } msg
popupFlipPadding =
    Popup_.flipPadding


{-| See [`Sl.Element.Popup.flipboundary`](Sl.Element.Popup#flipboundary).
-}
popupFlipboundary : String -> Attr { c | flipboundary : Supported } msg
popupFlipboundary =
    Popup_.flipboundary


{-| See [`Sl.Element.Popup.hoverBridge`](Sl.Element.Popup#hoverBridge).
-}
popupHoverBridge : Bool -> Attr { c | hoverBridge : Supported } msg
popupHoverBridge =
    Popup_.hoverBridge


{-| See [`Sl.Element.Popup.shift`](Sl.Element.Popup#shift).
-}
popupShift : Bool -> Attr { c | shift : Supported } msg
popupShift =
    Popup_.shift


{-| See [`Sl.Element.Popup.shiftPadding`](Sl.Element.Popup#shiftPadding).
-}
popupShiftPadding : Float -> Attr { c | shiftPadding : Supported } msg
popupShiftPadding =
    Popup_.shiftPadding


{-| See [`Sl.Element.Popup.shiftboundary`](Sl.Element.Popup#shiftboundary).
-}
popupShiftboundary : String -> Attr { c | shiftboundary : Supported } msg
popupShiftboundary =
    Popup_.shiftboundary


{-| See [`Sl.Element.Popup.skidding`](Sl.Element.Popup#skidding).
-}
popupSkidding : Float -> Attr { c | skidding : Supported } msg
popupSkidding =
    Popup_.skidding


{-| See [`Sl.Element.Popup.onReposition`](Sl.Element.Popup#onReposition).
-}
popupOnReposition : msg -> Attr { c | onReposition : Supported } msg
popupOnReposition =
    Popup_.onReposition
