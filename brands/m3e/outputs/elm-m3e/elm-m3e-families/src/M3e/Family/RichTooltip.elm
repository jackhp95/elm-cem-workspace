module M3e.Family.RichTooltip exposing (RichTooltipIs, RichTooltipAttrs, RichTooltipBuilder, RichTooltipAttrCaps, RichTooltipSlotCaps, RichTooltipContent, RichTooltipSubheadSlot, RichTooltipChildAdmittedBy, RichTooltipPosition, RichTooltipTouchGestures, ActionIs, ActionAttrs, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionContent, ActionChildAdmittedBy, richTooltip, richTooltipPosition, richTooltipTouchGestures, richTooltipDisabled, richTooltipFor, richTooltipHideDelay, richTooltipShowDelay, richTooltipOnBeforetoggle, richTooltipOnToggle, richTooltipActions, richTooltipSubhead, richTooltipChild, action, actionDisableRestoreFocus, actionChild)

{-| The **RichTooltip** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.RichTooltip`](M3e.Component.RichTooltip) as `richTooltip`, [`M3e.Component.RichTooltipAction`](M3e.Component.RichTooltipAction) as `action`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs RichTooltipIs, RichTooltipAttrs, RichTooltipBuilder, RichTooltipAttrCaps, RichTooltipSlotCaps, RichTooltipContent, RichTooltipSubheadSlot, RichTooltipChildAdmittedBy, RichTooltipPosition, RichTooltipTouchGestures, ActionIs, ActionAttrs, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionContent, ActionChildAdmittedBy, richTooltip, richTooltipPosition, richTooltipTouchGestures, richTooltipDisabled, richTooltipFor, richTooltipHideDelay, richTooltipShowDelay, richTooltipOnBeforetoggle, richTooltipOnToggle, richTooltipActions, richTooltipSubhead, richTooltipChild, action, actionDisableRestoreFocus, actionChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Component.RichTooltip as RichTooltip_
import M3e.Component.RichTooltipAction as Action_


{-| The `richTooltip` element of this family — delegates to [`M3e.Component.RichTooltip.component`](M3e.Component.RichTooltip#component).
-}
richTooltip :
    { content : Element RichTooltipContent (RichTooltipChildAdmittedBy childAdm) msg }
    -> List (Attr RichTooltipAttrs msg)
    -> List (Element RichTooltipContent (RichTooltipChildAdmittedBy childAdm) msg)
    -> Element (RichTooltipIs s) admittedBy msg
richTooltip =
    RichTooltip_.component


{-| See [`M3e.Component.RichTooltip.Is`](M3e.Component.RichTooltip#Is).
-}
type alias RichTooltipIs s =
    RichTooltip_.Is s


{-| See [`M3e.Component.RichTooltip.Attrs`](M3e.Component.RichTooltip#Attrs).
-}
type alias RichTooltipAttrs =
    RichTooltip_.Attrs


{-| See [`M3e.Component.RichTooltip.Builder`](M3e.Component.RichTooltip#Builder).
-}
type alias RichTooltipBuilder attrCaps slotCaps msg kind =
    RichTooltip_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.RichTooltip.AttrCaps`](M3e.Component.RichTooltip#AttrCaps).
-}
type alias RichTooltipAttrCaps =
    RichTooltip_.AttrCaps


{-| See [`M3e.Component.RichTooltip.SlotCaps`](M3e.Component.RichTooltip#SlotCaps).
-}
type alias RichTooltipSlotCaps =
    RichTooltip_.SlotCaps


{-| See [`M3e.Component.RichTooltip.Content`](M3e.Component.RichTooltip#Content).
-}
type alias RichTooltipContent =
    RichTooltip_.Content


{-| See [`M3e.Component.RichTooltip.SubheadSlot`](M3e.Component.RichTooltip#SubheadSlot).
-}
type alias RichTooltipSubheadSlot =
    RichTooltip_.SubheadSlot


{-| See [`M3e.Component.RichTooltip.ChildAdmittedBy`](M3e.Component.RichTooltip#ChildAdmittedBy).
-}
type alias RichTooltipChildAdmittedBy childAdm =
    RichTooltip_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.RichTooltip.Position`](M3e.Component.RichTooltip#Position).
-}
type alias RichTooltipPosition =
    RichTooltip_.Position


{-| See [`M3e.Component.RichTooltip.position`](M3e.Component.RichTooltip#position).
-}
richTooltipPosition : Value RichTooltipPosition -> Attr { c | position : Supported } msg
richTooltipPosition =
    RichTooltip_.position


{-| See [`M3e.Component.RichTooltip.TouchGestures`](M3e.Component.RichTooltip#TouchGestures).
-}
type alias RichTooltipTouchGestures =
    RichTooltip_.TouchGestures


{-| See [`M3e.Component.RichTooltip.touchGestures`](M3e.Component.RichTooltip#touchGestures).
-}
richTooltipTouchGestures : Value RichTooltipTouchGestures -> Attr { c | touchGestures : Supported } msg
richTooltipTouchGestures =
    RichTooltip_.touchGestures


{-| See [`M3e.Component.RichTooltip.disabled`](M3e.Component.RichTooltip#disabled).
-}
richTooltipDisabled : Bool -> Attr { c | disabled : Supported } msg
richTooltipDisabled =
    RichTooltip_.disabled


{-| See [`M3e.Component.RichTooltip.for`](M3e.Component.RichTooltip#for).
-}
richTooltipFor : String -> Attr { c | for : Supported } msg
richTooltipFor =
    RichTooltip_.for


{-| See [`M3e.Component.RichTooltip.hideDelay`](M3e.Component.RichTooltip#hideDelay).
-}
richTooltipHideDelay : Float -> Attr { c | hideDelay : Supported } msg
richTooltipHideDelay =
    RichTooltip_.hideDelay


{-| See [`M3e.Component.RichTooltip.showDelay`](M3e.Component.RichTooltip#showDelay).
-}
richTooltipShowDelay : Float -> Attr { c | showDelay : Supported } msg
richTooltipShowDelay =
    RichTooltip_.showDelay


{-| See [`M3e.Component.RichTooltip.onBeforetoggle`](M3e.Component.RichTooltip#onBeforetoggle).
-}
richTooltipOnBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
richTooltipOnBeforetoggle =
    RichTooltip_.onBeforetoggle


{-| See [`M3e.Component.RichTooltip.onToggle`](M3e.Component.RichTooltip#onToggle).
-}
richTooltipOnToggle : msg -> Attr { c | onToggle : Supported } msg
richTooltipOnToggle =
    RichTooltip_.onToggle


{-| See [`M3e.Component.RichTooltip.actions`](M3e.Component.RichTooltip#actions).
-}
richTooltipActions : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
richTooltipActions =
    RichTooltip_.actions


{-| See [`M3e.Component.RichTooltip.subhead`](M3e.Component.RichTooltip#subhead).
-}
richTooltipSubhead : Element RichTooltipSubheadSlot admittedBy msg -> Element free freeAdmittedBy msg
richTooltipSubhead =
    RichTooltip_.subhead


{-| See [`M3e.Component.RichTooltip.child`](M3e.Component.RichTooltip#child).
-}
richTooltipChild : Element RichTooltipContent admittedBy msg -> Element free freeAdmittedBy msg
richTooltipChild =
    RichTooltip_.child


{-| The `action` element of this family — delegates to [`M3e.Component.RichTooltipAction.component`](M3e.Component.RichTooltipAction#component).
-}
action :
    { content : Element ActionContent (ActionChildAdmittedBy childAdm) msg }
    -> List (Attr ActionAttrs msg)
    -> List (Element ActionContent (ActionChildAdmittedBy childAdm) msg)
    -> Element (ActionIs s) admittedBy msg
action =
    Action_.component


{-| See [`M3e.Component.RichTooltipAction.Is`](M3e.Component.RichTooltipAction#Is).
-}
type alias ActionIs s =
    Action_.Is s


{-| See [`M3e.Component.RichTooltipAction.Attrs`](M3e.Component.RichTooltipAction#Attrs).
-}
type alias ActionAttrs =
    Action_.Attrs


{-| See [`M3e.Component.RichTooltipAction.Builder`](M3e.Component.RichTooltipAction#Builder).
-}
type alias ActionBuilder attrCaps slotCaps msg kind =
    Action_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.RichTooltipAction.AttrCaps`](M3e.Component.RichTooltipAction#AttrCaps).
-}
type alias ActionAttrCaps =
    Action_.AttrCaps


{-| See [`M3e.Component.RichTooltipAction.SlotCaps`](M3e.Component.RichTooltipAction#SlotCaps).
-}
type alias ActionSlotCaps =
    Action_.SlotCaps


{-| See [`M3e.Component.RichTooltipAction.Content`](M3e.Component.RichTooltipAction#Content).
-}
type alias ActionContent =
    Action_.Content


{-| See [`M3e.Component.RichTooltipAction.ChildAdmittedBy`](M3e.Component.RichTooltipAction#ChildAdmittedBy).
-}
type alias ActionChildAdmittedBy childAdm =
    Action_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.RichTooltipAction.disableRestoreFocus`](M3e.Component.RichTooltipAction#disableRestoreFocus).
-}
actionDisableRestoreFocus : Bool -> Attr { c | disableRestoreFocus : Supported } msg
actionDisableRestoreFocus =
    Action_.disableRestoreFocus


{-| See [`M3e.Component.RichTooltipAction.child`](M3e.Component.RichTooltipAction#child).
-}
actionChild : Element ActionContent admittedBy msg -> Element free freeAdmittedBy msg
actionChild =
    Action_.child
