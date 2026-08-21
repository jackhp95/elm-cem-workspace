module M3e.Component.NavMenu exposing (NavMenuIs, NavMenuAttrs, NavMenuBuilder, NavMenuAttrCaps, NavMenuSlotCaps, NavMenuContent, NavMenuChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemBadgeSlot, ItemIconSlot, ItemLabelSlot, ItemSelectedIconSlot, ItemToggleIconSlot, ItemChildAdmittedBy, ItemGroupIs, ItemGroupAttrs, ItemGroupBuilder, ItemGroupAttrCaps, ItemGroupSlotCaps, ItemGroupContent, ItemGroupLabelSlot, ItemGroupChildAdmittedBy, navMenu, navMenuChild, item, itemDisabled, itemOpen, itemSelected, itemDefaultSelected, itemOnOpening, itemOnOpened, itemOnClosing, itemOnClosed, itemOnClick, itemBadge, itemIcon, itemLabel, itemSelectedIcon, itemToggleIcon, itemChild, itemGroup, itemGroupLabel, itemGroupChild)

{-| The **NavMenu** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.NavMenu`](M3e.Element.NavMenu) as `navMenu`, [`M3e.Element.NavMenuItem`](M3e.Element.NavMenuItem) as `item`, [`M3e.Element.NavMenuItemGroup`](M3e.Element.NavMenuItemGroup) as `itemGroup`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs NavMenuIs, NavMenuAttrs, NavMenuBuilder, NavMenuAttrCaps, NavMenuSlotCaps, NavMenuContent, NavMenuChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemBadgeSlot, ItemIconSlot, ItemLabelSlot, ItemSelectedIconSlot, ItemToggleIconSlot, ItemChildAdmittedBy, ItemGroupIs, ItemGroupAttrs, ItemGroupBuilder, ItemGroupAttrCaps, ItemGroupSlotCaps, ItemGroupContent, ItemGroupLabelSlot, ItemGroupChildAdmittedBy, navMenu, navMenuChild, item, itemDisabled, itemOpen, itemSelected, itemDefaultSelected, itemOnOpening, itemOnOpened, itemOnClosing, itemOnClosed, itemOnClick, itemBadge, itemIcon, itemLabel, itemSelectedIcon, itemToggleIcon, itemChild, itemGroup, itemGroupLabel, itemGroupChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.NavMenu as NavMenu_
import M3e.Element.NavMenuItem as Item_
import M3e.Element.NavMenuItemGroup as ItemGroup_


{-| The `navMenu` element of this family — delegates to [`M3e.Element.NavMenu.component`](M3e.Element.NavMenu#component).
-}
navMenu :
    List (Attr NavMenuAttrs msg)
    -> List (Element NavMenuContent (NavMenuChildAdmittedBy childAdm) msg)
    -> Element (NavMenuIs s) admittedBy msg
navMenu =
    NavMenu_.component


{-| See [`M3e.Element.NavMenu.Is`](M3e.Element.NavMenu#Is).
-}
type alias NavMenuIs s =
    NavMenu_.Is s


{-| See [`M3e.Element.NavMenu.Attrs`](M3e.Element.NavMenu#Attrs).
-}
type alias NavMenuAttrs =
    NavMenu_.Attrs


{-| See [`M3e.Element.NavMenu.Builder`](M3e.Element.NavMenu#Builder).
-}
type alias NavMenuBuilder attrCaps slotCaps msg kind =
    NavMenu_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.NavMenu.AttrCaps`](M3e.Element.NavMenu#AttrCaps).
-}
type alias NavMenuAttrCaps =
    NavMenu_.AttrCaps


{-| See [`M3e.Element.NavMenu.SlotCaps`](M3e.Element.NavMenu#SlotCaps).
-}
type alias NavMenuSlotCaps =
    NavMenu_.SlotCaps


{-| See [`M3e.Element.NavMenu.Content`](M3e.Element.NavMenu#Content).
-}
type alias NavMenuContent =
    NavMenu_.Content


{-| See [`M3e.Element.NavMenu.ChildAdmittedBy`](M3e.Element.NavMenu#ChildAdmittedBy).
-}
type alias NavMenuChildAdmittedBy childAdm =
    NavMenu_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.NavMenu.child`](M3e.Element.NavMenu#child).
-}
navMenuChild : Element NavMenuContent admittedBy msg -> Element free freeAdmittedBy msg
navMenuChild =
    NavMenu_.child


{-| The `item` element of this family — delegates to [`M3e.Element.NavMenuItem.component`](M3e.Element.NavMenuItem#component).
-}
item :
    { label : Element ItemLabelSlot (ItemChildAdmittedBy childAdm) msg }
    -> List (Attr ItemAttrs msg)
    -> List (Element ItemContent (ItemChildAdmittedBy childAdm) msg)
    -> Element (ItemIs s) admittedBy msg
item =
    Item_.component


{-| See [`M3e.Element.NavMenuItem.Is`](M3e.Element.NavMenuItem#Is).
-}
type alias ItemIs s =
    Item_.Is s


{-| See [`M3e.Element.NavMenuItem.Attrs`](M3e.Element.NavMenuItem#Attrs).
-}
type alias ItemAttrs =
    Item_.Attrs


{-| See [`M3e.Element.NavMenuItem.Builder`](M3e.Element.NavMenuItem#Builder).
-}
type alias ItemBuilder attrCaps slotCaps msg kind =
    Item_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.NavMenuItem.AttrCaps`](M3e.Element.NavMenuItem#AttrCaps).
-}
type alias ItemAttrCaps =
    Item_.AttrCaps


{-| See [`M3e.Element.NavMenuItem.SlotCaps`](M3e.Element.NavMenuItem#SlotCaps).
-}
type alias ItemSlotCaps =
    Item_.SlotCaps


{-| See [`M3e.Element.NavMenuItem.Content`](M3e.Element.NavMenuItem#Content).
-}
type alias ItemContent =
    Item_.Content


{-| See [`M3e.Element.NavMenuItem.BadgeSlot`](M3e.Element.NavMenuItem#BadgeSlot).
-}
type alias ItemBadgeSlot =
    Item_.BadgeSlot


{-| See [`M3e.Element.NavMenuItem.IconSlot`](M3e.Element.NavMenuItem#IconSlot).
-}
type alias ItemIconSlot =
    Item_.IconSlot


{-| See [`M3e.Element.NavMenuItem.LabelSlot`](M3e.Element.NavMenuItem#LabelSlot).
-}
type alias ItemLabelSlot =
    Item_.LabelSlot


{-| See [`M3e.Element.NavMenuItem.SelectedIconSlot`](M3e.Element.NavMenuItem#SelectedIconSlot).
-}
type alias ItemSelectedIconSlot =
    Item_.SelectedIconSlot


{-| See [`M3e.Element.NavMenuItem.ToggleIconSlot`](M3e.Element.NavMenuItem#ToggleIconSlot).
-}
type alias ItemToggleIconSlot =
    Item_.ToggleIconSlot


{-| See [`M3e.Element.NavMenuItem.ChildAdmittedBy`](M3e.Element.NavMenuItem#ChildAdmittedBy).
-}
type alias ItemChildAdmittedBy childAdm =
    Item_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.NavMenuItem.disabled`](M3e.Element.NavMenuItem#disabled).
-}
itemDisabled : Bool -> Attr { c | disabled : Supported } msg
itemDisabled =
    Item_.disabled


{-| See [`M3e.Element.NavMenuItem.open`](M3e.Element.NavMenuItem#open).
-}
itemOpen : Bool -> Attr { c | open : Supported } msg
itemOpen =
    Item_.open


{-| See [`M3e.Element.NavMenuItem.selected`](M3e.Element.NavMenuItem#selected).
-}
itemSelected : Bool -> Attr { c | selected : Supported } msg
itemSelected =
    Item_.selected


{-| See [`M3e.Element.NavMenuItem.defaultSelected`](M3e.Element.NavMenuItem#defaultSelected).
-}
itemDefaultSelected : Bool -> Attr { c | selected : Supported } msg
itemDefaultSelected =
    Item_.defaultSelected


{-| See [`M3e.Element.NavMenuItem.onOpening`](M3e.Element.NavMenuItem#onOpening).
-}
itemOnOpening : msg -> Attr { c | onOpening : Supported } msg
itemOnOpening =
    Item_.onOpening


{-| See [`M3e.Element.NavMenuItem.onOpened`](M3e.Element.NavMenuItem#onOpened).
-}
itemOnOpened : msg -> Attr { c | onOpened : Supported } msg
itemOnOpened =
    Item_.onOpened


{-| See [`M3e.Element.NavMenuItem.onClosing`](M3e.Element.NavMenuItem#onClosing).
-}
itemOnClosing : msg -> Attr { c | onClosing : Supported } msg
itemOnClosing =
    Item_.onClosing


{-| See [`M3e.Element.NavMenuItem.onClosed`](M3e.Element.NavMenuItem#onClosed).
-}
itemOnClosed : msg -> Attr { c | onClosed : Supported } msg
itemOnClosed =
    Item_.onClosed


{-| See [`M3e.Element.NavMenuItem.onClick`](M3e.Element.NavMenuItem#onClick).
-}
itemOnClick : msg -> Attr { c | onClick : Supported } msg
itemOnClick =
    Item_.onClick


{-| See [`M3e.Element.NavMenuItem.badge`](M3e.Element.NavMenuItem#badge).
-}
itemBadge : Element ItemBadgeSlot admittedBy msg -> Element free freeAdmittedBy msg
itemBadge =
    Item_.badge


{-| See [`M3e.Element.NavMenuItem.icon`](M3e.Element.NavMenuItem#icon).
-}
itemIcon : Element ItemIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemIcon =
    Item_.icon


{-| See [`M3e.Element.NavMenuItem.label`](M3e.Element.NavMenuItem#label).
-}
itemLabel : Element ItemLabelSlot admittedBy msg -> Element free freeAdmittedBy msg
itemLabel =
    Item_.label


{-| See [`M3e.Element.NavMenuItem.selectedIcon`](M3e.Element.NavMenuItem#selectedIcon).
-}
itemSelectedIcon : Element ItemSelectedIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemSelectedIcon =
    Item_.selectedIcon


{-| See [`M3e.Element.NavMenuItem.toggleIcon`](M3e.Element.NavMenuItem#toggleIcon).
-}
itemToggleIcon : Element ItemToggleIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemToggleIcon =
    Item_.toggleIcon


{-| See [`M3e.Element.NavMenuItem.child`](M3e.Element.NavMenuItem#child).
-}
itemChild : Element ItemContent admittedBy msg -> Element free freeAdmittedBy msg
itemChild =
    Item_.child


{-| The `itemGroup` element of this family — delegates to [`M3e.Element.NavMenuItemGroup.component`](M3e.Element.NavMenuItemGroup#component).
-}
itemGroup :
    List (Attr ItemGroupAttrs msg)
    -> List (Element ItemGroupContent (ItemGroupChildAdmittedBy childAdm) msg)
    -> Element (ItemGroupIs s) admittedBy msg
itemGroup =
    ItemGroup_.component


{-| See [`M3e.Element.NavMenuItemGroup.Is`](M3e.Element.NavMenuItemGroup#Is).
-}
type alias ItemGroupIs s =
    ItemGroup_.Is s


{-| See [`M3e.Element.NavMenuItemGroup.Attrs`](M3e.Element.NavMenuItemGroup#Attrs).
-}
type alias ItemGroupAttrs =
    ItemGroup_.Attrs


{-| See [`M3e.Element.NavMenuItemGroup.Builder`](M3e.Element.NavMenuItemGroup#Builder).
-}
type alias ItemGroupBuilder attrCaps slotCaps msg kind =
    ItemGroup_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.NavMenuItemGroup.AttrCaps`](M3e.Element.NavMenuItemGroup#AttrCaps).
-}
type alias ItemGroupAttrCaps =
    ItemGroup_.AttrCaps


{-| See [`M3e.Element.NavMenuItemGroup.SlotCaps`](M3e.Element.NavMenuItemGroup#SlotCaps).
-}
type alias ItemGroupSlotCaps =
    ItemGroup_.SlotCaps


{-| See [`M3e.Element.NavMenuItemGroup.Content`](M3e.Element.NavMenuItemGroup#Content).
-}
type alias ItemGroupContent =
    ItemGroup_.Content


{-| See [`M3e.Element.NavMenuItemGroup.LabelSlot`](M3e.Element.NavMenuItemGroup#LabelSlot).
-}
type alias ItemGroupLabelSlot =
    ItemGroup_.LabelSlot


{-| See [`M3e.Element.NavMenuItemGroup.ChildAdmittedBy`](M3e.Element.NavMenuItemGroup#ChildAdmittedBy).
-}
type alias ItemGroupChildAdmittedBy childAdm =
    ItemGroup_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.NavMenuItemGroup.label`](M3e.Element.NavMenuItemGroup#label).
-}
itemGroupLabel : Element ItemGroupLabelSlot admittedBy msg -> Element free freeAdmittedBy msg
itemGroupLabel =
    ItemGroup_.label


{-| See [`M3e.Element.NavMenuItemGroup.child`](M3e.Element.NavMenuItemGroup#child).
-}
itemGroupChild : Element ItemGroupContent admittedBy msg -> Element free freeAdmittedBy msg
itemGroupChild =
    ItemGroup_.child
