module M3e.Component.ListItemButton exposing (ListItemButtonIs, ListItemButtonAttrs, ListItemButtonBuilder, ListItemButtonAttrCaps, ListItemButtonSlotCaps, ListItemButtonContent, ListItemButtonLeadingSlot, ListItemButtonOverlineSlot, ListItemButtonSupportingTextSlot, ListItemButtonTrailingSlot, ListItemButtonChildAdmittedBy, listItemButton, listItemButtonDisabled, listItemButtonDownload, listItemButtonHref, listItemButtonRel, listItemButtonTarget, listItemButtonOnClick, listItemButtonLeading, listItemButtonOverline, listItemButtonSupportingText, listItemButtonTrailing, listItemButtonChild)

{-| The **ListItemButton** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.ListItemButton`](M3e.Element.ListItemButton) as `listItemButton`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ListItemButtonIs, ListItemButtonAttrs, ListItemButtonBuilder, ListItemButtonAttrCaps, ListItemButtonSlotCaps, ListItemButtonContent, ListItemButtonLeadingSlot, ListItemButtonOverlineSlot, ListItemButtonSupportingTextSlot, ListItemButtonTrailingSlot, ListItemButtonChildAdmittedBy, listItemButton, listItemButtonDisabled, listItemButtonDownload, listItemButtonHref, listItemButtonRel, listItemButtonTarget, listItemButtonOnClick, listItemButtonLeading, listItemButtonOverline, listItemButtonSupportingText, listItemButtonTrailing, listItemButtonChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.ListItemButton as ListItemButton_


{-| The `listItemButton` element of this family — delegates to [`M3e.Element.ListItemButton.component`](M3e.Element.ListItemButton#component).
-}
listItemButton :
    List (Attr ListItemButtonAttrs msg)
    -> List (Element ListItemButtonContent (ListItemButtonChildAdmittedBy childAdm) msg)
    -> Element (ListItemButtonIs s) admittedBy msg
listItemButton =
    ListItemButton_.component


{-| See [`M3e.Element.ListItemButton.Is`](M3e.Element.ListItemButton#Is).
-}
type alias ListItemButtonIs s =
    ListItemButton_.Is s


{-| See [`M3e.Element.ListItemButton.Attrs`](M3e.Element.ListItemButton#Attrs).
-}
type alias ListItemButtonAttrs =
    ListItemButton_.Attrs


{-| See [`M3e.Element.ListItemButton.Builder`](M3e.Element.ListItemButton#Builder).
-}
type alias ListItemButtonBuilder attrCaps slotCaps msg kind =
    ListItemButton_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.ListItemButton.AttrCaps`](M3e.Element.ListItemButton#AttrCaps).
-}
type alias ListItemButtonAttrCaps =
    ListItemButton_.AttrCaps


{-| See [`M3e.Element.ListItemButton.SlotCaps`](M3e.Element.ListItemButton#SlotCaps).
-}
type alias ListItemButtonSlotCaps =
    ListItemButton_.SlotCaps


{-| See [`M3e.Element.ListItemButton.Content`](M3e.Element.ListItemButton#Content).
-}
type alias ListItemButtonContent =
    ListItemButton_.Content


{-| See [`M3e.Element.ListItemButton.LeadingSlot`](M3e.Element.ListItemButton#LeadingSlot).
-}
type alias ListItemButtonLeadingSlot =
    ListItemButton_.LeadingSlot


{-| See [`M3e.Element.ListItemButton.OverlineSlot`](M3e.Element.ListItemButton#OverlineSlot).
-}
type alias ListItemButtonOverlineSlot =
    ListItemButton_.OverlineSlot


{-| See [`M3e.Element.ListItemButton.SupportingTextSlot`](M3e.Element.ListItemButton#SupportingTextSlot).
-}
type alias ListItemButtonSupportingTextSlot =
    ListItemButton_.SupportingTextSlot


{-| See [`M3e.Element.ListItemButton.TrailingSlot`](M3e.Element.ListItemButton#TrailingSlot).
-}
type alias ListItemButtonTrailingSlot =
    ListItemButton_.TrailingSlot


{-| See [`M3e.Element.ListItemButton.ChildAdmittedBy`](M3e.Element.ListItemButton#ChildAdmittedBy).
-}
type alias ListItemButtonChildAdmittedBy childAdm =
    ListItemButton_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.ListItemButton.disabled`](M3e.Element.ListItemButton#disabled).
-}
listItemButtonDisabled : Bool -> Attr { c | disabled : Supported } msg
listItemButtonDisabled =
    ListItemButton_.disabled


{-| See [`M3e.Element.ListItemButton.download`](M3e.Element.ListItemButton#download).
-}
listItemButtonDownload : String -> Attr { c | download : Supported } msg
listItemButtonDownload =
    ListItemButton_.download


{-| See [`M3e.Element.ListItemButton.href`](M3e.Element.ListItemButton#href).
-}
listItemButtonHref : String -> Attr { c | href : Supported } msg
listItemButtonHref =
    ListItemButton_.href


{-| See [`M3e.Element.ListItemButton.rel`](M3e.Element.ListItemButton#rel).
-}
listItemButtonRel : String -> Attr { c | rel : Supported } msg
listItemButtonRel =
    ListItemButton_.rel


{-| See [`M3e.Element.ListItemButton.target`](M3e.Element.ListItemButton#target).
-}
listItemButtonTarget : String -> Attr { c | target : Supported } msg
listItemButtonTarget =
    ListItemButton_.target


{-| See [`M3e.Element.ListItemButton.onClick`](M3e.Element.ListItemButton#onClick).
-}
listItemButtonOnClick : msg -> Attr { c | onClick : Supported } msg
listItemButtonOnClick =
    ListItemButton_.onClick


{-| See [`M3e.Element.ListItemButton.leading`](M3e.Element.ListItemButton#leading).
-}
listItemButtonLeading : Element ListItemButtonLeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
listItemButtonLeading =
    ListItemButton_.leading


{-| See [`M3e.Element.ListItemButton.overline`](M3e.Element.ListItemButton#overline).
-}
listItemButtonOverline : Element ListItemButtonOverlineSlot admittedBy msg -> Element free freeAdmittedBy msg
listItemButtonOverline =
    ListItemButton_.overline


{-| See [`M3e.Element.ListItemButton.supportingText`](M3e.Element.ListItemButton#supportingText).
-}
listItemButtonSupportingText : Element ListItemButtonSupportingTextSlot admittedBy msg -> Element free freeAdmittedBy msg
listItemButtonSupportingText =
    ListItemButton_.supportingText


{-| See [`M3e.Element.ListItemButton.trailing`](M3e.Element.ListItemButton#trailing).
-}
listItemButtonTrailing : Element ListItemButtonTrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
listItemButtonTrailing =
    ListItemButton_.trailing


{-| See [`M3e.Element.ListItemButton.child`](M3e.Element.ListItemButton#child).
-}
listItemButtonChild : Element ListItemButtonContent admittedBy msg -> Element free freeAdmittedBy msg
listItemButtonChild =
    ListItemButton_.child
