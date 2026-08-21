module M3e.Component.Dialog exposing (DialogIs, DialogAttrs, DialogBuilder, DialogAttrCaps, DialogSlotCaps, DialogCloseIconSlot, DialogHeaderSlot, DialogChildAdmittedBy, ActionIs, ActionAttrs, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionChildAdmittedBy, TriggerIs, TriggerAttrs, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerChildAdmittedBy, dialog, dialogAlert, dialogCloseLabel, dialogDisableClose, dialogDismissible, dialogNoFocusTrap, dialogOpen, dialogOnOpening, dialogOnOpened, dialogOnClosing, dialogOnClosed, dialogOnCancel, dialogActions, dialogCloseIcon, dialogHeader, dialogChild, action, actionReturnValue, actionChild, trigger, triggerFor)

{-| The **Dialog** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Dialog`](M3e.Element.Dialog) as `dialog`, [`M3e.Element.DialogAction`](M3e.Element.DialogAction) as `action`, [`M3e.Element.DialogTrigger`](M3e.Element.DialogTrigger) as `trigger`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs DialogIs, DialogAttrs, DialogBuilder, DialogAttrCaps, DialogSlotCaps, DialogCloseIconSlot, DialogHeaderSlot, DialogChildAdmittedBy, ActionIs, ActionAttrs, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionChildAdmittedBy, TriggerIs, TriggerAttrs, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerChildAdmittedBy, dialog, dialogAlert, dialogCloseLabel, dialogDisableClose, dialogDismissible, dialogNoFocusTrap, dialogOpen, dialogOnOpening, dialogOnOpened, dialogOnClosing, dialogOnClosed, dialogOnCancel, dialogActions, dialogCloseIcon, dialogHeader, dialogChild, action, actionReturnValue, actionChild, trigger, triggerFor

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.Dialog as Dialog_
import M3e.Element.DialogAction as Action_
import M3e.Element.DialogTrigger as Trigger_


{-| The `dialog` element of this family — delegates to [`M3e.Element.Dialog.component`](M3e.Element.Dialog#component).
-}
dialog :
    List (Attr DialogAttrs msg)
    -> List (Element childAccepts (DialogChildAdmittedBy childAdm) msg)
    -> Element (DialogIs s) admittedBy msg
dialog =
    Dialog_.component


{-| See [`M3e.Element.Dialog.Is`](M3e.Element.Dialog#Is).
-}
type alias DialogIs s =
    Dialog_.Is s


{-| See [`M3e.Element.Dialog.Attrs`](M3e.Element.Dialog#Attrs).
-}
type alias DialogAttrs =
    Dialog_.Attrs


{-| See [`M3e.Element.Dialog.Builder`](M3e.Element.Dialog#Builder).
-}
type alias DialogBuilder attrCaps slotCaps msg kind =
    Dialog_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Dialog.AttrCaps`](M3e.Element.Dialog#AttrCaps).
-}
type alias DialogAttrCaps =
    Dialog_.AttrCaps


{-| See [`M3e.Element.Dialog.SlotCaps`](M3e.Element.Dialog#SlotCaps).
-}
type alias DialogSlotCaps =
    Dialog_.SlotCaps


{-| See [`M3e.Element.Dialog.CloseIconSlot`](M3e.Element.Dialog#CloseIconSlot).
-}
type alias DialogCloseIconSlot =
    Dialog_.CloseIconSlot


{-| See [`M3e.Element.Dialog.HeaderSlot`](M3e.Element.Dialog#HeaderSlot).
-}
type alias DialogHeaderSlot =
    Dialog_.HeaderSlot


{-| See [`M3e.Element.Dialog.ChildAdmittedBy`](M3e.Element.Dialog#ChildAdmittedBy).
-}
type alias DialogChildAdmittedBy childAdm =
    Dialog_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Dialog.alert`](M3e.Element.Dialog#alert).
-}
dialogAlert : Bool -> Attr { c | alert : Supported } msg
dialogAlert =
    Dialog_.alert


{-| See [`M3e.Element.Dialog.closeLabel`](M3e.Element.Dialog#closeLabel).
-}
dialogCloseLabel : String -> Attr { c | closeLabel : Supported } msg
dialogCloseLabel =
    Dialog_.closeLabel


{-| See [`M3e.Element.Dialog.disableClose`](M3e.Element.Dialog#disableClose).
-}
dialogDisableClose : Bool -> Attr { c | disableClose : Supported } msg
dialogDisableClose =
    Dialog_.disableClose


{-| See [`M3e.Element.Dialog.dismissible`](M3e.Element.Dialog#dismissible).
-}
dialogDismissible : Bool -> Attr { c | dismissible : Supported } msg
dialogDismissible =
    Dialog_.dismissible


{-| See [`M3e.Element.Dialog.noFocusTrap`](M3e.Element.Dialog#noFocusTrap).
-}
dialogNoFocusTrap : Bool -> Attr { c | noFocusTrap : Supported } msg
dialogNoFocusTrap =
    Dialog_.noFocusTrap


{-| See [`M3e.Element.Dialog.open`](M3e.Element.Dialog#open).
-}
dialogOpen : Bool -> Attr { c | open : Supported } msg
dialogOpen =
    Dialog_.open


{-| See [`M3e.Element.Dialog.onOpening`](M3e.Element.Dialog#onOpening).
-}
dialogOnOpening : msg -> Attr { c | onOpening : Supported } msg
dialogOnOpening =
    Dialog_.onOpening


{-| See [`M3e.Element.Dialog.onOpened`](M3e.Element.Dialog#onOpened).
-}
dialogOnOpened : msg -> Attr { c | onOpened : Supported } msg
dialogOnOpened =
    Dialog_.onOpened


{-| See [`M3e.Element.Dialog.onClosing`](M3e.Element.Dialog#onClosing).
-}
dialogOnClosing : msg -> Attr { c | onClosing : Supported } msg
dialogOnClosing =
    Dialog_.onClosing


{-| See [`M3e.Element.Dialog.onClosed`](M3e.Element.Dialog#onClosed).
-}
dialogOnClosed : msg -> Attr { c | onClosed : Supported } msg
dialogOnClosed =
    Dialog_.onClosed


{-| See [`M3e.Element.Dialog.onCancel`](M3e.Element.Dialog#onCancel).
-}
dialogOnCancel : msg -> Attr { c | onCancel : Supported } msg
dialogOnCancel =
    Dialog_.onCancel


{-| See [`M3e.Element.Dialog.actions`](M3e.Element.Dialog#actions).
-}
dialogActions : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
dialogActions =
    Dialog_.actions


{-| See [`M3e.Element.Dialog.closeIcon`](M3e.Element.Dialog#closeIcon).
-}
dialogCloseIcon : Element DialogCloseIconSlot admittedBy msg -> Element free freeAdmittedBy msg
dialogCloseIcon =
    Dialog_.closeIcon


{-| See [`M3e.Element.Dialog.header`](M3e.Element.Dialog#header).
-}
dialogHeader : Element DialogHeaderSlot admittedBy msg -> Element free freeAdmittedBy msg
dialogHeader =
    Dialog_.header


{-| See [`M3e.Element.Dialog.child`](M3e.Element.Dialog#child).
-}
dialogChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
dialogChild =
    Dialog_.child


{-| The `action` element of this family — delegates to [`M3e.Element.DialogAction.component`](M3e.Element.DialogAction#component).
-}
action :
    List (Attr ActionAttrs msg)
    -> List (Element childAccepts (ActionChildAdmittedBy childAdm) msg)
    -> Element (ActionIs s) admittedBy msg
action =
    Action_.component


{-| See [`M3e.Element.DialogAction.Is`](M3e.Element.DialogAction#Is).
-}
type alias ActionIs s =
    Action_.Is s


{-| See [`M3e.Element.DialogAction.Attrs`](M3e.Element.DialogAction#Attrs).
-}
type alias ActionAttrs =
    Action_.Attrs


{-| See [`M3e.Element.DialogAction.Builder`](M3e.Element.DialogAction#Builder).
-}
type alias ActionBuilder attrCaps slotCaps msg kind =
    Action_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.DialogAction.AttrCaps`](M3e.Element.DialogAction#AttrCaps).
-}
type alias ActionAttrCaps =
    Action_.AttrCaps


{-| See [`M3e.Element.DialogAction.SlotCaps`](M3e.Element.DialogAction#SlotCaps).
-}
type alias ActionSlotCaps =
    Action_.SlotCaps


{-| See [`M3e.Element.DialogAction.ChildAdmittedBy`](M3e.Element.DialogAction#ChildAdmittedBy).
-}
type alias ActionChildAdmittedBy childAdm =
    Action_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.DialogAction.returnValue`](M3e.Element.DialogAction#returnValue).
-}
actionReturnValue : String -> Attr { c | returnValue : Supported } msg
actionReturnValue =
    Action_.returnValue


{-| See [`M3e.Element.DialogAction.child`](M3e.Element.DialogAction#child).
-}
actionChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
actionChild =
    Action_.child


{-| The `trigger` element of this family — delegates to [`M3e.Element.DialogTrigger.component`](M3e.Element.DialogTrigger#component).
-}
trigger :
    List (Attr TriggerAttrs msg)
    -> List (Element childAccepts (TriggerChildAdmittedBy childAdm) msg)
    -> Element (TriggerIs s) admittedBy msg
trigger =
    Trigger_.component


{-| See [`M3e.Element.DialogTrigger.Is`](M3e.Element.DialogTrigger#Is).
-}
type alias TriggerIs s =
    Trigger_.Is s


{-| See [`M3e.Element.DialogTrigger.Attrs`](M3e.Element.DialogTrigger#Attrs).
-}
type alias TriggerAttrs =
    Trigger_.Attrs


{-| See [`M3e.Element.DialogTrigger.Builder`](M3e.Element.DialogTrigger#Builder).
-}
type alias TriggerBuilder attrCaps slotCaps msg kind =
    Trigger_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.DialogTrigger.AttrCaps`](M3e.Element.DialogTrigger#AttrCaps).
-}
type alias TriggerAttrCaps =
    Trigger_.AttrCaps


{-| See [`M3e.Element.DialogTrigger.SlotCaps`](M3e.Element.DialogTrigger#SlotCaps).
-}
type alias TriggerSlotCaps =
    Trigger_.SlotCaps


{-| See [`M3e.Element.DialogTrigger.ChildAdmittedBy`](M3e.Element.DialogTrigger#ChildAdmittedBy).
-}
type alias TriggerChildAdmittedBy childAdm =
    Trigger_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.DialogTrigger.for`](M3e.Element.DialogTrigger#for).
-}
triggerFor : String -> Attr { c | for : Supported } msg
triggerFor =
    Trigger_.for
