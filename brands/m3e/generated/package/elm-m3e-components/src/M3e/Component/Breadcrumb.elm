module M3e.Component.Breadcrumb exposing (BreadcrumbIs, BreadcrumbAttrs, BreadcrumbBuilder, BreadcrumbAttrCaps, BreadcrumbSlotCaps, BreadcrumbContent, BreadcrumbChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemIconSlot, ItemChildAdmittedBy, ItemCurrent, breadcrumb, breadcrumbWrap, breadcrumbSeparator, breadcrumbChild, item, itemCurrent, itemDisabled, itemDownload, itemHref, itemItemLabel, itemRel, itemTarget, itemOnClick, itemIcon, itemChild)

{-| The **Breadcrumb** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Breadcrumb`](M3e.Element.Breadcrumb) as `breadcrumb`, [`M3e.Element.BreadcrumbItem`](M3e.Element.BreadcrumbItem) as `item`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs BreadcrumbIs, BreadcrumbAttrs, BreadcrumbBuilder, BreadcrumbAttrCaps, BreadcrumbSlotCaps, BreadcrumbContent, BreadcrumbChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemIconSlot, ItemChildAdmittedBy, ItemCurrent, breadcrumb, breadcrumbWrap, breadcrumbSeparator, breadcrumbChild, item, itemCurrent, itemDisabled, itemDownload, itemHref, itemItemLabel, itemRel, itemTarget, itemOnClick, itemIcon, itemChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Breadcrumb as Breadcrumb_
import M3e.Element.BreadcrumbItem as Item_


{-| The `breadcrumb` element of this family — delegates to [`M3e.Element.Breadcrumb.component`](M3e.Element.Breadcrumb#component).
-}
breadcrumb :
    { content : Element BreadcrumbContent (BreadcrumbChildAdmittedBy childAdm) msg }
    -> List (Attr BreadcrumbAttrs msg)
    -> List (Element BreadcrumbContent (BreadcrumbChildAdmittedBy childAdm) msg)
    -> Element (BreadcrumbIs s) admittedBy msg
breadcrumb =
    Breadcrumb_.component


{-| See [`M3e.Element.Breadcrumb.Is`](M3e.Element.Breadcrumb#Is).
-}
type alias BreadcrumbIs s =
    Breadcrumb_.Is s


{-| See [`M3e.Element.Breadcrumb.Attrs`](M3e.Element.Breadcrumb#Attrs).
-}
type alias BreadcrumbAttrs =
    Breadcrumb_.Attrs


{-| See [`M3e.Element.Breadcrumb.Builder`](M3e.Element.Breadcrumb#Builder).
-}
type alias BreadcrumbBuilder attrCaps slotCaps msg kind =
    Breadcrumb_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Breadcrumb.AttrCaps`](M3e.Element.Breadcrumb#AttrCaps).
-}
type alias BreadcrumbAttrCaps =
    Breadcrumb_.AttrCaps


{-| See [`M3e.Element.Breadcrumb.SlotCaps`](M3e.Element.Breadcrumb#SlotCaps).
-}
type alias BreadcrumbSlotCaps =
    Breadcrumb_.SlotCaps


{-| See [`M3e.Element.Breadcrumb.Content`](M3e.Element.Breadcrumb#Content).
-}
type alias BreadcrumbContent =
    Breadcrumb_.Content


{-| See [`M3e.Element.Breadcrumb.ChildAdmittedBy`](M3e.Element.Breadcrumb#ChildAdmittedBy).
-}
type alias BreadcrumbChildAdmittedBy childAdm =
    Breadcrumb_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Breadcrumb.wrap`](M3e.Element.Breadcrumb#wrap).
-}
breadcrumbWrap : Bool -> Attr { c | wrap : Supported } msg
breadcrumbWrap =
    Breadcrumb_.wrap


{-| See [`M3e.Element.Breadcrumb.separator`](M3e.Element.Breadcrumb#separator).
-}
breadcrumbSeparator : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
breadcrumbSeparator =
    Breadcrumb_.separator


{-| See [`M3e.Element.Breadcrumb.child`](M3e.Element.Breadcrumb#child).
-}
breadcrumbChild : Element BreadcrumbContent admittedBy msg -> Element free freeAdmittedBy msg
breadcrumbChild =
    Breadcrumb_.child


{-| The `item` element of this family — delegates to [`M3e.Element.BreadcrumbItem.component`](M3e.Element.BreadcrumbItem#component).
-}
item :
    List (Attr ItemAttrs msg)
    -> List (Element ItemContent (ItemChildAdmittedBy childAdm) msg)
    -> Element (ItemIs s) admittedBy msg
item =
    Item_.component


{-| See [`M3e.Element.BreadcrumbItem.Is`](M3e.Element.BreadcrumbItem#Is).
-}
type alias ItemIs s =
    Item_.Is s


{-| See [`M3e.Element.BreadcrumbItem.Attrs`](M3e.Element.BreadcrumbItem#Attrs).
-}
type alias ItemAttrs =
    Item_.Attrs


{-| See [`M3e.Element.BreadcrumbItem.Builder`](M3e.Element.BreadcrumbItem#Builder).
-}
type alias ItemBuilder attrCaps slotCaps msg kind =
    Item_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.BreadcrumbItem.AttrCaps`](M3e.Element.BreadcrumbItem#AttrCaps).
-}
type alias ItemAttrCaps =
    Item_.AttrCaps


{-| See [`M3e.Element.BreadcrumbItem.SlotCaps`](M3e.Element.BreadcrumbItem#SlotCaps).
-}
type alias ItemSlotCaps =
    Item_.SlotCaps


{-| See [`M3e.Element.BreadcrumbItem.Content`](M3e.Element.BreadcrumbItem#Content).
-}
type alias ItemContent =
    Item_.Content


{-| See [`M3e.Element.BreadcrumbItem.IconSlot`](M3e.Element.BreadcrumbItem#IconSlot).
-}
type alias ItemIconSlot =
    Item_.IconSlot


{-| See [`M3e.Element.BreadcrumbItem.ChildAdmittedBy`](M3e.Element.BreadcrumbItem#ChildAdmittedBy).
-}
type alias ItemChildAdmittedBy childAdm =
    Item_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.BreadcrumbItem.Current`](M3e.Element.BreadcrumbItem#Current).
-}
type alias ItemCurrent =
    Item_.Current


{-| See [`M3e.Element.BreadcrumbItem.current`](M3e.Element.BreadcrumbItem#current).
-}
itemCurrent : Value ItemCurrent -> Attr { c | current : Supported } msg
itemCurrent =
    Item_.current


{-| See [`M3e.Element.BreadcrumbItem.disabled`](M3e.Element.BreadcrumbItem#disabled).
-}
itemDisabled : Bool -> Attr { c | disabled : Supported } msg
itemDisabled =
    Item_.disabled


{-| See [`M3e.Element.BreadcrumbItem.download`](M3e.Element.BreadcrumbItem#download).
-}
itemDownload : String -> Attr { c | download : Supported } msg
itemDownload =
    Item_.download


{-| See [`M3e.Element.BreadcrumbItem.href`](M3e.Element.BreadcrumbItem#href).
-}
itemHref : String -> Attr { c | href : Supported } msg
itemHref =
    Item_.href


{-| See [`M3e.Element.BreadcrumbItem.itemLabel`](M3e.Element.BreadcrumbItem#itemLabel).
-}
itemItemLabel : String -> Attr { c | itemLabel : Supported } msg
itemItemLabel =
    Item_.itemLabel


{-| See [`M3e.Element.BreadcrumbItem.rel`](M3e.Element.BreadcrumbItem#rel).
-}
itemRel : String -> Attr { c | rel : Supported } msg
itemRel =
    Item_.rel


{-| See [`M3e.Element.BreadcrumbItem.target`](M3e.Element.BreadcrumbItem#target).
-}
itemTarget : String -> Attr { c | target : Supported } msg
itemTarget =
    Item_.target


{-| See [`M3e.Element.BreadcrumbItem.onClick`](M3e.Element.BreadcrumbItem#onClick).
-}
itemOnClick : msg -> Attr { c | onClick : Supported } msg
itemOnClick =
    Item_.onClick


{-| See [`M3e.Element.BreadcrumbItem.icon`](M3e.Element.BreadcrumbItem#icon).
-}
itemIcon : Element ItemIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemIcon =
    Item_.icon


{-| See [`M3e.Element.BreadcrumbItem.child`](M3e.Element.BreadcrumbItem#child).
-}
itemChild : Element ItemContent admittedBy msg -> Element free freeAdmittedBy msg
itemChild =
    Item_.child
