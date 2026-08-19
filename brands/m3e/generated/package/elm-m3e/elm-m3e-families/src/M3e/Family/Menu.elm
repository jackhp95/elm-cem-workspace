module M3e.Family.Menu exposing (MenuIs, MenuAttrs, MenuBuilder, MenuAttrCaps, MenuSlotCaps, MenuContent, MenuChildAdmittedBy, MenuPositionX, MenuPositionY, MenuVariant, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemIconSlot, ItemTrailingIconSlot, ItemChildAdmittedBy, ItemCheckboxIs, ItemCheckboxAttrs, ItemCheckboxBuilder, ItemCheckboxAttrCaps, ItemCheckboxSlotCaps, ItemCheckboxContent, ItemCheckboxIconSlot, ItemCheckboxTrailingIconSlot, ItemCheckboxChildAdmittedBy, ItemGroupIs, ItemGroupAttrs, ItemGroupBuilder, ItemGroupAttrCaps, ItemGroupSlotCaps, ItemGroupContent, ItemGroupChildAdmittedBy, ItemRadioIs, ItemRadioAttrs, ItemRadioBuilder, ItemRadioAttrCaps, ItemRadioSlotCaps, ItemRadioContent, ItemRadioIconSlot, ItemRadioTrailingIconSlot, ItemRadioChildAdmittedBy, TriggerIs, TriggerAttrs, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerChildAdmittedBy, menu, menuPositionX, menuPositionY, menuVariant, menuSubmenu, menuOnBeforetoggle, menuOnToggle, menuChild, item, itemDisabled, itemDownload, itemHref, itemRel, itemTarget, itemOnClick, itemIcon, itemTrailingIcon, itemChild, itemCheckbox, itemCheckboxChecked, itemCheckboxDisabled, itemCheckboxDefaultChecked, itemCheckboxOnClick, itemCheckboxIcon, itemCheckboxTrailingIcon, itemCheckboxChild, itemGroup, itemGroupChild, itemRadio, itemRadioChecked, itemRadioDisabled, itemRadioDefaultChecked, itemRadioOnClick, itemRadioIcon, itemRadioTrailingIcon, itemRadioChild, trigger, triggerFor, triggerChild)

{-| The **Menu** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.Menu`](M3e.Component.Menu) as `menu`, [`M3e.Component.MenuItem`](M3e.Component.MenuItem) as `item`, [`M3e.Component.MenuItemCheckbox`](M3e.Component.MenuItemCheckbox) as `itemCheckbox`, [`M3e.Component.MenuItemGroup`](M3e.Component.MenuItemGroup) as `itemGroup`, [`M3e.Component.MenuItemRadio`](M3e.Component.MenuItemRadio) as `itemRadio`, [`M3e.Component.MenuTrigger`](M3e.Component.MenuTrigger) as `trigger`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs MenuIs, MenuAttrs, MenuBuilder, MenuAttrCaps, MenuSlotCaps, MenuContent, MenuChildAdmittedBy, MenuPositionX, MenuPositionY, MenuVariant, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemIconSlot, ItemTrailingIconSlot, ItemChildAdmittedBy, ItemCheckboxIs, ItemCheckboxAttrs, ItemCheckboxBuilder, ItemCheckboxAttrCaps, ItemCheckboxSlotCaps, ItemCheckboxContent, ItemCheckboxIconSlot, ItemCheckboxTrailingIconSlot, ItemCheckboxChildAdmittedBy, ItemGroupIs, ItemGroupAttrs, ItemGroupBuilder, ItemGroupAttrCaps, ItemGroupSlotCaps, ItemGroupContent, ItemGroupChildAdmittedBy, ItemRadioIs, ItemRadioAttrs, ItemRadioBuilder, ItemRadioAttrCaps, ItemRadioSlotCaps, ItemRadioContent, ItemRadioIconSlot, ItemRadioTrailingIconSlot, ItemRadioChildAdmittedBy, TriggerIs, TriggerAttrs, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerChildAdmittedBy, menu, menuPositionX, menuPositionY, menuVariant, menuSubmenu, menuOnBeforetoggle, menuOnToggle, menuChild, item, itemDisabled, itemDownload, itemHref, itemRel, itemTarget, itemOnClick, itemIcon, itemTrailingIcon, itemChild, itemCheckbox, itemCheckboxChecked, itemCheckboxDisabled, itemCheckboxDefaultChecked, itemCheckboxOnClick, itemCheckboxIcon, itemCheckboxTrailingIcon, itemCheckboxChild, itemGroup, itemGroupChild, itemRadio, itemRadioChecked, itemRadioDisabled, itemRadioDefaultChecked, itemRadioOnClick, itemRadioIcon, itemRadioTrailingIcon, itemRadioChild, trigger, triggerFor, triggerChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Component.Menu as Menu_
import M3e.Component.MenuItem as Item_
import M3e.Component.MenuItemCheckbox as ItemCheckbox_
import M3e.Component.MenuItemGroup as ItemGroup_
import M3e.Component.MenuItemRadio as ItemRadio_
import M3e.Component.MenuTrigger as Trigger_


{-| The `menu` element of this family — delegates to [`M3e.Component.Menu.component`](M3e.Component.Menu#component).
-}
menu :
    List (Attr MenuAttrs msg)
    -> List (Element MenuContent (MenuChildAdmittedBy childAdm) msg)
    -> Element (MenuIs s) admittedBy msg
menu =
    Menu_.component


{-| See [`M3e.Component.Menu.Is`](M3e.Component.Menu#Is).
-}
type alias MenuIs s =
    Menu_.Is s


{-| See [`M3e.Component.Menu.Attrs`](M3e.Component.Menu#Attrs).
-}
type alias MenuAttrs =
    Menu_.Attrs


{-| See [`M3e.Component.Menu.Builder`](M3e.Component.Menu#Builder).
-}
type alias MenuBuilder attrCaps slotCaps msg kind =
    Menu_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.Menu.AttrCaps`](M3e.Component.Menu#AttrCaps).
-}
type alias MenuAttrCaps =
    Menu_.AttrCaps


{-| See [`M3e.Component.Menu.SlotCaps`](M3e.Component.Menu#SlotCaps).
-}
type alias MenuSlotCaps =
    Menu_.SlotCaps


{-| See [`M3e.Component.Menu.Content`](M3e.Component.Menu#Content).
-}
type alias MenuContent =
    Menu_.Content


{-| See [`M3e.Component.Menu.ChildAdmittedBy`](M3e.Component.Menu#ChildAdmittedBy).
-}
type alias MenuChildAdmittedBy childAdm =
    Menu_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.Menu.PositionX`](M3e.Component.Menu#PositionX).
-}
type alias MenuPositionX =
    Menu_.PositionX


{-| See [`M3e.Component.Menu.positionX`](M3e.Component.Menu#positionX).
-}
menuPositionX : Value MenuPositionX -> Attr { c | positionX : Supported } msg
menuPositionX =
    Menu_.positionX


{-| See [`M3e.Component.Menu.PositionY`](M3e.Component.Menu#PositionY).
-}
type alias MenuPositionY =
    Menu_.PositionY


{-| See [`M3e.Component.Menu.positionY`](M3e.Component.Menu#positionY).
-}
menuPositionY : Value MenuPositionY -> Attr { c | positionY : Supported } msg
menuPositionY =
    Menu_.positionY


{-| See [`M3e.Component.Menu.Variant`](M3e.Component.Menu#Variant).
-}
type alias MenuVariant =
    Menu_.Variant


{-| See [`M3e.Component.Menu.variant`](M3e.Component.Menu#variant).
-}
menuVariant : Value MenuVariant -> Attr { c | variant : Supported } msg
menuVariant =
    Menu_.variant


{-| See [`M3e.Component.Menu.submenu`](M3e.Component.Menu#submenu).
-}
menuSubmenu : Bool -> Attr { c | submenu : Supported } msg
menuSubmenu =
    Menu_.submenu


{-| See [`M3e.Component.Menu.onBeforetoggle`](M3e.Component.Menu#onBeforetoggle).
-}
menuOnBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
menuOnBeforetoggle =
    Menu_.onBeforetoggle


{-| See [`M3e.Component.Menu.onToggle`](M3e.Component.Menu#onToggle).
-}
menuOnToggle : (String -> msg) -> Attr { c | onToggle : Supported } msg
menuOnToggle =
    Menu_.onToggle


{-| See [`M3e.Component.Menu.child`](M3e.Component.Menu#child).
-}
menuChild : Element MenuContent admittedBy msg -> Element free freeAdmittedBy msg
menuChild =
    Menu_.child


{-| The `item` element of this family — delegates to [`M3e.Component.MenuItem.component`](M3e.Component.MenuItem#component).
-}
item :
    List (Attr ItemAttrs msg)
    -> List (Element ItemContent (ItemChildAdmittedBy childAdm) msg)
    -> Element (ItemIs s) admittedBy msg
item =
    Item_.component


{-| See [`M3e.Component.MenuItem.Is`](M3e.Component.MenuItem#Is).
-}
type alias ItemIs s =
    Item_.Is s


{-| See [`M3e.Component.MenuItem.Attrs`](M3e.Component.MenuItem#Attrs).
-}
type alias ItemAttrs =
    Item_.Attrs


{-| See [`M3e.Component.MenuItem.Builder`](M3e.Component.MenuItem#Builder).
-}
type alias ItemBuilder attrCaps slotCaps msg kind =
    Item_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.MenuItem.AttrCaps`](M3e.Component.MenuItem#AttrCaps).
-}
type alias ItemAttrCaps =
    Item_.AttrCaps


{-| See [`M3e.Component.MenuItem.SlotCaps`](M3e.Component.MenuItem#SlotCaps).
-}
type alias ItemSlotCaps =
    Item_.SlotCaps


{-| See [`M3e.Component.MenuItem.Content`](M3e.Component.MenuItem#Content).
-}
type alias ItemContent =
    Item_.Content


{-| See [`M3e.Component.MenuItem.IconSlot`](M3e.Component.MenuItem#IconSlot).
-}
type alias ItemIconSlot =
    Item_.IconSlot


{-| See [`M3e.Component.MenuItem.TrailingIconSlot`](M3e.Component.MenuItem#TrailingIconSlot).
-}
type alias ItemTrailingIconSlot =
    Item_.TrailingIconSlot


{-| See [`M3e.Component.MenuItem.ChildAdmittedBy`](M3e.Component.MenuItem#ChildAdmittedBy).
-}
type alias ItemChildAdmittedBy childAdm =
    Item_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.MenuItem.disabled`](M3e.Component.MenuItem#disabled).
-}
itemDisabled : Bool -> Attr { c | disabled : Supported } msg
itemDisabled =
    Item_.disabled


{-| See [`M3e.Component.MenuItem.download`](M3e.Component.MenuItem#download).
-}
itemDownload : String -> Attr { c | download : Supported } msg
itemDownload =
    Item_.download


{-| See [`M3e.Component.MenuItem.href`](M3e.Component.MenuItem#href).
-}
itemHref : String -> Attr { c | href : Supported } msg
itemHref =
    Item_.href


{-| See [`M3e.Component.MenuItem.rel`](M3e.Component.MenuItem#rel).
-}
itemRel : String -> Attr { c | rel : Supported } msg
itemRel =
    Item_.rel


{-| See [`M3e.Component.MenuItem.target`](M3e.Component.MenuItem#target).
-}
itemTarget : String -> Attr { c | target : Supported } msg
itemTarget =
    Item_.target


{-| See [`M3e.Component.MenuItem.onClick`](M3e.Component.MenuItem#onClick).
-}
itemOnClick : msg -> Attr { c | onClick : Supported } msg
itemOnClick =
    Item_.onClick


{-| See [`M3e.Component.MenuItem.icon`](M3e.Component.MenuItem#icon).
-}
itemIcon : Element ItemIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemIcon =
    Item_.icon


{-| See [`M3e.Component.MenuItem.trailingIcon`](M3e.Component.MenuItem#trailingIcon).
-}
itemTrailingIcon : Element ItemTrailingIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemTrailingIcon =
    Item_.trailingIcon


{-| See [`M3e.Component.MenuItem.child`](M3e.Component.MenuItem#child).
-}
itemChild : Element ItemContent admittedBy msg -> Element free freeAdmittedBy msg
itemChild =
    Item_.child


{-| The `itemCheckbox` element of this family — delegates to [`M3e.Component.MenuItemCheckbox.component`](M3e.Component.MenuItemCheckbox#component).
-}
itemCheckbox :
    List (Attr ItemCheckboxAttrs msg)
    -> List (Element ItemCheckboxContent (ItemCheckboxChildAdmittedBy childAdm) msg)
    -> Element (ItemCheckboxIs s) admittedBy msg
itemCheckbox =
    ItemCheckbox_.component


{-| See [`M3e.Component.MenuItemCheckbox.Is`](M3e.Component.MenuItemCheckbox#Is).
-}
type alias ItemCheckboxIs s =
    ItemCheckbox_.Is s


{-| See [`M3e.Component.MenuItemCheckbox.Attrs`](M3e.Component.MenuItemCheckbox#Attrs).
-}
type alias ItemCheckboxAttrs =
    ItemCheckbox_.Attrs


{-| See [`M3e.Component.MenuItemCheckbox.Builder`](M3e.Component.MenuItemCheckbox#Builder).
-}
type alias ItemCheckboxBuilder attrCaps slotCaps msg kind =
    ItemCheckbox_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.MenuItemCheckbox.AttrCaps`](M3e.Component.MenuItemCheckbox#AttrCaps).
-}
type alias ItemCheckboxAttrCaps =
    ItemCheckbox_.AttrCaps


{-| See [`M3e.Component.MenuItemCheckbox.SlotCaps`](M3e.Component.MenuItemCheckbox#SlotCaps).
-}
type alias ItemCheckboxSlotCaps =
    ItemCheckbox_.SlotCaps


{-| See [`M3e.Component.MenuItemCheckbox.Content`](M3e.Component.MenuItemCheckbox#Content).
-}
type alias ItemCheckboxContent =
    ItemCheckbox_.Content


{-| See [`M3e.Component.MenuItemCheckbox.IconSlot`](M3e.Component.MenuItemCheckbox#IconSlot).
-}
type alias ItemCheckboxIconSlot =
    ItemCheckbox_.IconSlot


{-| See [`M3e.Component.MenuItemCheckbox.TrailingIconSlot`](M3e.Component.MenuItemCheckbox#TrailingIconSlot).
-}
type alias ItemCheckboxTrailingIconSlot =
    ItemCheckbox_.TrailingIconSlot


{-| See [`M3e.Component.MenuItemCheckbox.ChildAdmittedBy`](M3e.Component.MenuItemCheckbox#ChildAdmittedBy).
-}
type alias ItemCheckboxChildAdmittedBy childAdm =
    ItemCheckbox_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.MenuItemCheckbox.checked`](M3e.Component.MenuItemCheckbox#checked).
-}
itemCheckboxChecked : Bool -> Attr { c | checked : Supported } msg
itemCheckboxChecked =
    ItemCheckbox_.checked


{-| See [`M3e.Component.MenuItemCheckbox.disabled`](M3e.Component.MenuItemCheckbox#disabled).
-}
itemCheckboxDisabled : Bool -> Attr { c | disabled : Supported } msg
itemCheckboxDisabled =
    ItemCheckbox_.disabled


{-| See [`M3e.Component.MenuItemCheckbox.defaultChecked`](M3e.Component.MenuItemCheckbox#defaultChecked).
-}
itemCheckboxDefaultChecked : Bool -> Attr { c | checked : Supported } msg
itemCheckboxDefaultChecked =
    ItemCheckbox_.defaultChecked


{-| See [`M3e.Component.MenuItemCheckbox.onClick`](M3e.Component.MenuItemCheckbox#onClick).
-}
itemCheckboxOnClick : msg -> Attr { c | onClick : Supported } msg
itemCheckboxOnClick =
    ItemCheckbox_.onClick


{-| See [`M3e.Component.MenuItemCheckbox.icon`](M3e.Component.MenuItemCheckbox#icon).
-}
itemCheckboxIcon : Element ItemCheckboxIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemCheckboxIcon =
    ItemCheckbox_.icon


{-| See [`M3e.Component.MenuItemCheckbox.trailingIcon`](M3e.Component.MenuItemCheckbox#trailingIcon).
-}
itemCheckboxTrailingIcon : Element ItemCheckboxTrailingIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemCheckboxTrailingIcon =
    ItemCheckbox_.trailingIcon


{-| See [`M3e.Component.MenuItemCheckbox.child`](M3e.Component.MenuItemCheckbox#child).
-}
itemCheckboxChild : Element ItemCheckboxContent admittedBy msg -> Element free freeAdmittedBy msg
itemCheckboxChild =
    ItemCheckbox_.child


{-| The `itemGroup` element of this family — delegates to [`M3e.Component.MenuItemGroup.component`](M3e.Component.MenuItemGroup#component).
-}
itemGroup :
    List (Attr ItemGroupAttrs msg)
    -> List (Element ItemGroupContent (ItemGroupChildAdmittedBy childAdm) msg)
    -> Element (ItemGroupIs s) admittedBy msg
itemGroup =
    ItemGroup_.component


{-| See [`M3e.Component.MenuItemGroup.Is`](M3e.Component.MenuItemGroup#Is).
-}
type alias ItemGroupIs s =
    ItemGroup_.Is s


{-| See [`M3e.Component.MenuItemGroup.Attrs`](M3e.Component.MenuItemGroup#Attrs).
-}
type alias ItemGroupAttrs =
    ItemGroup_.Attrs


{-| See [`M3e.Component.MenuItemGroup.Builder`](M3e.Component.MenuItemGroup#Builder).
-}
type alias ItemGroupBuilder attrCaps slotCaps msg kind =
    ItemGroup_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.MenuItemGroup.AttrCaps`](M3e.Component.MenuItemGroup#AttrCaps).
-}
type alias ItemGroupAttrCaps =
    ItemGroup_.AttrCaps


{-| See [`M3e.Component.MenuItemGroup.SlotCaps`](M3e.Component.MenuItemGroup#SlotCaps).
-}
type alias ItemGroupSlotCaps =
    ItemGroup_.SlotCaps


{-| See [`M3e.Component.MenuItemGroup.Content`](M3e.Component.MenuItemGroup#Content).
-}
type alias ItemGroupContent =
    ItemGroup_.Content


{-| See [`M3e.Component.MenuItemGroup.ChildAdmittedBy`](M3e.Component.MenuItemGroup#ChildAdmittedBy).
-}
type alias ItemGroupChildAdmittedBy childAdm =
    ItemGroup_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.MenuItemGroup.child`](M3e.Component.MenuItemGroup#child).
-}
itemGroupChild : Element ItemGroupContent admittedBy msg -> Element free freeAdmittedBy msg
itemGroupChild =
    ItemGroup_.child


{-| The `itemRadio` element of this family — delegates to [`M3e.Component.MenuItemRadio.component`](M3e.Component.MenuItemRadio#component).
-}
itemRadio :
    List (Attr ItemRadioAttrs msg)
    -> List (Element ItemRadioContent (ItemRadioChildAdmittedBy childAdm) msg)
    -> Element (ItemRadioIs s) admittedBy msg
itemRadio =
    ItemRadio_.component


{-| See [`M3e.Component.MenuItemRadio.Is`](M3e.Component.MenuItemRadio#Is).
-}
type alias ItemRadioIs s =
    ItemRadio_.Is s


{-| See [`M3e.Component.MenuItemRadio.Attrs`](M3e.Component.MenuItemRadio#Attrs).
-}
type alias ItemRadioAttrs =
    ItemRadio_.Attrs


{-| See [`M3e.Component.MenuItemRadio.Builder`](M3e.Component.MenuItemRadio#Builder).
-}
type alias ItemRadioBuilder attrCaps slotCaps msg kind =
    ItemRadio_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.MenuItemRadio.AttrCaps`](M3e.Component.MenuItemRadio#AttrCaps).
-}
type alias ItemRadioAttrCaps =
    ItemRadio_.AttrCaps


{-| See [`M3e.Component.MenuItemRadio.SlotCaps`](M3e.Component.MenuItemRadio#SlotCaps).
-}
type alias ItemRadioSlotCaps =
    ItemRadio_.SlotCaps


{-| See [`M3e.Component.MenuItemRadio.Content`](M3e.Component.MenuItemRadio#Content).
-}
type alias ItemRadioContent =
    ItemRadio_.Content


{-| See [`M3e.Component.MenuItemRadio.IconSlot`](M3e.Component.MenuItemRadio#IconSlot).
-}
type alias ItemRadioIconSlot =
    ItemRadio_.IconSlot


{-| See [`M3e.Component.MenuItemRadio.TrailingIconSlot`](M3e.Component.MenuItemRadio#TrailingIconSlot).
-}
type alias ItemRadioTrailingIconSlot =
    ItemRadio_.TrailingIconSlot


{-| See [`M3e.Component.MenuItemRadio.ChildAdmittedBy`](M3e.Component.MenuItemRadio#ChildAdmittedBy).
-}
type alias ItemRadioChildAdmittedBy childAdm =
    ItemRadio_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.MenuItemRadio.checked`](M3e.Component.MenuItemRadio#checked).
-}
itemRadioChecked : Bool -> Attr { c | checked : Supported } msg
itemRadioChecked =
    ItemRadio_.checked


{-| See [`M3e.Component.MenuItemRadio.disabled`](M3e.Component.MenuItemRadio#disabled).
-}
itemRadioDisabled : Bool -> Attr { c | disabled : Supported } msg
itemRadioDisabled =
    ItemRadio_.disabled


{-| See [`M3e.Component.MenuItemRadio.defaultChecked`](M3e.Component.MenuItemRadio#defaultChecked).
-}
itemRadioDefaultChecked : Bool -> Attr { c | checked : Supported } msg
itemRadioDefaultChecked =
    ItemRadio_.defaultChecked


{-| See [`M3e.Component.MenuItemRadio.onClick`](M3e.Component.MenuItemRadio#onClick).
-}
itemRadioOnClick : msg -> Attr { c | onClick : Supported } msg
itemRadioOnClick =
    ItemRadio_.onClick


{-| See [`M3e.Component.MenuItemRadio.icon`](M3e.Component.MenuItemRadio#icon).
-}
itemRadioIcon : Element ItemRadioIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemRadioIcon =
    ItemRadio_.icon


{-| See [`M3e.Component.MenuItemRadio.trailingIcon`](M3e.Component.MenuItemRadio#trailingIcon).
-}
itemRadioTrailingIcon : Element ItemRadioTrailingIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemRadioTrailingIcon =
    ItemRadio_.trailingIcon


{-| See [`M3e.Component.MenuItemRadio.child`](M3e.Component.MenuItemRadio#child).
-}
itemRadioChild : Element ItemRadioContent admittedBy msg -> Element free freeAdmittedBy msg
itemRadioChild =
    ItemRadio_.child


{-| The `trigger` element of this family — delegates to [`M3e.Component.MenuTrigger.component`](M3e.Component.MenuTrigger#component).
-}
trigger :
    List (Attr TriggerAttrs msg)
    -> List (Element childAccepts (TriggerChildAdmittedBy childAdm) msg)
    -> Element (TriggerIs s) admittedBy msg
trigger =
    Trigger_.component


{-| See [`M3e.Component.MenuTrigger.Is`](M3e.Component.MenuTrigger#Is).
-}
type alias TriggerIs s =
    Trigger_.Is s


{-| See [`M3e.Component.MenuTrigger.Attrs`](M3e.Component.MenuTrigger#Attrs).
-}
type alias TriggerAttrs =
    Trigger_.Attrs


{-| See [`M3e.Component.MenuTrigger.Builder`](M3e.Component.MenuTrigger#Builder).
-}
type alias TriggerBuilder attrCaps slotCaps msg kind =
    Trigger_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.MenuTrigger.AttrCaps`](M3e.Component.MenuTrigger#AttrCaps).
-}
type alias TriggerAttrCaps =
    Trigger_.AttrCaps


{-| See [`M3e.Component.MenuTrigger.SlotCaps`](M3e.Component.MenuTrigger#SlotCaps).
-}
type alias TriggerSlotCaps =
    Trigger_.SlotCaps


{-| See [`M3e.Component.MenuTrigger.ChildAdmittedBy`](M3e.Component.MenuTrigger#ChildAdmittedBy).
-}
type alias TriggerChildAdmittedBy childAdm =
    Trigger_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.MenuTrigger.for`](M3e.Component.MenuTrigger#for).
-}
triggerFor : String -> Attr { c | for : Supported } msg
triggerFor =
    Trigger_.for


{-| See [`M3e.Component.MenuTrigger.child`](M3e.Component.MenuTrigger#child).
-}
triggerChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
triggerChild =
    Trigger_.child
