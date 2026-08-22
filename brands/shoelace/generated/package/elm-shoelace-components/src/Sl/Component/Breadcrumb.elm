module Sl.Component.Breadcrumb exposing (BreadcrumbIs, BreadcrumbAttrs, BreadcrumbBuilder, BreadcrumbAttrCaps, BreadcrumbSlotCaps, BreadcrumbContent, BreadcrumbChildAdmittedBy, breadcrumb, breadcrumbLabel, breadcrumbChild)

{-| The **Breadcrumb** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Breadcrumb`](Sl.Element.Breadcrumb) as `breadcrumb`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs BreadcrumbIs, BreadcrumbAttrs, BreadcrumbBuilder, BreadcrumbAttrCaps, BreadcrumbSlotCaps, BreadcrumbContent, BreadcrumbChildAdmittedBy, breadcrumb, breadcrumbLabel, breadcrumbChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.Breadcrumb as Breadcrumb_


{-| The `breadcrumb` element of this family — delegates to [`Sl.Element.Breadcrumb.component`](Sl.Element.Breadcrumb#component).
-}
breadcrumb :
    List (Attr BreadcrumbAttrs msg)
    -> List (Element BreadcrumbContent (BreadcrumbChildAdmittedBy childAdm) msg)
    -> Element (BreadcrumbIs s) admittedBy msg
breadcrumb =
    Breadcrumb_.component


{-| See [`Sl.Element.Breadcrumb.Is`](Sl.Element.Breadcrumb#Is).
-}
type alias BreadcrumbIs s =
    Breadcrumb_.Is s


{-| See [`Sl.Element.Breadcrumb.Attrs`](Sl.Element.Breadcrumb#Attrs).
-}
type alias BreadcrumbAttrs =
    Breadcrumb_.Attrs


{-| See [`Sl.Element.Breadcrumb.Builder`](Sl.Element.Breadcrumb#Builder).
-}
type alias BreadcrumbBuilder attrCaps slotCaps msg kind =
    Breadcrumb_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Breadcrumb.AttrCaps`](Sl.Element.Breadcrumb#AttrCaps).
-}
type alias BreadcrumbAttrCaps =
    Breadcrumb_.AttrCaps


{-| See [`Sl.Element.Breadcrumb.SlotCaps`](Sl.Element.Breadcrumb#SlotCaps).
-}
type alias BreadcrumbSlotCaps =
    Breadcrumb_.SlotCaps


{-| See [`Sl.Element.Breadcrumb.Content`](Sl.Element.Breadcrumb#Content).
-}
type alias BreadcrumbContent =
    Breadcrumb_.Content


{-| See [`Sl.Element.Breadcrumb.ChildAdmittedBy`](Sl.Element.Breadcrumb#ChildAdmittedBy).
-}
type alias BreadcrumbChildAdmittedBy childAdm =
    Breadcrumb_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Breadcrumb.label`](Sl.Element.Breadcrumb#label).
-}
breadcrumbLabel : String -> Attr { c | label : Supported } msg
breadcrumbLabel =
    Breadcrumb_.label


{-| See [`Sl.Element.Breadcrumb.child`](Sl.Element.Breadcrumb#child).
-}
breadcrumbChild : Element BreadcrumbContent admittedBy msg -> Element free freeAdmittedBy msg
breadcrumbChild =
    Breadcrumb_.child
