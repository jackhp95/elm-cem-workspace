module M3e.Component.Tooltip exposing (TooltipIs, TooltipAttrs, TooltipBuilder, TooltipAttrCaps, TooltipSlotCaps, TooltipContent, TooltipChildAdmittedBy, TooltipPosition, TooltipTouchGestures, tooltip, tooltipPosition, tooltipTouchGestures, tooltipDisabled, tooltipFor, tooltipHideDelay, tooltipShowDelay, tooltipChild)

{-| The **Tooltip** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Tooltip`](M3e.Element.Tooltip) as `tooltip`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs TooltipIs, TooltipAttrs, TooltipBuilder, TooltipAttrCaps, TooltipSlotCaps, TooltipContent, TooltipChildAdmittedBy, TooltipPosition, TooltipTouchGestures, tooltip, tooltipPosition, tooltipTouchGestures, tooltipDisabled, tooltipFor, tooltipHideDelay, tooltipShowDelay, tooltipChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Tooltip as Tooltip_


{-| The `tooltip` element of this family — delegates to [`M3e.Element.Tooltip.component`](M3e.Element.Tooltip#component).
-}
tooltip :
    { content : Element TooltipContent (TooltipChildAdmittedBy childAdm) msg }
    -> List (Attr TooltipAttrs msg)
    -> List (Element TooltipContent (TooltipChildAdmittedBy childAdm) msg)
    -> Element (TooltipIs s) admittedBy msg
tooltip =
    Tooltip_.component


{-| See [`M3e.Element.Tooltip.Is`](M3e.Element.Tooltip#Is).
-}
type alias TooltipIs s =
    Tooltip_.Is s


{-| See [`M3e.Element.Tooltip.Attrs`](M3e.Element.Tooltip#Attrs).
-}
type alias TooltipAttrs =
    Tooltip_.Attrs


{-| See [`M3e.Element.Tooltip.Builder`](M3e.Element.Tooltip#Builder).
-}
type alias TooltipBuilder attrCaps slotCaps msg kind =
    Tooltip_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Tooltip.AttrCaps`](M3e.Element.Tooltip#AttrCaps).
-}
type alias TooltipAttrCaps =
    Tooltip_.AttrCaps


{-| See [`M3e.Element.Tooltip.SlotCaps`](M3e.Element.Tooltip#SlotCaps).
-}
type alias TooltipSlotCaps =
    Tooltip_.SlotCaps


{-| See [`M3e.Element.Tooltip.Content`](M3e.Element.Tooltip#Content).
-}
type alias TooltipContent =
    Tooltip_.Content


{-| See [`M3e.Element.Tooltip.ChildAdmittedBy`](M3e.Element.Tooltip#ChildAdmittedBy).
-}
type alias TooltipChildAdmittedBy childAdm =
    Tooltip_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Tooltip.Position`](M3e.Element.Tooltip#Position).
-}
type alias TooltipPosition =
    Tooltip_.Position


{-| See [`M3e.Element.Tooltip.position`](M3e.Element.Tooltip#position).
-}
tooltipPosition : Value TooltipPosition -> Attr { c | position : Supported } msg
tooltipPosition =
    Tooltip_.position


{-| See [`M3e.Element.Tooltip.TouchGestures`](M3e.Element.Tooltip#TouchGestures).
-}
type alias TooltipTouchGestures =
    Tooltip_.TouchGestures


{-| See [`M3e.Element.Tooltip.touchGestures`](M3e.Element.Tooltip#touchGestures).
-}
tooltipTouchGestures : Value TooltipTouchGestures -> Attr { c | touchGestures : Supported } msg
tooltipTouchGestures =
    Tooltip_.touchGestures


{-| See [`M3e.Element.Tooltip.disabled`](M3e.Element.Tooltip#disabled).
-}
tooltipDisabled : Bool -> Attr { c | disabled : Supported } msg
tooltipDisabled =
    Tooltip_.disabled


{-| See [`M3e.Element.Tooltip.for`](M3e.Element.Tooltip#for).
-}
tooltipFor : String -> Attr { c | for : Supported } msg
tooltipFor =
    Tooltip_.for


{-| See [`M3e.Element.Tooltip.hideDelay`](M3e.Element.Tooltip#hideDelay).
-}
tooltipHideDelay : Float -> Attr { c | hideDelay : Supported } msg
tooltipHideDelay =
    Tooltip_.hideDelay


{-| See [`M3e.Element.Tooltip.showDelay`](M3e.Element.Tooltip#showDelay).
-}
tooltipShowDelay : Float -> Attr { c | showDelay : Supported } msg
tooltipShowDelay =
    Tooltip_.showDelay


{-| See [`M3e.Element.Tooltip.child`](M3e.Element.Tooltip#child).
-}
tooltipChild : Element TooltipContent admittedBy msg -> Element free freeAdmittedBy msg
tooltipChild =
    Tooltip_.child
