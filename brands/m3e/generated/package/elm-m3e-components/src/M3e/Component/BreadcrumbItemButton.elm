module M3e.Component.BreadcrumbItemButton exposing (BreadcrumbItemButtonIs, BreadcrumbItemButtonAttrs, BreadcrumbItemButtonBuilder, BreadcrumbItemButtonAttrCaps, BreadcrumbItemButtonSlotCaps, BreadcrumbItemButtonContent, BreadcrumbItemButtonChildAdmittedBy, BreadcrumbItemButtonCurrent, breadcrumbItemButton, breadcrumbItemButtonCurrent, breadcrumbItemButtonDisabled, breadcrumbItemButtonDownload, breadcrumbItemButtonHref, breadcrumbItemButtonRel, breadcrumbItemButtonTarget, breadcrumbItemButtonOnClick, breadcrumbItemButtonChild)

{-| The **BreadcrumbItemButton** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.BreadcrumbItemButton`](M3e.Element.BreadcrumbItemButton) as `breadcrumbItemButton`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs BreadcrumbItemButtonIs, BreadcrumbItemButtonAttrs, BreadcrumbItemButtonBuilder, BreadcrumbItemButtonAttrCaps, BreadcrumbItemButtonSlotCaps, BreadcrumbItemButtonContent, BreadcrumbItemButtonChildAdmittedBy, BreadcrumbItemButtonCurrent, breadcrumbItemButton, breadcrumbItemButtonCurrent, breadcrumbItemButtonDisabled, breadcrumbItemButtonDownload, breadcrumbItemButtonHref, breadcrumbItemButtonRel, breadcrumbItemButtonTarget, breadcrumbItemButtonOnClick, breadcrumbItemButtonChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.BreadcrumbItemButton as BreadcrumbItemButton_


{-| The `breadcrumbItemButton` element of this family — delegates to [`M3e.Element.BreadcrumbItemButton.component`](M3e.Element.BreadcrumbItemButton#component).
-}
breadcrumbItemButton :
    List (Attr BreadcrumbItemButtonAttrs msg)
    -> List (Element BreadcrumbItemButtonContent (BreadcrumbItemButtonChildAdmittedBy childAdm) msg)
    -> Element (BreadcrumbItemButtonIs s) admittedBy msg
breadcrumbItemButton =
    BreadcrumbItemButton_.component


{-| See [`M3e.Element.BreadcrumbItemButton.Is`](M3e.Element.BreadcrumbItemButton#Is).
-}
type alias BreadcrumbItemButtonIs s =
    BreadcrumbItemButton_.Is s


{-| See [`M3e.Element.BreadcrumbItemButton.Attrs`](M3e.Element.BreadcrumbItemButton#Attrs).
-}
type alias BreadcrumbItemButtonAttrs =
    BreadcrumbItemButton_.Attrs


{-| See [`M3e.Element.BreadcrumbItemButton.Builder`](M3e.Element.BreadcrumbItemButton#Builder).
-}
type alias BreadcrumbItemButtonBuilder attrCaps slotCaps msg kind =
    BreadcrumbItemButton_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.BreadcrumbItemButton.AttrCaps`](M3e.Element.BreadcrumbItemButton#AttrCaps).
-}
type alias BreadcrumbItemButtonAttrCaps =
    BreadcrumbItemButton_.AttrCaps


{-| See [`M3e.Element.BreadcrumbItemButton.SlotCaps`](M3e.Element.BreadcrumbItemButton#SlotCaps).
-}
type alias BreadcrumbItemButtonSlotCaps =
    BreadcrumbItemButton_.SlotCaps


{-| See [`M3e.Element.BreadcrumbItemButton.Content`](M3e.Element.BreadcrumbItemButton#Content).
-}
type alias BreadcrumbItemButtonContent =
    BreadcrumbItemButton_.Content


{-| See [`M3e.Element.BreadcrumbItemButton.ChildAdmittedBy`](M3e.Element.BreadcrumbItemButton#ChildAdmittedBy).
-}
type alias BreadcrumbItemButtonChildAdmittedBy childAdm =
    BreadcrumbItemButton_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.BreadcrumbItemButton.Current`](M3e.Element.BreadcrumbItemButton#Current).
-}
type alias BreadcrumbItemButtonCurrent =
    BreadcrumbItemButton_.Current


{-| See [`M3e.Element.BreadcrumbItemButton.current`](M3e.Element.BreadcrumbItemButton#current).
-}
breadcrumbItemButtonCurrent : Value BreadcrumbItemButtonCurrent -> Attr { c | current : Supported } msg
breadcrumbItemButtonCurrent =
    BreadcrumbItemButton_.current


{-| See [`M3e.Element.BreadcrumbItemButton.disabled`](M3e.Element.BreadcrumbItemButton#disabled).
-}
breadcrumbItemButtonDisabled : Bool -> Attr { c | disabled : Supported } msg
breadcrumbItemButtonDisabled =
    BreadcrumbItemButton_.disabled


{-| See [`M3e.Element.BreadcrumbItemButton.download`](M3e.Element.BreadcrumbItemButton#download).
-}
breadcrumbItemButtonDownload : String -> Attr { c | download : Supported } msg
breadcrumbItemButtonDownload =
    BreadcrumbItemButton_.download


{-| See [`M3e.Element.BreadcrumbItemButton.href`](M3e.Element.BreadcrumbItemButton#href).
-}
breadcrumbItemButtonHref : String -> Attr { c | href : Supported } msg
breadcrumbItemButtonHref =
    BreadcrumbItemButton_.href


{-| See [`M3e.Element.BreadcrumbItemButton.rel`](M3e.Element.BreadcrumbItemButton#rel).
-}
breadcrumbItemButtonRel : String -> Attr { c | rel : Supported } msg
breadcrumbItemButtonRel =
    BreadcrumbItemButton_.rel


{-| See [`M3e.Element.BreadcrumbItemButton.target`](M3e.Element.BreadcrumbItemButton#target).
-}
breadcrumbItemButtonTarget : String -> Attr { c | target : Supported } msg
breadcrumbItemButtonTarget =
    BreadcrumbItemButton_.target


{-| See [`M3e.Element.BreadcrumbItemButton.onClick`](M3e.Element.BreadcrumbItemButton#onClick).
-}
breadcrumbItemButtonOnClick : msg -> Attr { c | onClick : Supported } msg
breadcrumbItemButtonOnClick =
    BreadcrumbItemButton_.onClick


{-| See [`M3e.Element.BreadcrumbItemButton.child`](M3e.Element.BreadcrumbItemButton#child).
-}
breadcrumbItemButtonChild : Element BreadcrumbItemButtonContent admittedBy msg -> Element free freeAdmittedBy msg
breadcrumbItemButtonChild =
    BreadcrumbItemButton_.child
