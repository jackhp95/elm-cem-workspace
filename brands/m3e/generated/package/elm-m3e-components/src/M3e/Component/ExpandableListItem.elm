module M3e.Component.ExpandableListItem exposing (ExpandableListItemIs, ExpandableListItemAttrs, ExpandableListItemBuilder, ExpandableListItemAttrCaps, ExpandableListItemSlotCaps, ExpandableListItemContent, ExpandableListItemLeadingSlot, ExpandableListItemOverlineSlot, ExpandableListItemSupportingTextSlot, ExpandableListItemToggleIconSlot, ExpandableListItemChildAdmittedBy, expandableListItem, expandableListItemDisabled, expandableListItemOpen, expandableListItemOnOpening, expandableListItemOnOpened, expandableListItemOnClosing, expandableListItemOnClosed, expandableListItemItems, expandableListItemLeading, expandableListItemOverline, expandableListItemSupportingText, expandableListItemToggleIcon, expandableListItemChild)

{-| The **ExpandableListItem** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.ExpandableListItem`](M3e.Element.ExpandableListItem) as `expandableListItem`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ExpandableListItemIs, ExpandableListItemAttrs, ExpandableListItemBuilder, ExpandableListItemAttrCaps, ExpandableListItemSlotCaps, ExpandableListItemContent, ExpandableListItemLeadingSlot, ExpandableListItemOverlineSlot, ExpandableListItemSupportingTextSlot, ExpandableListItemToggleIconSlot, ExpandableListItemChildAdmittedBy, expandableListItem, expandableListItemDisabled, expandableListItemOpen, expandableListItemOnOpening, expandableListItemOnOpened, expandableListItemOnClosing, expandableListItemOnClosed, expandableListItemItems, expandableListItemLeading, expandableListItemOverline, expandableListItemSupportingText, expandableListItemToggleIcon, expandableListItemChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.ExpandableListItem as ExpandableListItem_


{-| The `expandableListItem` element of this family — delegates to [`M3e.Element.ExpandableListItem.component`](M3e.Element.ExpandableListItem#component).
-}
expandableListItem :
    List (Attr ExpandableListItemAttrs msg)
    -> List (Element ExpandableListItemContent (ExpandableListItemChildAdmittedBy childAdm) msg)
    -> Element (ExpandableListItemIs s) admittedBy msg
expandableListItem =
    ExpandableListItem_.component


{-| See [`M3e.Element.ExpandableListItem.Is`](M3e.Element.ExpandableListItem#Is).
-}
type alias ExpandableListItemIs s =
    ExpandableListItem_.Is s


{-| See [`M3e.Element.ExpandableListItem.Attrs`](M3e.Element.ExpandableListItem#Attrs).
-}
type alias ExpandableListItemAttrs =
    ExpandableListItem_.Attrs


{-| See [`M3e.Element.ExpandableListItem.Builder`](M3e.Element.ExpandableListItem#Builder).
-}
type alias ExpandableListItemBuilder attrCaps slotCaps msg kind =
    ExpandableListItem_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.ExpandableListItem.AttrCaps`](M3e.Element.ExpandableListItem#AttrCaps).
-}
type alias ExpandableListItemAttrCaps =
    ExpandableListItem_.AttrCaps


{-| See [`M3e.Element.ExpandableListItem.SlotCaps`](M3e.Element.ExpandableListItem#SlotCaps).
-}
type alias ExpandableListItemSlotCaps =
    ExpandableListItem_.SlotCaps


{-| See [`M3e.Element.ExpandableListItem.Content`](M3e.Element.ExpandableListItem#Content).
-}
type alias ExpandableListItemContent =
    ExpandableListItem_.Content


{-| See [`M3e.Element.ExpandableListItem.LeadingSlot`](M3e.Element.ExpandableListItem#LeadingSlot).
-}
type alias ExpandableListItemLeadingSlot =
    ExpandableListItem_.LeadingSlot


{-| See [`M3e.Element.ExpandableListItem.OverlineSlot`](M3e.Element.ExpandableListItem#OverlineSlot).
-}
type alias ExpandableListItemOverlineSlot =
    ExpandableListItem_.OverlineSlot


{-| See [`M3e.Element.ExpandableListItem.SupportingTextSlot`](M3e.Element.ExpandableListItem#SupportingTextSlot).
-}
type alias ExpandableListItemSupportingTextSlot =
    ExpandableListItem_.SupportingTextSlot


{-| See [`M3e.Element.ExpandableListItem.ToggleIconSlot`](M3e.Element.ExpandableListItem#ToggleIconSlot).
-}
type alias ExpandableListItemToggleIconSlot =
    ExpandableListItem_.ToggleIconSlot


{-| See [`M3e.Element.ExpandableListItem.ChildAdmittedBy`](M3e.Element.ExpandableListItem#ChildAdmittedBy).
-}
type alias ExpandableListItemChildAdmittedBy childAdm =
    ExpandableListItem_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.ExpandableListItem.disabled`](M3e.Element.ExpandableListItem#disabled).
-}
expandableListItemDisabled : Bool -> Attr { c | disabled : Supported } msg
expandableListItemDisabled =
    ExpandableListItem_.disabled


{-| See [`M3e.Element.ExpandableListItem.open`](M3e.Element.ExpandableListItem#open).
-}
expandableListItemOpen : Bool -> Attr { c | open : Supported } msg
expandableListItemOpen =
    ExpandableListItem_.open


{-| See [`M3e.Element.ExpandableListItem.onOpening`](M3e.Element.ExpandableListItem#onOpening).
-}
expandableListItemOnOpening : msg -> Attr { c | onOpening : Supported } msg
expandableListItemOnOpening =
    ExpandableListItem_.onOpening


{-| See [`M3e.Element.ExpandableListItem.onOpened`](M3e.Element.ExpandableListItem#onOpened).
-}
expandableListItemOnOpened : msg -> Attr { c | onOpened : Supported } msg
expandableListItemOnOpened =
    ExpandableListItem_.onOpened


{-| See [`M3e.Element.ExpandableListItem.onClosing`](M3e.Element.ExpandableListItem#onClosing).
-}
expandableListItemOnClosing : msg -> Attr { c | onClosing : Supported } msg
expandableListItemOnClosing =
    ExpandableListItem_.onClosing


{-| See [`M3e.Element.ExpandableListItem.onClosed`](M3e.Element.ExpandableListItem#onClosed).
-}
expandableListItemOnClosed : msg -> Attr { c | onClosed : Supported } msg
expandableListItemOnClosed =
    ExpandableListItem_.onClosed


{-| See [`M3e.Element.ExpandableListItem.items`](M3e.Element.ExpandableListItem#items).
-}
expandableListItemItems : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
expandableListItemItems =
    ExpandableListItem_.items


{-| See [`M3e.Element.ExpandableListItem.leading`](M3e.Element.ExpandableListItem#leading).
-}
expandableListItemLeading : Element ExpandableListItemLeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
expandableListItemLeading =
    ExpandableListItem_.leading


{-| See [`M3e.Element.ExpandableListItem.overline`](M3e.Element.ExpandableListItem#overline).
-}
expandableListItemOverline : Element ExpandableListItemOverlineSlot admittedBy msg -> Element free freeAdmittedBy msg
expandableListItemOverline =
    ExpandableListItem_.overline


{-| See [`M3e.Element.ExpandableListItem.supportingText`](M3e.Element.ExpandableListItem#supportingText).
-}
expandableListItemSupportingText : Element ExpandableListItemSupportingTextSlot admittedBy msg -> Element free freeAdmittedBy msg
expandableListItemSupportingText =
    ExpandableListItem_.supportingText


{-| See [`M3e.Element.ExpandableListItem.toggleIcon`](M3e.Element.ExpandableListItem#toggleIcon).
-}
expandableListItemToggleIcon : Element ExpandableListItemToggleIconSlot admittedBy msg -> Element free freeAdmittedBy msg
expandableListItemToggleIcon =
    ExpandableListItem_.toggleIcon


{-| See [`M3e.Element.ExpandableListItem.child`](M3e.Element.ExpandableListItem#child).
-}
expandableListItemChild : Element ExpandableListItemContent admittedBy msg -> Element free freeAdmittedBy msg
expandableListItemChild =
    ExpandableListItem_.child
