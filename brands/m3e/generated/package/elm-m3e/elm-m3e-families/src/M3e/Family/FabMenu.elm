module M3e.Family.FabMenu exposing (FabMenuIs, FabMenuAttrs, FabMenuBuilder, FabMenuAttrCaps, FabMenuSlotCaps, FabMenuContent, FabMenuChildAdmittedBy, FabMenuVariant, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIconSlot, ItemChildAdmittedBy, TriggerIs, TriggerAttrs, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerChildAdmittedBy, fabMenu, fabMenuVariant, fabMenuOnBeforetoggle, fabMenuOnToggle, fabMenuChild, item, itemDisabled, itemDownload, itemHref, itemRel, itemTarget, itemOnClick, itemIcon, itemChild, trigger, triggerFor)

{-| The **FabMenu** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.FabMenu`](M3e.Component.FabMenu) as `fabMenu`, [`M3e.Component.FabMenuItem`](M3e.Component.FabMenuItem) as `item`, [`M3e.Component.FabMenuTrigger`](M3e.Component.FabMenuTrigger) as `trigger`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs FabMenuIs, FabMenuAttrs, FabMenuBuilder, FabMenuAttrCaps, FabMenuSlotCaps, FabMenuContent, FabMenuChildAdmittedBy, FabMenuVariant, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIconSlot, ItemChildAdmittedBy, TriggerIs, TriggerAttrs, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerChildAdmittedBy, fabMenu, fabMenuVariant, fabMenuOnBeforetoggle, fabMenuOnToggle, fabMenuChild, item, itemDisabled, itemDownload, itemHref, itemRel, itemTarget, itemOnClick, itemIcon, itemChild, trigger, triggerFor

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Component.FabMenu as FabMenu_
import M3e.Component.FabMenuItem as Item_
import M3e.Component.FabMenuTrigger as Trigger_


{-| The `fabMenu` element of this family — delegates to [`M3e.Component.FabMenu.component`](M3e.Component.FabMenu#component).
-}
fabMenu :
    List (Attr FabMenuAttrs msg)
    -> List (Element FabMenuContent (FabMenuChildAdmittedBy childAdm) msg)
    -> Element (FabMenuIs s) admittedBy msg
fabMenu =
    FabMenu_.component


{-| See [`M3e.Component.FabMenu.Is`](M3e.Component.FabMenu#Is).
-}
type alias FabMenuIs s =
    FabMenu_.Is s


{-| See [`M3e.Component.FabMenu.Attrs`](M3e.Component.FabMenu#Attrs).
-}
type alias FabMenuAttrs =
    FabMenu_.Attrs


{-| See [`M3e.Component.FabMenu.Builder`](M3e.Component.FabMenu#Builder).
-}
type alias FabMenuBuilder attrCaps slotCaps msg kind =
    FabMenu_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.FabMenu.AttrCaps`](M3e.Component.FabMenu#AttrCaps).
-}
type alias FabMenuAttrCaps =
    FabMenu_.AttrCaps


{-| See [`M3e.Component.FabMenu.SlotCaps`](M3e.Component.FabMenu#SlotCaps).
-}
type alias FabMenuSlotCaps =
    FabMenu_.SlotCaps


{-| See [`M3e.Component.FabMenu.Content`](M3e.Component.FabMenu#Content).
-}
type alias FabMenuContent =
    FabMenu_.Content


{-| See [`M3e.Component.FabMenu.ChildAdmittedBy`](M3e.Component.FabMenu#ChildAdmittedBy).
-}
type alias FabMenuChildAdmittedBy childAdm =
    FabMenu_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.FabMenu.Variant`](M3e.Component.FabMenu#Variant).
-}
type alias FabMenuVariant =
    FabMenu_.Variant


{-| See [`M3e.Component.FabMenu.variant`](M3e.Component.FabMenu#variant).
-}
fabMenuVariant : Value FabMenuVariant -> Attr { c | variant : Supported } msg
fabMenuVariant =
    FabMenu_.variant


{-| See [`M3e.Component.FabMenu.onBeforetoggle`](M3e.Component.FabMenu#onBeforetoggle).
-}
fabMenuOnBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
fabMenuOnBeforetoggle =
    FabMenu_.onBeforetoggle


{-| See [`M3e.Component.FabMenu.onToggle`](M3e.Component.FabMenu#onToggle).
-}
fabMenuOnToggle : msg -> Attr { c | onToggle : Supported } msg
fabMenuOnToggle =
    FabMenu_.onToggle


{-| See [`M3e.Component.FabMenu.child`](M3e.Component.FabMenu#child).
-}
fabMenuChild : Element FabMenuContent admittedBy msg -> Element free freeAdmittedBy msg
fabMenuChild =
    FabMenu_.child


{-| The `item` element of this family — delegates to [`M3e.Component.FabMenuItem.component`](M3e.Component.FabMenuItem#component).
-}
item :
    List (Attr ItemAttrs msg)
    -> List (Element childAccepts (ItemChildAdmittedBy childAdm) msg)
    -> Element (ItemIs s) admittedBy msg
item =
    Item_.component


{-| See [`M3e.Component.FabMenuItem.Is`](M3e.Component.FabMenuItem#Is).
-}
type alias ItemIs s =
    Item_.Is s


{-| See [`M3e.Component.FabMenuItem.Attrs`](M3e.Component.FabMenuItem#Attrs).
-}
type alias ItemAttrs =
    Item_.Attrs


{-| See [`M3e.Component.FabMenuItem.Builder`](M3e.Component.FabMenuItem#Builder).
-}
type alias ItemBuilder attrCaps slotCaps msg kind =
    Item_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.FabMenuItem.AttrCaps`](M3e.Component.FabMenuItem#AttrCaps).
-}
type alias ItemAttrCaps =
    Item_.AttrCaps


{-| See [`M3e.Component.FabMenuItem.SlotCaps`](M3e.Component.FabMenuItem#SlotCaps).
-}
type alias ItemSlotCaps =
    Item_.SlotCaps


{-| See [`M3e.Component.FabMenuItem.IconSlot`](M3e.Component.FabMenuItem#IconSlot).
-}
type alias ItemIconSlot =
    Item_.IconSlot


{-| See [`M3e.Component.FabMenuItem.ChildAdmittedBy`](M3e.Component.FabMenuItem#ChildAdmittedBy).
-}
type alias ItemChildAdmittedBy childAdm =
    Item_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.FabMenuItem.disabled`](M3e.Component.FabMenuItem#disabled).
-}
itemDisabled : Bool -> Attr { c | disabled : Supported } msg
itemDisabled =
    Item_.disabled


{-| See [`M3e.Component.FabMenuItem.download`](M3e.Component.FabMenuItem#download).
-}
itemDownload : String -> Attr { c | download : Supported } msg
itemDownload =
    Item_.download


{-| See [`M3e.Component.FabMenuItem.href`](M3e.Component.FabMenuItem#href).
-}
itemHref : String -> Attr { c | href : Supported } msg
itemHref =
    Item_.href


{-| See [`M3e.Component.FabMenuItem.rel`](M3e.Component.FabMenuItem#rel).
-}
itemRel : String -> Attr { c | rel : Supported } msg
itemRel =
    Item_.rel


{-| See [`M3e.Component.FabMenuItem.target`](M3e.Component.FabMenuItem#target).
-}
itemTarget : String -> Attr { c | target : Supported } msg
itemTarget =
    Item_.target


{-| See [`M3e.Component.FabMenuItem.onClick`](M3e.Component.FabMenuItem#onClick).
-}
itemOnClick : msg -> Attr { c | onClick : Supported } msg
itemOnClick =
    Item_.onClick


{-| See [`M3e.Component.FabMenuItem.icon`](M3e.Component.FabMenuItem#icon).
-}
itemIcon : Element ItemIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemIcon =
    Item_.icon


{-| See [`M3e.Component.FabMenuItem.child`](M3e.Component.FabMenuItem#child).
-}
itemChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
itemChild =
    Item_.child


{-| The `trigger` element of this family — delegates to [`M3e.Component.FabMenuTrigger.component`](M3e.Component.FabMenuTrigger#component).
-}
trigger :
    List (Attr TriggerAttrs msg)
    -> List (Element childAccepts (TriggerChildAdmittedBy childAdm) msg)
    -> Element (TriggerIs s) admittedBy msg
trigger =
    Trigger_.component


{-| See [`M3e.Component.FabMenuTrigger.Is`](M3e.Component.FabMenuTrigger#Is).
-}
type alias TriggerIs s =
    Trigger_.Is s


{-| See [`M3e.Component.FabMenuTrigger.Attrs`](M3e.Component.FabMenuTrigger#Attrs).
-}
type alias TriggerAttrs =
    Trigger_.Attrs


{-| See [`M3e.Component.FabMenuTrigger.Builder`](M3e.Component.FabMenuTrigger#Builder).
-}
type alias TriggerBuilder attrCaps slotCaps msg kind =
    Trigger_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.FabMenuTrigger.AttrCaps`](M3e.Component.FabMenuTrigger#AttrCaps).
-}
type alias TriggerAttrCaps =
    Trigger_.AttrCaps


{-| See [`M3e.Component.FabMenuTrigger.SlotCaps`](M3e.Component.FabMenuTrigger#SlotCaps).
-}
type alias TriggerSlotCaps =
    Trigger_.SlotCaps


{-| See [`M3e.Component.FabMenuTrigger.ChildAdmittedBy`](M3e.Component.FabMenuTrigger#ChildAdmittedBy).
-}
type alias TriggerChildAdmittedBy childAdm =
    Trigger_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.FabMenuTrigger.for`](M3e.Component.FabMenuTrigger#for).
-}
triggerFor : String -> Attr { c | for : Supported } msg
triggerFor =
    Trigger_.for
