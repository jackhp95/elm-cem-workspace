module M3e.Component.BottomSheet exposing (BottomSheetIs, BottomSheetAttrs, BottomSheetBuilder, BottomSheetAttrCaps, BottomSheetSlotCaps, BottomSheetChildAdmittedBy, ActionIs, ActionAttrs, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionContent, ActionChildAdmittedBy, TriggerIs, TriggerAttrs, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerContent, TriggerChildAdmittedBy, bottomSheet, bottomSheetDetent, bottomSheetDetents, bottomSheetHandle, bottomSheetHandleLabel, bottomSheetHideFriction, bottomSheetHideable, bottomSheetModal, bottomSheetOpen, bottomSheetOvershootLimit, bottomSheetOnOpening, bottomSheetOnClosing, bottomSheetOnCancel, bottomSheetOnOpened, bottomSheetOnClosed, bottomSheetHeader, bottomSheetChild, action, actionChild, trigger, triggerDetent, triggerFor, triggerSecondary, triggerChild)

{-| The **BottomSheet** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.BottomSheet`](M3e.Element.BottomSheet) as `bottomSheet`, [`M3e.Element.BottomSheetAction`](M3e.Element.BottomSheetAction) as `action`, [`M3e.Element.BottomSheetTrigger`](M3e.Element.BottomSheetTrigger) as `trigger`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs BottomSheetIs, BottomSheetAttrs, BottomSheetBuilder, BottomSheetAttrCaps, BottomSheetSlotCaps, BottomSheetChildAdmittedBy, ActionIs, ActionAttrs, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionContent, ActionChildAdmittedBy, TriggerIs, TriggerAttrs, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerContent, TriggerChildAdmittedBy, bottomSheet, bottomSheetDetent, bottomSheetDetents, bottomSheetHandle, bottomSheetHandleLabel, bottomSheetHideFriction, bottomSheetHideable, bottomSheetModal, bottomSheetOpen, bottomSheetOvershootLimit, bottomSheetOnOpening, bottomSheetOnClosing, bottomSheetOnCancel, bottomSheetOnOpened, bottomSheetOnClosed, bottomSheetHeader, bottomSheetChild, action, actionChild, trigger, triggerDetent, triggerFor, triggerSecondary, triggerChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.BottomSheet as BottomSheet_
import M3e.Element.BottomSheetAction as Action_
import M3e.Element.BottomSheetTrigger as Trigger_


{-| The `bottomSheet` element of this family — delegates to [`M3e.Element.BottomSheet.component`](M3e.Element.BottomSheet#component).
-}
bottomSheet :
    List (Attr BottomSheetAttrs msg)
    -> List (Element childAccepts (BottomSheetChildAdmittedBy childAdm) msg)
    -> Element (BottomSheetIs s) admittedBy msg
bottomSheet =
    BottomSheet_.component


{-| See [`M3e.Element.BottomSheet.Is`](M3e.Element.BottomSheet#Is).
-}
type alias BottomSheetIs s =
    BottomSheet_.Is s


{-| See [`M3e.Element.BottomSheet.Attrs`](M3e.Element.BottomSheet#Attrs).
-}
type alias BottomSheetAttrs =
    BottomSheet_.Attrs


{-| See [`M3e.Element.BottomSheet.Builder`](M3e.Element.BottomSheet#Builder).
-}
type alias BottomSheetBuilder attrCaps slotCaps msg kind =
    BottomSheet_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.BottomSheet.AttrCaps`](M3e.Element.BottomSheet#AttrCaps).
-}
type alias BottomSheetAttrCaps =
    BottomSheet_.AttrCaps


{-| See [`M3e.Element.BottomSheet.SlotCaps`](M3e.Element.BottomSheet#SlotCaps).
-}
type alias BottomSheetSlotCaps =
    BottomSheet_.SlotCaps


{-| See [`M3e.Element.BottomSheet.ChildAdmittedBy`](M3e.Element.BottomSheet#ChildAdmittedBy).
-}
type alias BottomSheetChildAdmittedBy childAdm =
    BottomSheet_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.BottomSheet.detent`](M3e.Element.BottomSheet#detent).
-}
bottomSheetDetent : Float -> Attr { c | detent : Supported } msg
bottomSheetDetent =
    BottomSheet_.detent


{-| See [`M3e.Element.BottomSheet.detents`](M3e.Element.BottomSheet#detents).
-}
bottomSheetDetents : String -> Attr { c | detents : Supported } msg
bottomSheetDetents =
    BottomSheet_.detents


{-| See [`M3e.Element.BottomSheet.handle`](M3e.Element.BottomSheet#handle).
-}
bottomSheetHandle : Bool -> Attr { c | handle : Supported } msg
bottomSheetHandle =
    BottomSheet_.handle


{-| See [`M3e.Element.BottomSheet.handleLabel`](M3e.Element.BottomSheet#handleLabel).
-}
bottomSheetHandleLabel : String -> Attr { c | handleLabel : Supported } msg
bottomSheetHandleLabel =
    BottomSheet_.handleLabel


{-| See [`M3e.Element.BottomSheet.hideFriction`](M3e.Element.BottomSheet#hideFriction).
-}
bottomSheetHideFriction : Float -> Attr { c | hideFriction : Supported } msg
bottomSheetHideFriction =
    BottomSheet_.hideFriction


{-| See [`M3e.Element.BottomSheet.hideable`](M3e.Element.BottomSheet#hideable).
-}
bottomSheetHideable : Bool -> Attr { c | hideable : Supported } msg
bottomSheetHideable =
    BottomSheet_.hideable


{-| See [`M3e.Element.BottomSheet.modal`](M3e.Element.BottomSheet#modal).
-}
bottomSheetModal : Bool -> Attr { c | modal : Supported } msg
bottomSheetModal =
    BottomSheet_.modal


{-| See [`M3e.Element.BottomSheet.open`](M3e.Element.BottomSheet#open).
-}
bottomSheetOpen : Bool -> Attr { c | open : Supported } msg
bottomSheetOpen =
    BottomSheet_.open


{-| See [`M3e.Element.BottomSheet.overshootLimit`](M3e.Element.BottomSheet#overshootLimit).
-}
bottomSheetOvershootLimit : Float -> Attr { c | overshootLimit : Supported } msg
bottomSheetOvershootLimit =
    BottomSheet_.overshootLimit


{-| See [`M3e.Element.BottomSheet.onOpening`](M3e.Element.BottomSheet#onOpening).
-}
bottomSheetOnOpening : msg -> Attr { c | onOpening : Supported } msg
bottomSheetOnOpening =
    BottomSheet_.onOpening


{-| See [`M3e.Element.BottomSheet.onClosing`](M3e.Element.BottomSheet#onClosing).
-}
bottomSheetOnClosing : msg -> Attr { c | onClosing : Supported } msg
bottomSheetOnClosing =
    BottomSheet_.onClosing


{-| See [`M3e.Element.BottomSheet.onCancel`](M3e.Element.BottomSheet#onCancel).
-}
bottomSheetOnCancel : msg -> Attr { c | onCancel : Supported } msg
bottomSheetOnCancel =
    BottomSheet_.onCancel


{-| See [`M3e.Element.BottomSheet.onOpened`](M3e.Element.BottomSheet#onOpened).
-}
bottomSheetOnOpened : msg -> Attr { c | onOpened : Supported } msg
bottomSheetOnOpened =
    BottomSheet_.onOpened


{-| See [`M3e.Element.BottomSheet.onClosed`](M3e.Element.BottomSheet#onClosed).
-}
bottomSheetOnClosed : msg -> Attr { c | onClosed : Supported } msg
bottomSheetOnClosed =
    BottomSheet_.onClosed


{-| See [`M3e.Element.BottomSheet.header`](M3e.Element.BottomSheet#header).
-}
bottomSheetHeader : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
bottomSheetHeader =
    BottomSheet_.header


{-| See [`M3e.Element.BottomSheet.child`](M3e.Element.BottomSheet#child).
-}
bottomSheetChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
bottomSheetChild =
    BottomSheet_.child


{-| The `action` element of this family — delegates to [`M3e.Element.BottomSheetAction.component`](M3e.Element.BottomSheetAction#component).
-}
action :
    List (Attr ActionAttrs msg)
    -> List (Element ActionContent (ActionChildAdmittedBy childAdm) msg)
    -> Element (ActionIs s) admittedBy msg
action =
    Action_.component


{-| See [`M3e.Element.BottomSheetAction.Is`](M3e.Element.BottomSheetAction#Is).
-}
type alias ActionIs s =
    Action_.Is s


{-| See [`M3e.Element.BottomSheetAction.Attrs`](M3e.Element.BottomSheetAction#Attrs).
-}
type alias ActionAttrs =
    Action_.Attrs


{-| See [`M3e.Element.BottomSheetAction.Builder`](M3e.Element.BottomSheetAction#Builder).
-}
type alias ActionBuilder attrCaps slotCaps msg kind =
    Action_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.BottomSheetAction.AttrCaps`](M3e.Element.BottomSheetAction#AttrCaps).
-}
type alias ActionAttrCaps =
    Action_.AttrCaps


{-| See [`M3e.Element.BottomSheetAction.SlotCaps`](M3e.Element.BottomSheetAction#SlotCaps).
-}
type alias ActionSlotCaps =
    Action_.SlotCaps


{-| See [`M3e.Element.BottomSheetAction.Content`](M3e.Element.BottomSheetAction#Content).
-}
type alias ActionContent =
    Action_.Content


{-| See [`M3e.Element.BottomSheetAction.ChildAdmittedBy`](M3e.Element.BottomSheetAction#ChildAdmittedBy).
-}
type alias ActionChildAdmittedBy childAdm =
    Action_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.BottomSheetAction.child`](M3e.Element.BottomSheetAction#child).
-}
actionChild : Element ActionContent admittedBy msg -> Element free freeAdmittedBy msg
actionChild =
    Action_.child


{-| The `trigger` element of this family — delegates to [`M3e.Element.BottomSheetTrigger.component`](M3e.Element.BottomSheetTrigger#component).
-}
trigger :
    List (Attr TriggerAttrs msg)
    -> List (Element TriggerContent (TriggerChildAdmittedBy childAdm) msg)
    -> Element (TriggerIs s) admittedBy msg
trigger =
    Trigger_.component


{-| See [`M3e.Element.BottomSheetTrigger.Is`](M3e.Element.BottomSheetTrigger#Is).
-}
type alias TriggerIs s =
    Trigger_.Is s


{-| See [`M3e.Element.BottomSheetTrigger.Attrs`](M3e.Element.BottomSheetTrigger#Attrs).
-}
type alias TriggerAttrs =
    Trigger_.Attrs


{-| See [`M3e.Element.BottomSheetTrigger.Builder`](M3e.Element.BottomSheetTrigger#Builder).
-}
type alias TriggerBuilder attrCaps slotCaps msg kind =
    Trigger_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.BottomSheetTrigger.AttrCaps`](M3e.Element.BottomSheetTrigger#AttrCaps).
-}
type alias TriggerAttrCaps =
    Trigger_.AttrCaps


{-| See [`M3e.Element.BottomSheetTrigger.SlotCaps`](M3e.Element.BottomSheetTrigger#SlotCaps).
-}
type alias TriggerSlotCaps =
    Trigger_.SlotCaps


{-| See [`M3e.Element.BottomSheetTrigger.Content`](M3e.Element.BottomSheetTrigger#Content).
-}
type alias TriggerContent =
    Trigger_.Content


{-| See [`M3e.Element.BottomSheetTrigger.ChildAdmittedBy`](M3e.Element.BottomSheetTrigger#ChildAdmittedBy).
-}
type alias TriggerChildAdmittedBy childAdm =
    Trigger_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.BottomSheetTrigger.detent`](M3e.Element.BottomSheetTrigger#detent).
-}
triggerDetent : Float -> Attr { c | detent : Supported } msg
triggerDetent =
    Trigger_.detent


{-| See [`M3e.Element.BottomSheetTrigger.for`](M3e.Element.BottomSheetTrigger#for).
-}
triggerFor : String -> Attr { c | for : Supported } msg
triggerFor =
    Trigger_.for


{-| See [`M3e.Element.BottomSheetTrigger.secondary`](M3e.Element.BottomSheetTrigger#secondary).
-}
triggerSecondary : Bool -> Attr { c | secondary : Supported } msg
triggerSecondary =
    Trigger_.secondary


{-| See [`M3e.Element.BottomSheetTrigger.child`](M3e.Element.BottomSheetTrigger#child).
-}
triggerChild : Element TriggerContent admittedBy msg -> Element free freeAdmittedBy msg
triggerChild =
    Trigger_.child
