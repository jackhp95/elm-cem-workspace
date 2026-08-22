module Sl.Component.BreadcrumbItem exposing (BreadcrumbItemIs, BreadcrumbItemAttrs, BreadcrumbItemBuilder, BreadcrumbItemAttrCaps, BreadcrumbItemSlotCaps, BreadcrumbItemChildAdmittedBy, BreadcrumbItemTarget, breadcrumbItem, breadcrumbItemTarget, breadcrumbItemHref, breadcrumbItemRel)

{-| The **BreadcrumbItem** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.BreadcrumbItem`](Sl.Element.BreadcrumbItem) as `breadcrumbItem`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs BreadcrumbItemIs, BreadcrumbItemAttrs, BreadcrumbItemBuilder, BreadcrumbItemAttrCaps, BreadcrumbItemSlotCaps, BreadcrumbItemChildAdmittedBy, BreadcrumbItemTarget, breadcrumbItem, breadcrumbItemTarget, breadcrumbItemHref, breadcrumbItemRel

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.BreadcrumbItem as BreadcrumbItem_


{-| The `breadcrumbItem` element of this family — delegates to [`Sl.Element.BreadcrumbItem.component`](Sl.Element.BreadcrumbItem#component).
-}
breadcrumbItem :
    List (Attr BreadcrumbItemAttrs msg)
    -> List (Element childAccepts (BreadcrumbItemChildAdmittedBy childAdm) msg)
    -> Element (BreadcrumbItemIs s) admittedBy msg
breadcrumbItem =
    BreadcrumbItem_.component


{-| See [`Sl.Element.BreadcrumbItem.Is`](Sl.Element.BreadcrumbItem#Is).
-}
type alias BreadcrumbItemIs s =
    BreadcrumbItem_.Is s


{-| See [`Sl.Element.BreadcrumbItem.Attrs`](Sl.Element.BreadcrumbItem#Attrs).
-}
type alias BreadcrumbItemAttrs =
    BreadcrumbItem_.Attrs


{-| See [`Sl.Element.BreadcrumbItem.Builder`](Sl.Element.BreadcrumbItem#Builder).
-}
type alias BreadcrumbItemBuilder attrCaps slotCaps msg kind =
    BreadcrumbItem_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.BreadcrumbItem.AttrCaps`](Sl.Element.BreadcrumbItem#AttrCaps).
-}
type alias BreadcrumbItemAttrCaps =
    BreadcrumbItem_.AttrCaps


{-| See [`Sl.Element.BreadcrumbItem.SlotCaps`](Sl.Element.BreadcrumbItem#SlotCaps).
-}
type alias BreadcrumbItemSlotCaps =
    BreadcrumbItem_.SlotCaps


{-| See [`Sl.Element.BreadcrumbItem.ChildAdmittedBy`](Sl.Element.BreadcrumbItem#ChildAdmittedBy).
-}
type alias BreadcrumbItemChildAdmittedBy childAdm =
    BreadcrumbItem_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.BreadcrumbItem.Target`](Sl.Element.BreadcrumbItem#Target).
-}
type alias BreadcrumbItemTarget =
    BreadcrumbItem_.Target


{-| See [`Sl.Element.BreadcrumbItem.target`](Sl.Element.BreadcrumbItem#target).
-}
breadcrumbItemTarget : Value BreadcrumbItemTarget -> Attr { c | target : Supported } msg
breadcrumbItemTarget =
    BreadcrumbItem_.target


{-| See [`Sl.Element.BreadcrumbItem.href`](Sl.Element.BreadcrumbItem#href).
-}
breadcrumbItemHref : String -> Attr { c | href : Supported } msg
breadcrumbItemHref =
    BreadcrumbItem_.href


{-| See [`Sl.Element.BreadcrumbItem.rel`](Sl.Element.BreadcrumbItem#rel).
-}
breadcrumbItemRel : String -> Attr { c | rel : Supported } msg
breadcrumbItemRel =
    BreadcrumbItem_.rel
