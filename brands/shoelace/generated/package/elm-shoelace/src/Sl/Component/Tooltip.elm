module Sl.Component.Tooltip exposing (TooltipIs, TooltipAttrs, TooltipBuilder, TooltipAttrCaps, TooltipSlotCaps, TooltipChildAdmittedBy, TooltipPlacement, tooltip, tooltipPlacement, tooltipContent, tooltipDisabled, tooltipDistance, tooltipHoist, tooltipOpen, tooltipSkidding, tooltipTrigger, tooltipOnShow, tooltipOnAfterShow, tooltipOnHide, tooltipOnAfterHide, tooltipChild)

{-| The **Tooltip** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Tooltip`](Sl.Element.Tooltip) as `tooltip`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs TooltipIs, TooltipAttrs, TooltipBuilder, TooltipAttrCaps, TooltipSlotCaps, TooltipChildAdmittedBy, TooltipPlacement, tooltip, tooltipPlacement, tooltipContent, tooltipDisabled, tooltipDistance, tooltipHoist, tooltipOpen, tooltipSkidding, tooltipTrigger, tooltipOnShow, tooltipOnAfterShow, tooltipOnHide, tooltipOnAfterHide, tooltipChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Tooltip as Tooltip_


{-| The `tooltip` element of this family — delegates to [`Sl.Element.Tooltip.component`](Sl.Element.Tooltip#component).
-}
tooltip :
    List (Attr TooltipAttrs msg)
    -> List (Element childAccepts (TooltipChildAdmittedBy childAdm) msg)
    -> Element (TooltipIs s) admittedBy msg
tooltip =
    Tooltip_.component


{-| See [`Sl.Element.Tooltip.Is`](Sl.Element.Tooltip#Is).
-}
type alias TooltipIs s =
    Tooltip_.Is s


{-| See [`Sl.Element.Tooltip.Attrs`](Sl.Element.Tooltip#Attrs).
-}
type alias TooltipAttrs =
    Tooltip_.Attrs


{-| See [`Sl.Element.Tooltip.Builder`](Sl.Element.Tooltip#Builder).
-}
type alias TooltipBuilder attrCaps slotCaps msg kind =
    Tooltip_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Tooltip.AttrCaps`](Sl.Element.Tooltip#AttrCaps).
-}
type alias TooltipAttrCaps =
    Tooltip_.AttrCaps


{-| See [`Sl.Element.Tooltip.SlotCaps`](Sl.Element.Tooltip#SlotCaps).
-}
type alias TooltipSlotCaps =
    Tooltip_.SlotCaps


{-| See [`Sl.Element.Tooltip.ChildAdmittedBy`](Sl.Element.Tooltip#ChildAdmittedBy).
-}
type alias TooltipChildAdmittedBy childAdm =
    Tooltip_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Tooltip.Placement`](Sl.Element.Tooltip#Placement).
-}
type alias TooltipPlacement =
    Tooltip_.Placement


{-| See [`Sl.Element.Tooltip.placement`](Sl.Element.Tooltip#placement).
-}
tooltipPlacement : Value TooltipPlacement -> Attr { c | placement : Supported } msg
tooltipPlacement =
    Tooltip_.placement


{-| See [`Sl.Element.Tooltip.content`](Sl.Element.Tooltip#content).
-}
tooltipContent : String -> Attr { c | content : Supported } msg
tooltipContent =
    Tooltip_.content


{-| See [`Sl.Element.Tooltip.disabled`](Sl.Element.Tooltip#disabled).
-}
tooltipDisabled : Bool -> Attr { c | disabled : Supported } msg
tooltipDisabled =
    Tooltip_.disabled


{-| See [`Sl.Element.Tooltip.distance`](Sl.Element.Tooltip#distance).
-}
tooltipDistance : Float -> Attr { c | distance : Supported } msg
tooltipDistance =
    Tooltip_.distance


{-| See [`Sl.Element.Tooltip.hoist`](Sl.Element.Tooltip#hoist).
-}
tooltipHoist : Bool -> Attr { c | hoist : Supported } msg
tooltipHoist =
    Tooltip_.hoist


{-| See [`Sl.Element.Tooltip.open`](Sl.Element.Tooltip#open).
-}
tooltipOpen : Bool -> Attr { c | open : Supported } msg
tooltipOpen =
    Tooltip_.open


{-| See [`Sl.Element.Tooltip.skidding`](Sl.Element.Tooltip#skidding).
-}
tooltipSkidding : Float -> Attr { c | skidding : Supported } msg
tooltipSkidding =
    Tooltip_.skidding


{-| See [`Sl.Element.Tooltip.trigger`](Sl.Element.Tooltip#trigger).
-}
tooltipTrigger : String -> Attr { c | trigger : Supported } msg
tooltipTrigger =
    Tooltip_.trigger


{-| See [`Sl.Element.Tooltip.onShow`](Sl.Element.Tooltip#onShow).
-}
tooltipOnShow : msg -> Attr { c | onShow : Supported } msg
tooltipOnShow =
    Tooltip_.onShow


{-| See [`Sl.Element.Tooltip.onAfterShow`](Sl.Element.Tooltip#onAfterShow).
-}
tooltipOnAfterShow : msg -> Attr { c | onAfterShow : Supported } msg
tooltipOnAfterShow =
    Tooltip_.onAfterShow


{-| See [`Sl.Element.Tooltip.onHide`](Sl.Element.Tooltip#onHide).
-}
tooltipOnHide : msg -> Attr { c | onHide : Supported } msg
tooltipOnHide =
    Tooltip_.onHide


{-| See [`Sl.Element.Tooltip.onAfterHide`](Sl.Element.Tooltip#onAfterHide).
-}
tooltipOnAfterHide : msg -> Attr { c | onAfterHide : Supported } msg
tooltipOnAfterHide =
    Tooltip_.onAfterHide


{-| See [`Sl.Element.Tooltip.child`](Sl.Element.Tooltip#child).
-}
tooltipChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
tooltipChild =
    Tooltip_.child
