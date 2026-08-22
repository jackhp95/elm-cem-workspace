module Sl.Component.MenuItem exposing (MenuItemIs, MenuItemAttrs, MenuItemBuilder, MenuItemAttrCaps, MenuItemSlotCaps, MenuItemChildAdmittedBy, MenuItemType, menuItem, menuItemType_, menuItemChecked, menuItemDisabled, menuItemLoading, menuItemValue, menuItemDefaultChecked, menuItemDefaultValue)

{-| The **MenuItem** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.MenuItem`](Sl.Element.MenuItem) as `menuItem`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs MenuItemIs, MenuItemAttrs, MenuItemBuilder, MenuItemAttrCaps, MenuItemSlotCaps, MenuItemChildAdmittedBy, MenuItemType, menuItem, menuItemType_, menuItemChecked, menuItemDisabled, menuItemLoading, menuItemValue, menuItemDefaultChecked, menuItemDefaultValue

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.MenuItem as MenuItem_


{-| The `menuItem` element of this family — delegates to [`Sl.Element.MenuItem.component`](Sl.Element.MenuItem#component).
-}
menuItem :
    List (Attr MenuItemAttrs msg)
    -> List (Element childAccepts (MenuItemChildAdmittedBy childAdm) msg)
    -> Element (MenuItemIs s) admittedBy msg
menuItem =
    MenuItem_.component


{-| See [`Sl.Element.MenuItem.Is`](Sl.Element.MenuItem#Is).
-}
type alias MenuItemIs s =
    MenuItem_.Is s


{-| See [`Sl.Element.MenuItem.Attrs`](Sl.Element.MenuItem#Attrs).
-}
type alias MenuItemAttrs =
    MenuItem_.Attrs


{-| See [`Sl.Element.MenuItem.Builder`](Sl.Element.MenuItem#Builder).
-}
type alias MenuItemBuilder attrCaps slotCaps msg kind =
    MenuItem_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.MenuItem.AttrCaps`](Sl.Element.MenuItem#AttrCaps).
-}
type alias MenuItemAttrCaps =
    MenuItem_.AttrCaps


{-| See [`Sl.Element.MenuItem.SlotCaps`](Sl.Element.MenuItem#SlotCaps).
-}
type alias MenuItemSlotCaps =
    MenuItem_.SlotCaps


{-| See [`Sl.Element.MenuItem.ChildAdmittedBy`](Sl.Element.MenuItem#ChildAdmittedBy).
-}
type alias MenuItemChildAdmittedBy childAdm =
    MenuItem_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.MenuItem.Type`](Sl.Element.MenuItem#Type).
-}
type alias MenuItemType =
    MenuItem_.Type


{-| See [`Sl.Element.MenuItem.type_`](Sl.Element.MenuItem#type_).
-}
menuItemType_ : Value MenuItemType -> Attr { c | type_ : Supported } msg
menuItemType_ =
    MenuItem_.type_


{-| See [`Sl.Element.MenuItem.checked`](Sl.Element.MenuItem#checked).
-}
menuItemChecked : Bool -> Attr { c | checked : Supported } msg
menuItemChecked =
    MenuItem_.checked


{-| See [`Sl.Element.MenuItem.disabled`](Sl.Element.MenuItem#disabled).
-}
menuItemDisabled : Bool -> Attr { c | disabled : Supported } msg
menuItemDisabled =
    MenuItem_.disabled


{-| See [`Sl.Element.MenuItem.loading`](Sl.Element.MenuItem#loading).
-}
menuItemLoading : Bool -> Attr { c | loading : Supported } msg
menuItemLoading =
    MenuItem_.loading


{-| See [`Sl.Element.MenuItem.value`](Sl.Element.MenuItem#value).
-}
menuItemValue : String -> Attr { c | value : Supported } msg
menuItemValue =
    MenuItem_.value


{-| See [`Sl.Element.MenuItem.defaultChecked`](Sl.Element.MenuItem#defaultChecked).
-}
menuItemDefaultChecked : Bool -> Attr { c | checked : Supported } msg
menuItemDefaultChecked =
    MenuItem_.defaultChecked


{-| See [`Sl.Element.MenuItem.defaultValue`](Sl.Element.MenuItem#defaultValue).
-}
menuItemDefaultValue : String -> Attr { c | value : Supported } msg
menuItemDefaultValue =
    MenuItem_.defaultValue
