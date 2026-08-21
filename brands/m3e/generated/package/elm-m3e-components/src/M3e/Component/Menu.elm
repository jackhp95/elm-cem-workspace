module M3e.Component.Menu exposing (MenuIs, MenuAttrs, MenuBuilder, MenuAttrCaps, MenuSlotCaps, MenuContent, MenuChildAdmittedBy, MenuPositionX, MenuPositionY, MenuVariant, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemIconSlot, ItemTrailingIconSlot, ItemChildAdmittedBy, ItemCheckboxIs, ItemCheckboxAttrs, ItemCheckboxBuilder, ItemCheckboxAttrCaps, ItemCheckboxSlotCaps, ItemCheckboxContent, ItemCheckboxIconSlot, ItemCheckboxTrailingIconSlot, ItemCheckboxChildAdmittedBy, ItemGroupIs, ItemGroupAttrs, ItemGroupBuilder, ItemGroupAttrCaps, ItemGroupSlotCaps, ItemGroupContent, ItemGroupChildAdmittedBy, ItemRadioIs, ItemRadioAttrs, ItemRadioBuilder, ItemRadioAttrCaps, ItemRadioSlotCaps, ItemRadioContent, ItemRadioIconSlot, ItemRadioTrailingIconSlot, ItemRadioChildAdmittedBy, TriggerIs, TriggerAttrs, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerChildAdmittedBy, menu, menuPositionX, menuPositionY, menuVariant, menuSubmenu, menuOnBeforetoggle, menuOnToggle, menuChild, item, itemDisabled, itemDownload, itemHref, itemRel, itemTarget, itemOnClick, itemIcon, itemTrailingIcon, itemChild, itemCheckbox, itemCheckboxChecked, itemCheckboxDisabled, itemCheckboxDefaultChecked, itemCheckboxOnClick, itemCheckboxIcon, itemCheckboxTrailingIcon, itemCheckboxChild, itemGroup, itemGroupChild, itemRadio, itemRadioChecked, itemRadioDisabled, itemRadioDefaultChecked, itemRadioOnClick, itemRadioIcon, itemRadioTrailingIcon, itemRadioChild, trigger, triggerFor, triggerChild)

{-| The **Menu** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Menu`](M3e.Element.Menu) as `menu`, [`M3e.Element.MenuItem`](M3e.Element.MenuItem) as `item`, [`M3e.Element.MenuItemCheckbox`](M3e.Element.MenuItemCheckbox) as `itemCheckbox`, [`M3e.Element.MenuItemGroup`](M3e.Element.MenuItemGroup) as `itemGroup`, [`M3e.Element.MenuItemRadio`](M3e.Element.MenuItemRadio) as `itemRadio`, [`M3e.Element.MenuTrigger`](M3e.Element.MenuTrigger) as `trigger`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs MenuIs, MenuAttrs, MenuBuilder, MenuAttrCaps, MenuSlotCaps, MenuContent, MenuChildAdmittedBy, MenuPositionX, MenuPositionY, MenuVariant, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemIconSlot, ItemTrailingIconSlot, ItemChildAdmittedBy, ItemCheckboxIs, ItemCheckboxAttrs, ItemCheckboxBuilder, ItemCheckboxAttrCaps, ItemCheckboxSlotCaps, ItemCheckboxContent, ItemCheckboxIconSlot, ItemCheckboxTrailingIconSlot, ItemCheckboxChildAdmittedBy, ItemGroupIs, ItemGroupAttrs, ItemGroupBuilder, ItemGroupAttrCaps, ItemGroupSlotCaps, ItemGroupContent, ItemGroupChildAdmittedBy, ItemRadioIs, ItemRadioAttrs, ItemRadioBuilder, ItemRadioAttrCaps, ItemRadioSlotCaps, ItemRadioContent, ItemRadioIconSlot, ItemRadioTrailingIconSlot, ItemRadioChildAdmittedBy, TriggerIs, TriggerAttrs, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerChildAdmittedBy, menu, menuPositionX, menuPositionY, menuVariant, menuSubmenu, menuOnBeforetoggle, menuOnToggle, menuChild, item, itemDisabled, itemDownload, itemHref, itemRel, itemTarget, itemOnClick, itemIcon, itemTrailingIcon, itemChild, itemCheckbox, itemCheckboxChecked, itemCheckboxDisabled, itemCheckboxDefaultChecked, itemCheckboxOnClick, itemCheckboxIcon, itemCheckboxTrailingIcon, itemCheckboxChild, itemGroup, itemGroupChild, itemRadio, itemRadioChecked, itemRadioDisabled, itemRadioDefaultChecked, itemRadioOnClick, itemRadioIcon, itemRadioTrailingIcon, itemRadioChild, trigger, triggerFor, triggerChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Menu as Menu_
import M3e.Element.MenuItem as Item_
import M3e.Element.MenuItemCheckbox as ItemCheckbox_
import M3e.Element.MenuItemGroup as ItemGroup_
import M3e.Element.MenuItemRadio as ItemRadio_
import M3e.Element.MenuTrigger as Trigger_


{-| The `menu` element of this family — delegates to [`M3e.Element.Menu.component`](M3e.Element.Menu#component).
-}
menu :
    List (Attr MenuAttrs msg)
    -> List (Element MenuContent (MenuChildAdmittedBy childAdm) msg)
    -> Element (MenuIs s) admittedBy msg
menu =
    Menu_.component


{-| See [`M3e.Element.Menu.Is`](M3e.Element.Menu#Is).
-}
type alias MenuIs s =
    Menu_.Is s


{-| See [`M3e.Element.Menu.Attrs`](M3e.Element.Menu#Attrs).
-}
type alias MenuAttrs =
    Menu_.Attrs


{-| See [`M3e.Element.Menu.Builder`](M3e.Element.Menu#Builder).
-}
type alias MenuBuilder attrCaps slotCaps msg kind =
    Menu_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Menu.AttrCaps`](M3e.Element.Menu#AttrCaps).
-}
type alias MenuAttrCaps =
    Menu_.AttrCaps


{-| See [`M3e.Element.Menu.SlotCaps`](M3e.Element.Menu#SlotCaps).
-}
type alias MenuSlotCaps =
    Menu_.SlotCaps


{-| See [`M3e.Element.Menu.Content`](M3e.Element.Menu#Content).
-}
type alias MenuContent =
    Menu_.Content


{-| See [`M3e.Element.Menu.ChildAdmittedBy`](M3e.Element.Menu#ChildAdmittedBy).
-}
type alias MenuChildAdmittedBy childAdm =
    Menu_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Menu.PositionX`](M3e.Element.Menu#PositionX).
-}
type alias MenuPositionX =
    Menu_.PositionX


{-| See [`M3e.Element.Menu.positionX`](M3e.Element.Menu#positionX).
-}
menuPositionX : Value MenuPositionX -> Attr { c | positionX : Supported } msg
menuPositionX =
    Menu_.positionX


{-| See [`M3e.Element.Menu.PositionY`](M3e.Element.Menu#PositionY).
-}
type alias MenuPositionY =
    Menu_.PositionY


{-| See [`M3e.Element.Menu.positionY`](M3e.Element.Menu#positionY).
-}
menuPositionY : Value MenuPositionY -> Attr { c | positionY : Supported } msg
menuPositionY =
    Menu_.positionY


{-| See [`M3e.Element.Menu.Variant`](M3e.Element.Menu#Variant).
-}
type alias MenuVariant =
    Menu_.Variant


{-| See [`M3e.Element.Menu.variant`](M3e.Element.Menu#variant).
-}
menuVariant : Value MenuVariant -> Attr { c | variant : Supported } msg
menuVariant =
    Menu_.variant


{-| See [`M3e.Element.Menu.submenu`](M3e.Element.Menu#submenu).
-}
menuSubmenu : Bool -> Attr { c | submenu : Supported } msg
menuSubmenu =
    Menu_.submenu


{-| See [`M3e.Element.Menu.onBeforetoggle`](M3e.Element.Menu#onBeforetoggle).
-}
menuOnBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
menuOnBeforetoggle =
    Menu_.onBeforetoggle


{-| See [`M3e.Element.Menu.onToggle`](M3e.Element.Menu#onToggle).
-}
menuOnToggle : (String -> msg) -> Attr { c | onToggle : Supported } msg
menuOnToggle =
    Menu_.onToggle


{-| See [`M3e.Element.Menu.child`](M3e.Element.Menu#child).
-}
menuChild : Element MenuContent admittedBy msg -> Element free freeAdmittedBy msg
menuChild =
    Menu_.child


{-| The `item` element of this family — delegates to [`M3e.Element.MenuItem.component`](M3e.Element.MenuItem#component).
-}
item :
    List (Attr ItemAttrs msg)
    -> List (Element ItemContent (ItemChildAdmittedBy childAdm) msg)
    -> Element (ItemIs s) admittedBy msg
item =
    Item_.component


{-| See [`M3e.Element.MenuItem.Is`](M3e.Element.MenuItem#Is).
-}
type alias ItemIs s =
    Item_.Is s


{-| See [`M3e.Element.MenuItem.Attrs`](M3e.Element.MenuItem#Attrs).
-}
type alias ItemAttrs =
    Item_.Attrs


{-| See [`M3e.Element.MenuItem.Builder`](M3e.Element.MenuItem#Builder).
-}
type alias ItemBuilder attrCaps slotCaps msg kind =
    Item_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.MenuItem.AttrCaps`](M3e.Element.MenuItem#AttrCaps).
-}
type alias ItemAttrCaps =
    Item_.AttrCaps


{-| See [`M3e.Element.MenuItem.SlotCaps`](M3e.Element.MenuItem#SlotCaps).
-}
type alias ItemSlotCaps =
    Item_.SlotCaps


{-| See [`M3e.Element.MenuItem.Content`](M3e.Element.MenuItem#Content).
-}
type alias ItemContent =
    Item_.Content


{-| See [`M3e.Element.MenuItem.IconSlot`](M3e.Element.MenuItem#IconSlot).
-}
type alias ItemIconSlot =
    Item_.IconSlot


{-| See [`M3e.Element.MenuItem.TrailingIconSlot`](M3e.Element.MenuItem#TrailingIconSlot).
-}
type alias ItemTrailingIconSlot =
    Item_.TrailingIconSlot


{-| See [`M3e.Element.MenuItem.ChildAdmittedBy`](M3e.Element.MenuItem#ChildAdmittedBy).
-}
type alias ItemChildAdmittedBy childAdm =
    Item_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.MenuItem.disabled`](M3e.Element.MenuItem#disabled).
-}
itemDisabled : Bool -> Attr { c | disabled : Supported } msg
itemDisabled =
    Item_.disabled


{-| See [`M3e.Element.MenuItem.download`](M3e.Element.MenuItem#download).
-}
itemDownload : String -> Attr { c | download : Supported } msg
itemDownload =
    Item_.download


{-| See [`M3e.Element.MenuItem.href`](M3e.Element.MenuItem#href).
-}
itemHref : String -> Attr { c | href : Supported } msg
itemHref =
    Item_.href


{-| See [`M3e.Element.MenuItem.rel`](M3e.Element.MenuItem#rel).
-}
itemRel : String -> Attr { c | rel : Supported } msg
itemRel =
    Item_.rel


{-| See [`M3e.Element.MenuItem.target`](M3e.Element.MenuItem#target).
-}
itemTarget : String -> Attr { c | target : Supported } msg
itemTarget =
    Item_.target


{-| See [`M3e.Element.MenuItem.onClick`](M3e.Element.MenuItem#onClick).
-}
itemOnClick : msg -> Attr { c | onClick : Supported } msg
itemOnClick =
    Item_.onClick


{-| See [`M3e.Element.MenuItem.icon`](M3e.Element.MenuItem#icon).
-}
itemIcon : Element ItemIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemIcon =
    Item_.icon


{-| See [`M3e.Element.MenuItem.trailingIcon`](M3e.Element.MenuItem#trailingIcon).
-}
itemTrailingIcon : Element ItemTrailingIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemTrailingIcon =
    Item_.trailingIcon


{-| See [`M3e.Element.MenuItem.child`](M3e.Element.MenuItem#child).
-}
itemChild : Element ItemContent admittedBy msg -> Element free freeAdmittedBy msg
itemChild =
    Item_.child


{-| The `itemCheckbox` element of this family — delegates to [`M3e.Element.MenuItemCheckbox.component`](M3e.Element.MenuItemCheckbox#component).
-}
itemCheckbox :
    List (Attr ItemCheckboxAttrs msg)
    -> List (Element ItemCheckboxContent (ItemCheckboxChildAdmittedBy childAdm) msg)
    -> Element (ItemCheckboxIs s) admittedBy msg
itemCheckbox =
    ItemCheckbox_.component


{-| See [`M3e.Element.MenuItemCheckbox.Is`](M3e.Element.MenuItemCheckbox#Is).
-}
type alias ItemCheckboxIs s =
    ItemCheckbox_.Is s


{-| See [`M3e.Element.MenuItemCheckbox.Attrs`](M3e.Element.MenuItemCheckbox#Attrs).
-}
type alias ItemCheckboxAttrs =
    ItemCheckbox_.Attrs


{-| See [`M3e.Element.MenuItemCheckbox.Builder`](M3e.Element.MenuItemCheckbox#Builder).
-}
type alias ItemCheckboxBuilder attrCaps slotCaps msg kind =
    ItemCheckbox_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.MenuItemCheckbox.AttrCaps`](M3e.Element.MenuItemCheckbox#AttrCaps).
-}
type alias ItemCheckboxAttrCaps =
    ItemCheckbox_.AttrCaps


{-| See [`M3e.Element.MenuItemCheckbox.SlotCaps`](M3e.Element.MenuItemCheckbox#SlotCaps).
-}
type alias ItemCheckboxSlotCaps =
    ItemCheckbox_.SlotCaps


{-| See [`M3e.Element.MenuItemCheckbox.Content`](M3e.Element.MenuItemCheckbox#Content).
-}
type alias ItemCheckboxContent =
    ItemCheckbox_.Content


{-| See [`M3e.Element.MenuItemCheckbox.IconSlot`](M3e.Element.MenuItemCheckbox#IconSlot).
-}
type alias ItemCheckboxIconSlot =
    ItemCheckbox_.IconSlot


{-| See [`M3e.Element.MenuItemCheckbox.TrailingIconSlot`](M3e.Element.MenuItemCheckbox#TrailingIconSlot).
-}
type alias ItemCheckboxTrailingIconSlot =
    ItemCheckbox_.TrailingIconSlot


{-| See [`M3e.Element.MenuItemCheckbox.ChildAdmittedBy`](M3e.Element.MenuItemCheckbox#ChildAdmittedBy).
-}
type alias ItemCheckboxChildAdmittedBy childAdm =
    ItemCheckbox_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.MenuItemCheckbox.checked`](M3e.Element.MenuItemCheckbox#checked).
-}
itemCheckboxChecked : Bool -> Attr { c | checked : Supported } msg
itemCheckboxChecked =
    ItemCheckbox_.checked


{-| See [`M3e.Element.MenuItemCheckbox.disabled`](M3e.Element.MenuItemCheckbox#disabled).
-}
itemCheckboxDisabled : Bool -> Attr { c | disabled : Supported } msg
itemCheckboxDisabled =
    ItemCheckbox_.disabled


{-| See [`M3e.Element.MenuItemCheckbox.defaultChecked`](M3e.Element.MenuItemCheckbox#defaultChecked).
-}
itemCheckboxDefaultChecked : Bool -> Attr { c | checked : Supported } msg
itemCheckboxDefaultChecked =
    ItemCheckbox_.defaultChecked


{-| See [`M3e.Element.MenuItemCheckbox.onClick`](M3e.Element.MenuItemCheckbox#onClick).
-}
itemCheckboxOnClick : msg -> Attr { c | onClick : Supported } msg
itemCheckboxOnClick =
    ItemCheckbox_.onClick


{-| See [`M3e.Element.MenuItemCheckbox.icon`](M3e.Element.MenuItemCheckbox#icon).
-}
itemCheckboxIcon : Element ItemCheckboxIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemCheckboxIcon =
    ItemCheckbox_.icon


{-| See [`M3e.Element.MenuItemCheckbox.trailingIcon`](M3e.Element.MenuItemCheckbox#trailingIcon).
-}
itemCheckboxTrailingIcon : Element ItemCheckboxTrailingIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemCheckboxTrailingIcon =
    ItemCheckbox_.trailingIcon


{-| See [`M3e.Element.MenuItemCheckbox.child`](M3e.Element.MenuItemCheckbox#child).
-}
itemCheckboxChild : Element ItemCheckboxContent admittedBy msg -> Element free freeAdmittedBy msg
itemCheckboxChild =
    ItemCheckbox_.child


{-| The `itemGroup` element of this family — delegates to [`M3e.Element.MenuItemGroup.component`](M3e.Element.MenuItemGroup#component).
-}
itemGroup :
    List (Attr ItemGroupAttrs msg)
    -> List (Element ItemGroupContent (ItemGroupChildAdmittedBy childAdm) msg)
    -> Element (ItemGroupIs s) admittedBy msg
itemGroup =
    ItemGroup_.component


{-| See [`M3e.Element.MenuItemGroup.Is`](M3e.Element.MenuItemGroup#Is).
-}
type alias ItemGroupIs s =
    ItemGroup_.Is s


{-| See [`M3e.Element.MenuItemGroup.Attrs`](M3e.Element.MenuItemGroup#Attrs).
-}
type alias ItemGroupAttrs =
    ItemGroup_.Attrs


{-| See [`M3e.Element.MenuItemGroup.Builder`](M3e.Element.MenuItemGroup#Builder).
-}
type alias ItemGroupBuilder attrCaps slotCaps msg kind =
    ItemGroup_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.MenuItemGroup.AttrCaps`](M3e.Element.MenuItemGroup#AttrCaps).
-}
type alias ItemGroupAttrCaps =
    ItemGroup_.AttrCaps


{-| See [`M3e.Element.MenuItemGroup.SlotCaps`](M3e.Element.MenuItemGroup#SlotCaps).
-}
type alias ItemGroupSlotCaps =
    ItemGroup_.SlotCaps


{-| See [`M3e.Element.MenuItemGroup.Content`](M3e.Element.MenuItemGroup#Content).
-}
type alias ItemGroupContent =
    ItemGroup_.Content


{-| See [`M3e.Element.MenuItemGroup.ChildAdmittedBy`](M3e.Element.MenuItemGroup#ChildAdmittedBy).
-}
type alias ItemGroupChildAdmittedBy childAdm =
    ItemGroup_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.MenuItemGroup.child`](M3e.Element.MenuItemGroup#child).
-}
itemGroupChild : Element ItemGroupContent admittedBy msg -> Element free freeAdmittedBy msg
itemGroupChild =
    ItemGroup_.child


{-| The `itemRadio` element of this family — delegates to [`M3e.Element.MenuItemRadio.component`](M3e.Element.MenuItemRadio#component).
-}
itemRadio :
    List (Attr ItemRadioAttrs msg)
    -> List (Element ItemRadioContent (ItemRadioChildAdmittedBy childAdm) msg)
    -> Element (ItemRadioIs s) admittedBy msg
itemRadio =
    ItemRadio_.component


{-| See [`M3e.Element.MenuItemRadio.Is`](M3e.Element.MenuItemRadio#Is).
-}
type alias ItemRadioIs s =
    ItemRadio_.Is s


{-| See [`M3e.Element.MenuItemRadio.Attrs`](M3e.Element.MenuItemRadio#Attrs).
-}
type alias ItemRadioAttrs =
    ItemRadio_.Attrs


{-| See [`M3e.Element.MenuItemRadio.Builder`](M3e.Element.MenuItemRadio#Builder).
-}
type alias ItemRadioBuilder attrCaps slotCaps msg kind =
    ItemRadio_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.MenuItemRadio.AttrCaps`](M3e.Element.MenuItemRadio#AttrCaps).
-}
type alias ItemRadioAttrCaps =
    ItemRadio_.AttrCaps


{-| See [`M3e.Element.MenuItemRadio.SlotCaps`](M3e.Element.MenuItemRadio#SlotCaps).
-}
type alias ItemRadioSlotCaps =
    ItemRadio_.SlotCaps


{-| See [`M3e.Element.MenuItemRadio.Content`](M3e.Element.MenuItemRadio#Content).
-}
type alias ItemRadioContent =
    ItemRadio_.Content


{-| See [`M3e.Element.MenuItemRadio.IconSlot`](M3e.Element.MenuItemRadio#IconSlot).
-}
type alias ItemRadioIconSlot =
    ItemRadio_.IconSlot


{-| See [`M3e.Element.MenuItemRadio.TrailingIconSlot`](M3e.Element.MenuItemRadio#TrailingIconSlot).
-}
type alias ItemRadioTrailingIconSlot =
    ItemRadio_.TrailingIconSlot


{-| See [`M3e.Element.MenuItemRadio.ChildAdmittedBy`](M3e.Element.MenuItemRadio#ChildAdmittedBy).
-}
type alias ItemRadioChildAdmittedBy childAdm =
    ItemRadio_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.MenuItemRadio.checked`](M3e.Element.MenuItemRadio#checked).
-}
itemRadioChecked : Bool -> Attr { c | checked : Supported } msg
itemRadioChecked =
    ItemRadio_.checked


{-| See [`M3e.Element.MenuItemRadio.disabled`](M3e.Element.MenuItemRadio#disabled).
-}
itemRadioDisabled : Bool -> Attr { c | disabled : Supported } msg
itemRadioDisabled =
    ItemRadio_.disabled


{-| See [`M3e.Element.MenuItemRadio.defaultChecked`](M3e.Element.MenuItemRadio#defaultChecked).
-}
itemRadioDefaultChecked : Bool -> Attr { c | checked : Supported } msg
itemRadioDefaultChecked =
    ItemRadio_.defaultChecked


{-| See [`M3e.Element.MenuItemRadio.onClick`](M3e.Element.MenuItemRadio#onClick).
-}
itemRadioOnClick : msg -> Attr { c | onClick : Supported } msg
itemRadioOnClick =
    ItemRadio_.onClick


{-| See [`M3e.Element.MenuItemRadio.icon`](M3e.Element.MenuItemRadio#icon).
-}
itemRadioIcon : Element ItemRadioIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemRadioIcon =
    ItemRadio_.icon


{-| See [`M3e.Element.MenuItemRadio.trailingIcon`](M3e.Element.MenuItemRadio#trailingIcon).
-}
itemRadioTrailingIcon : Element ItemRadioTrailingIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemRadioTrailingIcon =
    ItemRadio_.trailingIcon


{-| See [`M3e.Element.MenuItemRadio.child`](M3e.Element.MenuItemRadio#child).
-}
itemRadioChild : Element ItemRadioContent admittedBy msg -> Element free freeAdmittedBy msg
itemRadioChild =
    ItemRadio_.child


{-| The `trigger` element of this family — delegates to [`M3e.Element.MenuTrigger.component`](M3e.Element.MenuTrigger#component).
-}
trigger :
    List (Attr TriggerAttrs msg)
    -> List (Element childAccepts (TriggerChildAdmittedBy childAdm) msg)
    -> Element (TriggerIs s) admittedBy msg
trigger =
    Trigger_.component


{-| See [`M3e.Element.MenuTrigger.Is`](M3e.Element.MenuTrigger#Is).
-}
type alias TriggerIs s =
    Trigger_.Is s


{-| See [`M3e.Element.MenuTrigger.Attrs`](M3e.Element.MenuTrigger#Attrs).
-}
type alias TriggerAttrs =
    Trigger_.Attrs


{-| See [`M3e.Element.MenuTrigger.Builder`](M3e.Element.MenuTrigger#Builder).
-}
type alias TriggerBuilder attrCaps slotCaps msg kind =
    Trigger_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.MenuTrigger.AttrCaps`](M3e.Element.MenuTrigger#AttrCaps).
-}
type alias TriggerAttrCaps =
    Trigger_.AttrCaps


{-| See [`M3e.Element.MenuTrigger.SlotCaps`](M3e.Element.MenuTrigger#SlotCaps).
-}
type alias TriggerSlotCaps =
    Trigger_.SlotCaps


{-| See [`M3e.Element.MenuTrigger.ChildAdmittedBy`](M3e.Element.MenuTrigger#ChildAdmittedBy).
-}
type alias TriggerChildAdmittedBy childAdm =
    Trigger_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.MenuTrigger.for`](M3e.Element.MenuTrigger#for).
-}
triggerFor : String -> Attr { c | for : Supported } msg
triggerFor =
    Trigger_.for


{-| See [`M3e.Element.MenuTrigger.child`](M3e.Element.MenuTrigger#child).
-}
triggerChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
triggerChild =
    Trigger_.child
