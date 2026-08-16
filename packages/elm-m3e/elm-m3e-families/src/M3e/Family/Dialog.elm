module M3e.Family.Dialog exposing (DialogIs, DialogAttrs, DialogBuilder, DialogAttrCaps, DialogSlotCaps, DialogCloseIconSlot, DialogHeaderSlot, DialogChildAdmittedBy, ActionIs, ActionAttrs, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionChildAdmittedBy, TriggerIs, TriggerAttrs, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerChildAdmittedBy, dialog, dialogAlert, dialogCloseLabel, dialogDisableClose, dialogDismissible, dialogNoFocusTrap, dialogOpen, dialogOnOpening, dialogOnOpened, dialogOnClosing, dialogOnClosed, dialogOnCancel, dialogActions, dialogCloseIcon, dialogHeader, dialogChild, action, actionReturnValue, actionChild, trigger, triggerFor)

{-| The **Dialog** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.Dialog`](M3e.Component.Dialog) as `dialog`, [`M3e.Component.DialogAction`](M3e.Component.DialogAction) as `action`, [`M3e.Component.DialogTrigger`](M3e.Component.DialogTrigger) as `trigger`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs DialogIs, DialogAttrs, DialogBuilder, DialogAttrCaps, DialogSlotCaps, DialogCloseIconSlot, DialogHeaderSlot, DialogChildAdmittedBy, ActionIs, ActionAttrs, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionChildAdmittedBy, TriggerIs, TriggerAttrs, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerChildAdmittedBy, dialog, dialogAlert, dialogCloseLabel, dialogDisableClose, dialogDismissible, dialogNoFocusTrap, dialogOpen, dialogOnOpening, dialogOnOpened, dialogOnClosing, dialogOnClosed, dialogOnCancel, dialogActions, dialogCloseIcon, dialogHeader, dialogChild, action, actionReturnValue, actionChild, trigger, triggerFor

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Component.Dialog as Dialog_
import M3e.Component.DialogAction as Action_
import M3e.Component.DialogTrigger as Trigger_


{-| The `dialog` element of this family — delegates to [`M3e.Component.Dialog.component`](M3e.Component.Dialog#component).
-}
dialog :
    List (Attr DialogAttrs msg)
    -> List (Element childAccepts (DialogChildAdmittedBy childAdm) msg)
    -> Element (DialogIs s) admittedBy msg
dialog =
    Dialog_.component


{-| See [`M3e.Component.Dialog.Is`](M3e.Component.Dialog#Is).
-}
type alias DialogIs s =
    Dialog_.Is s


{-| See [`M3e.Component.Dialog.Attrs`](M3e.Component.Dialog#Attrs).
-}
type alias DialogAttrs =
    Dialog_.Attrs


{-| See [`M3e.Component.Dialog.Builder`](M3e.Component.Dialog#Builder).
-}
type alias DialogBuilder attrCaps slotCaps msg kind =
    Dialog_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.Dialog.AttrCaps`](M3e.Component.Dialog#AttrCaps).
-}
type alias DialogAttrCaps =
    Dialog_.AttrCaps


{-| See [`M3e.Component.Dialog.SlotCaps`](M3e.Component.Dialog#SlotCaps).
-}
type alias DialogSlotCaps =
    Dialog_.SlotCaps


{-| See [`M3e.Component.Dialog.CloseIconSlot`](M3e.Component.Dialog#CloseIconSlot).
-}
type alias DialogCloseIconSlot =
    Dialog_.CloseIconSlot


{-| See [`M3e.Component.Dialog.HeaderSlot`](M3e.Component.Dialog#HeaderSlot).
-}
type alias DialogHeaderSlot =
    Dialog_.HeaderSlot


{-| See [`M3e.Component.Dialog.ChildAdmittedBy`](M3e.Component.Dialog#ChildAdmittedBy).
-}
type alias DialogChildAdmittedBy childAdm =
    Dialog_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.Dialog.alert`](M3e.Component.Dialog#alert).
-}
dialogAlert : Bool -> Attr { c | alert : Supported } msg
dialogAlert =
    Dialog_.alert


{-| See [`M3e.Component.Dialog.closeLabel`](M3e.Component.Dialog#closeLabel).
-}
dialogCloseLabel : String -> Attr { c | closeLabel : Supported } msg
dialogCloseLabel =
    Dialog_.closeLabel


{-| See [`M3e.Component.Dialog.disableClose`](M3e.Component.Dialog#disableClose).
-}
dialogDisableClose : Bool -> Attr { c | disableClose : Supported } msg
dialogDisableClose =
    Dialog_.disableClose


{-| See [`M3e.Component.Dialog.dismissible`](M3e.Component.Dialog#dismissible).
-}
dialogDismissible : Bool -> Attr { c | dismissible : Supported } msg
dialogDismissible =
    Dialog_.dismissible


{-| See [`M3e.Component.Dialog.noFocusTrap`](M3e.Component.Dialog#noFocusTrap).
-}
dialogNoFocusTrap : Bool -> Attr { c | noFocusTrap : Supported } msg
dialogNoFocusTrap =
    Dialog_.noFocusTrap


{-| See [`M3e.Component.Dialog.open`](M3e.Component.Dialog#open).
-}
dialogOpen : Bool -> Attr { c | open : Supported } msg
dialogOpen =
    Dialog_.open


{-| See [`M3e.Component.Dialog.onOpening`](M3e.Component.Dialog#onOpening).
-}
dialogOnOpening : msg -> Attr { c | onOpening : Supported } msg
dialogOnOpening =
    Dialog_.onOpening


{-| See [`M3e.Component.Dialog.onOpened`](M3e.Component.Dialog#onOpened).
-}
dialogOnOpened : msg -> Attr { c | onOpened : Supported } msg
dialogOnOpened =
    Dialog_.onOpened


{-| See [`M3e.Component.Dialog.onClosing`](M3e.Component.Dialog#onClosing).
-}
dialogOnClosing : msg -> Attr { c | onClosing : Supported } msg
dialogOnClosing =
    Dialog_.onClosing


{-| See [`M3e.Component.Dialog.onClosed`](M3e.Component.Dialog#onClosed).
-}
dialogOnClosed : msg -> Attr { c | onClosed : Supported } msg
dialogOnClosed =
    Dialog_.onClosed


{-| See [`M3e.Component.Dialog.onCancel`](M3e.Component.Dialog#onCancel).
-}
dialogOnCancel : msg -> Attr { c | onCancel : Supported } msg
dialogOnCancel =
    Dialog_.onCancel


{-| See [`M3e.Component.Dialog.actions`](M3e.Component.Dialog#actions).
-}
dialogActions : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
dialogActions =
    Dialog_.actions


{-| See [`M3e.Component.Dialog.closeIcon`](M3e.Component.Dialog#closeIcon).
-}
dialogCloseIcon : Element DialogCloseIconSlot admittedBy msg -> Element free freeAdmittedBy msg
dialogCloseIcon =
    Dialog_.closeIcon


{-| See [`M3e.Component.Dialog.header`](M3e.Component.Dialog#header).
-}
dialogHeader : Element DialogHeaderSlot admittedBy msg -> Element free freeAdmittedBy msg
dialogHeader =
    Dialog_.header


{-| See [`M3e.Component.Dialog.child`](M3e.Component.Dialog#child).
-}
dialogChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
dialogChild =
    Dialog_.child


{-| The `action` element of this family — delegates to [`M3e.Component.DialogAction.component`](M3e.Component.DialogAction#component).
-}
action :
    List (Attr ActionAttrs msg)
    -> List (Element childAccepts (ActionChildAdmittedBy childAdm) msg)
    -> Element (ActionIs s) admittedBy msg
action =
    Action_.component


{-| See [`M3e.Component.DialogAction.Is`](M3e.Component.DialogAction#Is).
-}
type alias ActionIs s =
    Action_.Is s


{-| See [`M3e.Component.DialogAction.Attrs`](M3e.Component.DialogAction#Attrs).
-}
type alias ActionAttrs =
    Action_.Attrs


{-| See [`M3e.Component.DialogAction.Builder`](M3e.Component.DialogAction#Builder).
-}
type alias ActionBuilder attrCaps slotCaps msg kind =
    Action_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.DialogAction.AttrCaps`](M3e.Component.DialogAction#AttrCaps).
-}
type alias ActionAttrCaps =
    Action_.AttrCaps


{-| See [`M3e.Component.DialogAction.SlotCaps`](M3e.Component.DialogAction#SlotCaps).
-}
type alias ActionSlotCaps =
    Action_.SlotCaps


{-| See [`M3e.Component.DialogAction.ChildAdmittedBy`](M3e.Component.DialogAction#ChildAdmittedBy).
-}
type alias ActionChildAdmittedBy childAdm =
    Action_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.DialogAction.returnValue`](M3e.Component.DialogAction#returnValue).
-}
actionReturnValue : String -> Attr { c | returnValue : Supported } msg
actionReturnValue =
    Action_.returnValue


{-| See [`M3e.Component.DialogAction.child`](M3e.Component.DialogAction#child).
-}
actionChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
actionChild =
    Action_.child


{-| The `trigger` element of this family — delegates to [`M3e.Component.DialogTrigger.component`](M3e.Component.DialogTrigger#component).
-}
trigger :
    List (Attr TriggerAttrs msg)
    -> List (Element childAccepts (TriggerChildAdmittedBy childAdm) msg)
    -> Element (TriggerIs s) admittedBy msg
trigger =
    Trigger_.component


{-| See [`M3e.Component.DialogTrigger.Is`](M3e.Component.DialogTrigger#Is).
-}
type alias TriggerIs s =
    Trigger_.Is s


{-| See [`M3e.Component.DialogTrigger.Attrs`](M3e.Component.DialogTrigger#Attrs).
-}
type alias TriggerAttrs =
    Trigger_.Attrs


{-| See [`M3e.Component.DialogTrigger.Builder`](M3e.Component.DialogTrigger#Builder).
-}
type alias TriggerBuilder attrCaps slotCaps msg kind =
    Trigger_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.DialogTrigger.AttrCaps`](M3e.Component.DialogTrigger#AttrCaps).
-}
type alias TriggerAttrCaps =
    Trigger_.AttrCaps


{-| See [`M3e.Component.DialogTrigger.SlotCaps`](M3e.Component.DialogTrigger#SlotCaps).
-}
type alias TriggerSlotCaps =
    Trigger_.SlotCaps


{-| See [`M3e.Component.DialogTrigger.ChildAdmittedBy`](M3e.Component.DialogTrigger#ChildAdmittedBy).
-}
type alias TriggerChildAdmittedBy childAdm =
    Trigger_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.DialogTrigger.for`](M3e.Component.DialogTrigger#for).
-}
triggerFor : String -> Attr { c | for : Supported } msg
triggerFor =
    Trigger_.for
