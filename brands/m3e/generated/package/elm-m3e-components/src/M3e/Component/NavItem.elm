module M3e.Component.NavItem exposing (NavItemIs, NavItemAttrs, NavItemBuilder, NavItemAttrCaps, NavItemSlotCaps, NavItemContent, NavItemIconSlot, NavItemSelectedIconSlot, NavItemChildAdmittedBy, NavItemOrientation, navItem, navItemOrientation, navItemDisabled, navItemDisabledInteractive, navItemDownload, navItemHref, navItemRel, navItemSelected, navItemTarget, navItemDefaultSelected, navItemOnBeforeinput, navItemOnInput, navItemOnChange, navItemOnClick, navItemIcon, navItemSelectedIcon, navItemChild)

{-| The **NavItem** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.NavItem`](M3e.Element.NavItem) as `navItem`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs NavItemIs, NavItemAttrs, NavItemBuilder, NavItemAttrCaps, NavItemSlotCaps, NavItemContent, NavItemIconSlot, NavItemSelectedIconSlot, NavItemChildAdmittedBy, NavItemOrientation, navItem, navItemOrientation, navItemDisabled, navItemDisabledInteractive, navItemDownload, navItemHref, navItemRel, navItemSelected, navItemTarget, navItemDefaultSelected, navItemOnBeforeinput, navItemOnInput, navItemOnChange, navItemOnClick, navItemIcon, navItemSelectedIcon, navItemChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.NavItem as NavItem_


{-| The `navItem` element of this family — delegates to [`M3e.Element.NavItem.component`](M3e.Element.NavItem#component).
-}
navItem :
    List (Attr NavItemAttrs msg)
    -> List (Element NavItemContent (NavItemChildAdmittedBy childAdm) msg)
    -> Element (NavItemIs s) admittedBy msg
navItem =
    NavItem_.component


{-| See [`M3e.Element.NavItem.Is`](M3e.Element.NavItem#Is).
-}
type alias NavItemIs s =
    NavItem_.Is s


{-| See [`M3e.Element.NavItem.Attrs`](M3e.Element.NavItem#Attrs).
-}
type alias NavItemAttrs =
    NavItem_.Attrs


{-| See [`M3e.Element.NavItem.Builder`](M3e.Element.NavItem#Builder).
-}
type alias NavItemBuilder attrCaps slotCaps msg kind =
    NavItem_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.NavItem.AttrCaps`](M3e.Element.NavItem#AttrCaps).
-}
type alias NavItemAttrCaps =
    NavItem_.AttrCaps


{-| See [`M3e.Element.NavItem.SlotCaps`](M3e.Element.NavItem#SlotCaps).
-}
type alias NavItemSlotCaps =
    NavItem_.SlotCaps


{-| See [`M3e.Element.NavItem.Content`](M3e.Element.NavItem#Content).
-}
type alias NavItemContent =
    NavItem_.Content


{-| See [`M3e.Element.NavItem.IconSlot`](M3e.Element.NavItem#IconSlot).
-}
type alias NavItemIconSlot =
    NavItem_.IconSlot


{-| See [`M3e.Element.NavItem.SelectedIconSlot`](M3e.Element.NavItem#SelectedIconSlot).
-}
type alias NavItemSelectedIconSlot =
    NavItem_.SelectedIconSlot


{-| See [`M3e.Element.NavItem.ChildAdmittedBy`](M3e.Element.NavItem#ChildAdmittedBy).
-}
type alias NavItemChildAdmittedBy childAdm =
    NavItem_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.NavItem.Orientation`](M3e.Element.NavItem#Orientation).
-}
type alias NavItemOrientation =
    NavItem_.Orientation


{-| See [`M3e.Element.NavItem.orientation`](M3e.Element.NavItem#orientation).
-}
navItemOrientation : Value NavItemOrientation -> Attr { c | orientation : Supported } msg
navItemOrientation =
    NavItem_.orientation


{-| See [`M3e.Element.NavItem.disabled`](M3e.Element.NavItem#disabled).
-}
navItemDisabled : Bool -> Attr { c | disabled : Supported } msg
navItemDisabled =
    NavItem_.disabled


{-| See [`M3e.Element.NavItem.disabledInteractive`](M3e.Element.NavItem#disabledInteractive).
-}
navItemDisabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
navItemDisabledInteractive =
    NavItem_.disabledInteractive


{-| See [`M3e.Element.NavItem.download`](M3e.Element.NavItem#download).
-}
navItemDownload : String -> Attr { c | download : Supported } msg
navItemDownload =
    NavItem_.download


{-| See [`M3e.Element.NavItem.href`](M3e.Element.NavItem#href).
-}
navItemHref : String -> Attr { c | href : Supported } msg
navItemHref =
    NavItem_.href


{-| See [`M3e.Element.NavItem.rel`](M3e.Element.NavItem#rel).
-}
navItemRel : String -> Attr { c | rel : Supported } msg
navItemRel =
    NavItem_.rel


{-| See [`M3e.Element.NavItem.selected`](M3e.Element.NavItem#selected).
-}
navItemSelected : Bool -> Attr { c | selected : Supported } msg
navItemSelected =
    NavItem_.selected


{-| See [`M3e.Element.NavItem.target`](M3e.Element.NavItem#target).
-}
navItemTarget : String -> Attr { c | target : Supported } msg
navItemTarget =
    NavItem_.target


{-| See [`M3e.Element.NavItem.defaultSelected`](M3e.Element.NavItem#defaultSelected).
-}
navItemDefaultSelected : Bool -> Attr { c | selected : Supported } msg
navItemDefaultSelected =
    NavItem_.defaultSelected


{-| See [`M3e.Element.NavItem.onBeforeinput`](M3e.Element.NavItem#onBeforeinput).
-}
navItemOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
navItemOnBeforeinput =
    NavItem_.onBeforeinput


{-| See [`M3e.Element.NavItem.onInput`](M3e.Element.NavItem#onInput).
-}
navItemOnInput : msg -> Attr { c | onInput : Supported } msg
navItemOnInput =
    NavItem_.onInput


{-| See [`M3e.Element.NavItem.onChange`](M3e.Element.NavItem#onChange).
-}
navItemOnChange : msg -> Attr { c | onChange : Supported } msg
navItemOnChange =
    NavItem_.onChange


{-| See [`M3e.Element.NavItem.onClick`](M3e.Element.NavItem#onClick).
-}
navItemOnClick : msg -> Attr { c | onClick : Supported } msg
navItemOnClick =
    NavItem_.onClick


{-| See [`M3e.Element.NavItem.icon`](M3e.Element.NavItem#icon).
-}
navItemIcon : Element NavItemIconSlot admittedBy msg -> Element free freeAdmittedBy msg
navItemIcon =
    NavItem_.icon


{-| See [`M3e.Element.NavItem.selectedIcon`](M3e.Element.NavItem#selectedIcon).
-}
navItemSelectedIcon : Element NavItemSelectedIconSlot admittedBy msg -> Element free freeAdmittedBy msg
navItemSelectedIcon =
    NavItem_.selectedIcon


{-| See [`M3e.Element.NavItem.child`](M3e.Element.NavItem#child).
-}
navItemChild : Element NavItemContent admittedBy msg -> Element free freeAdmittedBy msg
navItemChild =
    NavItem_.child
