module M3e.Family.NavMenu exposing (NavMenuIs, NavMenuAttrs, NavMenuBuilder, NavMenuAttrCaps, NavMenuSlotCaps, NavMenuContent, NavMenuChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemBadgeSlot, ItemIconSlot, ItemLabelSlot, ItemSelectedIconSlot, ItemToggleIconSlot, ItemChildAdmittedBy, ItemGroupIs, ItemGroupAttrs, ItemGroupBuilder, ItemGroupAttrCaps, ItemGroupSlotCaps, ItemGroupContent, ItemGroupLabelSlot, ItemGroupChildAdmittedBy, navMenu, navMenuChild, item, itemDisabled, itemOpen, itemSelected, itemDefaultSelected, itemOnOpening, itemOnOpened, itemOnClosing, itemOnClosed, itemOnClick, itemBadge, itemIcon, itemLabel, itemSelectedIcon, itemToggleIcon, itemChild, itemGroup, itemGroupLabel, itemGroupChild)

{-| The **NavMenu** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.NavMenu`](M3e.Component.NavMenu) as `navMenu`, [`M3e.Component.NavMenuItem`](M3e.Component.NavMenuItem) as `item`, [`M3e.Component.NavMenuItemGroup`](M3e.Component.NavMenuItemGroup) as `itemGroup`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs NavMenuIs, NavMenuAttrs, NavMenuBuilder, NavMenuAttrCaps, NavMenuSlotCaps, NavMenuContent, NavMenuChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemBadgeSlot, ItemIconSlot, ItemLabelSlot, ItemSelectedIconSlot, ItemToggleIconSlot, ItemChildAdmittedBy, ItemGroupIs, ItemGroupAttrs, ItemGroupBuilder, ItemGroupAttrCaps, ItemGroupSlotCaps, ItemGroupContent, ItemGroupLabelSlot, ItemGroupChildAdmittedBy, navMenu, navMenuChild, item, itemDisabled, itemOpen, itemSelected, itemDefaultSelected, itemOnOpening, itemOnOpened, itemOnClosing, itemOnClosed, itemOnClick, itemBadge, itemIcon, itemLabel, itemSelectedIcon, itemToggleIcon, itemChild, itemGroup, itemGroupLabel, itemGroupChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Component.NavMenu as NavMenu_
import M3e.Component.NavMenuItem as Item_
import M3e.Component.NavMenuItemGroup as ItemGroup_


{-| The `navMenu` element of this family — delegates to [`M3e.Component.NavMenu.component`](M3e.Component.NavMenu#component).
-}
navMenu :
    List (Attr NavMenuAttrs msg)
    -> List (Element NavMenuContent (NavMenuChildAdmittedBy childAdm) msg)
    -> Element (NavMenuIs s) admittedBy msg
navMenu =
    NavMenu_.component


{-| See [`M3e.Component.NavMenu.Is`](M3e.Component.NavMenu#Is).
-}
type alias NavMenuIs s =
    NavMenu_.Is s


{-| See [`M3e.Component.NavMenu.Attrs`](M3e.Component.NavMenu#Attrs).
-}
type alias NavMenuAttrs =
    NavMenu_.Attrs


{-| See [`M3e.Component.NavMenu.Builder`](M3e.Component.NavMenu#Builder).
-}
type alias NavMenuBuilder attrCaps slotCaps msg kind =
    NavMenu_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.NavMenu.AttrCaps`](M3e.Component.NavMenu#AttrCaps).
-}
type alias NavMenuAttrCaps =
    NavMenu_.AttrCaps


{-| See [`M3e.Component.NavMenu.SlotCaps`](M3e.Component.NavMenu#SlotCaps).
-}
type alias NavMenuSlotCaps =
    NavMenu_.SlotCaps


{-| See [`M3e.Component.NavMenu.Content`](M3e.Component.NavMenu#Content).
-}
type alias NavMenuContent =
    NavMenu_.Content


{-| See [`M3e.Component.NavMenu.ChildAdmittedBy`](M3e.Component.NavMenu#ChildAdmittedBy).
-}
type alias NavMenuChildAdmittedBy childAdm =
    NavMenu_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.NavMenu.child`](M3e.Component.NavMenu#child).
-}
navMenuChild : Element NavMenuContent admittedBy msg -> Element free freeAdmittedBy msg
navMenuChild =
    NavMenu_.child


{-| The `item` element of this family — delegates to [`M3e.Component.NavMenuItem.component`](M3e.Component.NavMenuItem#component).
-}
item :
    { label : Element ItemLabelSlot (ItemChildAdmittedBy childAdm) msg }
    -> List (Attr ItemAttrs msg)
    -> List (Element ItemContent (ItemChildAdmittedBy childAdm) msg)
    -> Element (ItemIs s) admittedBy msg
item =
    Item_.component


{-| See [`M3e.Component.NavMenuItem.Is`](M3e.Component.NavMenuItem#Is).
-}
type alias ItemIs s =
    Item_.Is s


{-| See [`M3e.Component.NavMenuItem.Attrs`](M3e.Component.NavMenuItem#Attrs).
-}
type alias ItemAttrs =
    Item_.Attrs


{-| See [`M3e.Component.NavMenuItem.Builder`](M3e.Component.NavMenuItem#Builder).
-}
type alias ItemBuilder attrCaps slotCaps msg kind =
    Item_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.NavMenuItem.AttrCaps`](M3e.Component.NavMenuItem#AttrCaps).
-}
type alias ItemAttrCaps =
    Item_.AttrCaps


{-| See [`M3e.Component.NavMenuItem.SlotCaps`](M3e.Component.NavMenuItem#SlotCaps).
-}
type alias ItemSlotCaps =
    Item_.SlotCaps


{-| See [`M3e.Component.NavMenuItem.Content`](M3e.Component.NavMenuItem#Content).
-}
type alias ItemContent =
    Item_.Content


{-| See [`M3e.Component.NavMenuItem.BadgeSlot`](M3e.Component.NavMenuItem#BadgeSlot).
-}
type alias ItemBadgeSlot =
    Item_.BadgeSlot


{-| See [`M3e.Component.NavMenuItem.IconSlot`](M3e.Component.NavMenuItem#IconSlot).
-}
type alias ItemIconSlot =
    Item_.IconSlot


{-| See [`M3e.Component.NavMenuItem.LabelSlot`](M3e.Component.NavMenuItem#LabelSlot).
-}
type alias ItemLabelSlot =
    Item_.LabelSlot


{-| See [`M3e.Component.NavMenuItem.SelectedIconSlot`](M3e.Component.NavMenuItem#SelectedIconSlot).
-}
type alias ItemSelectedIconSlot =
    Item_.SelectedIconSlot


{-| See [`M3e.Component.NavMenuItem.ToggleIconSlot`](M3e.Component.NavMenuItem#ToggleIconSlot).
-}
type alias ItemToggleIconSlot =
    Item_.ToggleIconSlot


{-| See [`M3e.Component.NavMenuItem.ChildAdmittedBy`](M3e.Component.NavMenuItem#ChildAdmittedBy).
-}
type alias ItemChildAdmittedBy childAdm =
    Item_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.NavMenuItem.disabled`](M3e.Component.NavMenuItem#disabled).
-}
itemDisabled : Bool -> Attr { c | disabled : Supported } msg
itemDisabled =
    Item_.disabled


{-| See [`M3e.Component.NavMenuItem.open`](M3e.Component.NavMenuItem#open).
-}
itemOpen : Bool -> Attr { c | open : Supported } msg
itemOpen =
    Item_.open


{-| See [`M3e.Component.NavMenuItem.selected`](M3e.Component.NavMenuItem#selected).
-}
itemSelected : Bool -> Attr { c | selected : Supported } msg
itemSelected =
    Item_.selected


{-| See [`M3e.Component.NavMenuItem.defaultSelected`](M3e.Component.NavMenuItem#defaultSelected).
-}
itemDefaultSelected : Bool -> Attr { c | selected : Supported } msg
itemDefaultSelected =
    Item_.defaultSelected


{-| See [`M3e.Component.NavMenuItem.onOpening`](M3e.Component.NavMenuItem#onOpening).
-}
itemOnOpening : msg -> Attr { c | onOpening : Supported } msg
itemOnOpening =
    Item_.onOpening


{-| See [`M3e.Component.NavMenuItem.onOpened`](M3e.Component.NavMenuItem#onOpened).
-}
itemOnOpened : msg -> Attr { c | onOpened : Supported } msg
itemOnOpened =
    Item_.onOpened


{-| See [`M3e.Component.NavMenuItem.onClosing`](M3e.Component.NavMenuItem#onClosing).
-}
itemOnClosing : msg -> Attr { c | onClosing : Supported } msg
itemOnClosing =
    Item_.onClosing


{-| See [`M3e.Component.NavMenuItem.onClosed`](M3e.Component.NavMenuItem#onClosed).
-}
itemOnClosed : msg -> Attr { c | onClosed : Supported } msg
itemOnClosed =
    Item_.onClosed


{-| See [`M3e.Component.NavMenuItem.onClick`](M3e.Component.NavMenuItem#onClick).
-}
itemOnClick : msg -> Attr { c | onClick : Supported } msg
itemOnClick =
    Item_.onClick


{-| See [`M3e.Component.NavMenuItem.badge`](M3e.Component.NavMenuItem#badge).
-}
itemBadge : Element ItemBadgeSlot admittedBy msg -> Element free freeAdmittedBy msg
itemBadge =
    Item_.badge


{-| See [`M3e.Component.NavMenuItem.icon`](M3e.Component.NavMenuItem#icon).
-}
itemIcon : Element ItemIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemIcon =
    Item_.icon


{-| See [`M3e.Component.NavMenuItem.label`](M3e.Component.NavMenuItem#label).
-}
itemLabel : Element ItemLabelSlot admittedBy msg -> Element free freeAdmittedBy msg
itemLabel =
    Item_.label


{-| See [`M3e.Component.NavMenuItem.selectedIcon`](M3e.Component.NavMenuItem#selectedIcon).
-}
itemSelectedIcon : Element ItemSelectedIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemSelectedIcon =
    Item_.selectedIcon


{-| See [`M3e.Component.NavMenuItem.toggleIcon`](M3e.Component.NavMenuItem#toggleIcon).
-}
itemToggleIcon : Element ItemToggleIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemToggleIcon =
    Item_.toggleIcon


{-| See [`M3e.Component.NavMenuItem.child`](M3e.Component.NavMenuItem#child).
-}
itemChild : Element ItemContent admittedBy msg -> Element free freeAdmittedBy msg
itemChild =
    Item_.child


{-| The `itemGroup` element of this family — delegates to [`M3e.Component.NavMenuItemGroup.component`](M3e.Component.NavMenuItemGroup#component).
-}
itemGroup :
    List (Attr ItemGroupAttrs msg)
    -> List (Element ItemGroupContent (ItemGroupChildAdmittedBy childAdm) msg)
    -> Element (ItemGroupIs s) admittedBy msg
itemGroup =
    ItemGroup_.component


{-| See [`M3e.Component.NavMenuItemGroup.Is`](M3e.Component.NavMenuItemGroup#Is).
-}
type alias ItemGroupIs s =
    ItemGroup_.Is s


{-| See [`M3e.Component.NavMenuItemGroup.Attrs`](M3e.Component.NavMenuItemGroup#Attrs).
-}
type alias ItemGroupAttrs =
    ItemGroup_.Attrs


{-| See [`M3e.Component.NavMenuItemGroup.Builder`](M3e.Component.NavMenuItemGroup#Builder).
-}
type alias ItemGroupBuilder attrCaps slotCaps msg kind =
    ItemGroup_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.NavMenuItemGroup.AttrCaps`](M3e.Component.NavMenuItemGroup#AttrCaps).
-}
type alias ItemGroupAttrCaps =
    ItemGroup_.AttrCaps


{-| See [`M3e.Component.NavMenuItemGroup.SlotCaps`](M3e.Component.NavMenuItemGroup#SlotCaps).
-}
type alias ItemGroupSlotCaps =
    ItemGroup_.SlotCaps


{-| See [`M3e.Component.NavMenuItemGroup.Content`](M3e.Component.NavMenuItemGroup#Content).
-}
type alias ItemGroupContent =
    ItemGroup_.Content


{-| See [`M3e.Component.NavMenuItemGroup.LabelSlot`](M3e.Component.NavMenuItemGroup#LabelSlot).
-}
type alias ItemGroupLabelSlot =
    ItemGroup_.LabelSlot


{-| See [`M3e.Component.NavMenuItemGroup.ChildAdmittedBy`](M3e.Component.NavMenuItemGroup#ChildAdmittedBy).
-}
type alias ItemGroupChildAdmittedBy childAdm =
    ItemGroup_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.NavMenuItemGroup.label`](M3e.Component.NavMenuItemGroup#label).
-}
itemGroupLabel : Element ItemGroupLabelSlot admittedBy msg -> Element free freeAdmittedBy msg
itemGroupLabel =
    ItemGroup_.label


{-| See [`M3e.Component.NavMenuItemGroup.child`](M3e.Component.NavMenuItemGroup#child).
-}
itemGroupChild : Element ItemGroupContent admittedBy msg -> Element free freeAdmittedBy msg
itemGroupChild =
    ItemGroup_.child
