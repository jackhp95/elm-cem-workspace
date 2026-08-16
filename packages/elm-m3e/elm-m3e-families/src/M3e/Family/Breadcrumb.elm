module M3e.Family.Breadcrumb exposing (BreadcrumbIs, BreadcrumbAttrs, BreadcrumbBuilder, BreadcrumbAttrCaps, BreadcrumbSlotCaps, BreadcrumbContent, BreadcrumbChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemIconSlot, ItemChildAdmittedBy, ItemCurrent, breadcrumb, breadcrumbWrap, breadcrumbSeparator, breadcrumbChild, item, itemCurrent, itemDisabled, itemDownload, itemHref, itemItemLabel, itemRel, itemTarget, itemOnClick, itemIcon, itemChild)

{-| The **Breadcrumb** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.Breadcrumb`](M3e.Component.Breadcrumb) as `breadcrumb`, [`M3e.Component.BreadcrumbItem`](M3e.Component.BreadcrumbItem) as `item`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs BreadcrumbIs, BreadcrumbAttrs, BreadcrumbBuilder, BreadcrumbAttrCaps, BreadcrumbSlotCaps, BreadcrumbContent, BreadcrumbChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemIconSlot, ItemChildAdmittedBy, ItemCurrent, breadcrumb, breadcrumbWrap, breadcrumbSeparator, breadcrumbChild, item, itemCurrent, itemDisabled, itemDownload, itemHref, itemItemLabel, itemRel, itemTarget, itemOnClick, itemIcon, itemChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Component.Breadcrumb as Breadcrumb_
import M3e.Component.BreadcrumbItem as Item_


{-| The `breadcrumb` element of this family — delegates to [`M3e.Component.Breadcrumb.component`](M3e.Component.Breadcrumb#component).
-}
breadcrumb :
    { content : Element BreadcrumbContent (BreadcrumbChildAdmittedBy childAdm) msg }
    -> List (Attr BreadcrumbAttrs msg)
    -> List (Element BreadcrumbContent (BreadcrumbChildAdmittedBy childAdm) msg)
    -> Element (BreadcrumbIs s) admittedBy msg
breadcrumb =
    Breadcrumb_.component


{-| See [`M3e.Component.Breadcrumb.Is`](M3e.Component.Breadcrumb#Is).
-}
type alias BreadcrumbIs s =
    Breadcrumb_.Is s


{-| See [`M3e.Component.Breadcrumb.Attrs`](M3e.Component.Breadcrumb#Attrs).
-}
type alias BreadcrumbAttrs =
    Breadcrumb_.Attrs


{-| See [`M3e.Component.Breadcrumb.Builder`](M3e.Component.Breadcrumb#Builder).
-}
type alias BreadcrumbBuilder attrCaps slotCaps msg kind =
    Breadcrumb_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.Breadcrumb.AttrCaps`](M3e.Component.Breadcrumb#AttrCaps).
-}
type alias BreadcrumbAttrCaps =
    Breadcrumb_.AttrCaps


{-| See [`M3e.Component.Breadcrumb.SlotCaps`](M3e.Component.Breadcrumb#SlotCaps).
-}
type alias BreadcrumbSlotCaps =
    Breadcrumb_.SlotCaps


{-| See [`M3e.Component.Breadcrumb.Content`](M3e.Component.Breadcrumb#Content).
-}
type alias BreadcrumbContent =
    Breadcrumb_.Content


{-| See [`M3e.Component.Breadcrumb.ChildAdmittedBy`](M3e.Component.Breadcrumb#ChildAdmittedBy).
-}
type alias BreadcrumbChildAdmittedBy childAdm =
    Breadcrumb_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.Breadcrumb.wrap`](M3e.Component.Breadcrumb#wrap).
-}
breadcrumbWrap : Bool -> Attr { c | wrap : Supported } msg
breadcrumbWrap =
    Breadcrumb_.wrap


{-| See [`M3e.Component.Breadcrumb.separator`](M3e.Component.Breadcrumb#separator).
-}
breadcrumbSeparator : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
breadcrumbSeparator =
    Breadcrumb_.separator


{-| See [`M3e.Component.Breadcrumb.child`](M3e.Component.Breadcrumb#child).
-}
breadcrumbChild : Element BreadcrumbContent admittedBy msg -> Element free freeAdmittedBy msg
breadcrumbChild =
    Breadcrumb_.child


{-| The `item` element of this family — delegates to [`M3e.Component.BreadcrumbItem.component`](M3e.Component.BreadcrumbItem#component).
-}
item :
    List (Attr ItemAttrs msg)
    -> List (Element ItemContent (ItemChildAdmittedBy childAdm) msg)
    -> Element (ItemIs s) admittedBy msg
item =
    Item_.component


{-| See [`M3e.Component.BreadcrumbItem.Is`](M3e.Component.BreadcrumbItem#Is).
-}
type alias ItemIs s =
    Item_.Is s


{-| See [`M3e.Component.BreadcrumbItem.Attrs`](M3e.Component.BreadcrumbItem#Attrs).
-}
type alias ItemAttrs =
    Item_.Attrs


{-| See [`M3e.Component.BreadcrumbItem.Builder`](M3e.Component.BreadcrumbItem#Builder).
-}
type alias ItemBuilder attrCaps slotCaps msg kind =
    Item_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.BreadcrumbItem.AttrCaps`](M3e.Component.BreadcrumbItem#AttrCaps).
-}
type alias ItemAttrCaps =
    Item_.AttrCaps


{-| See [`M3e.Component.BreadcrumbItem.SlotCaps`](M3e.Component.BreadcrumbItem#SlotCaps).
-}
type alias ItemSlotCaps =
    Item_.SlotCaps


{-| See [`M3e.Component.BreadcrumbItem.Content`](M3e.Component.BreadcrumbItem#Content).
-}
type alias ItemContent =
    Item_.Content


{-| See [`M3e.Component.BreadcrumbItem.IconSlot`](M3e.Component.BreadcrumbItem#IconSlot).
-}
type alias ItemIconSlot =
    Item_.IconSlot


{-| See [`M3e.Component.BreadcrumbItem.ChildAdmittedBy`](M3e.Component.BreadcrumbItem#ChildAdmittedBy).
-}
type alias ItemChildAdmittedBy childAdm =
    Item_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.BreadcrumbItem.Current`](M3e.Component.BreadcrumbItem#Current).
-}
type alias ItemCurrent =
    Item_.Current


{-| See [`M3e.Component.BreadcrumbItem.current`](M3e.Component.BreadcrumbItem#current).
-}
itemCurrent : Value ItemCurrent -> Attr { c | current : Supported } msg
itemCurrent =
    Item_.current


{-| See [`M3e.Component.BreadcrumbItem.disabled`](M3e.Component.BreadcrumbItem#disabled).
-}
itemDisabled : Bool -> Attr { c | disabled : Supported } msg
itemDisabled =
    Item_.disabled


{-| See [`M3e.Component.BreadcrumbItem.download`](M3e.Component.BreadcrumbItem#download).
-}
itemDownload : String -> Attr { c | download : Supported } msg
itemDownload =
    Item_.download


{-| See [`M3e.Component.BreadcrumbItem.href`](M3e.Component.BreadcrumbItem#href).
-}
itemHref : String -> Attr { c | href : Supported } msg
itemHref =
    Item_.href


{-| See [`M3e.Component.BreadcrumbItem.itemLabel`](M3e.Component.BreadcrumbItem#itemLabel).
-}
itemItemLabel : String -> Attr { c | itemLabel : Supported } msg
itemItemLabel =
    Item_.itemLabel


{-| See [`M3e.Component.BreadcrumbItem.rel`](M3e.Component.BreadcrumbItem#rel).
-}
itemRel : String -> Attr { c | rel : Supported } msg
itemRel =
    Item_.rel


{-| See [`M3e.Component.BreadcrumbItem.target`](M3e.Component.BreadcrumbItem#target).
-}
itemTarget : String -> Attr { c | target : Supported } msg
itemTarget =
    Item_.target


{-| See [`M3e.Component.BreadcrumbItem.onClick`](M3e.Component.BreadcrumbItem#onClick).
-}
itemOnClick : msg -> Attr { c | onClick : Supported } msg
itemOnClick =
    Item_.onClick


{-| See [`M3e.Component.BreadcrumbItem.icon`](M3e.Component.BreadcrumbItem#icon).
-}
itemIcon : Element ItemIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemIcon =
    Item_.icon


{-| See [`M3e.Component.BreadcrumbItem.child`](M3e.Component.BreadcrumbItem#child).
-}
itemChild : Element ItemContent admittedBy msg -> Element free freeAdmittedBy msg
itemChild =
    Item_.child
