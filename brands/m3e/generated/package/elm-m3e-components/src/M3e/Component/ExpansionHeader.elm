module M3e.Component.ExpansionHeader exposing (ExpansionHeaderIs, ExpansionHeaderAttrs, ExpansionHeaderBuilder, ExpansionHeaderAttrCaps, ExpansionHeaderSlotCaps, ExpansionHeaderContent, ExpansionHeaderToggleIconSlot, ExpansionHeaderChildAdmittedBy, ExpansionHeaderToggleDirection, ExpansionHeaderTogglePosition, expansionHeader, expansionHeaderToggleDirection, expansionHeaderTogglePosition, expansionHeaderDisabled, expansionHeaderHideToggle, expansionHeaderOnClick, expansionHeaderToggleIcon, expansionHeaderChild)

{-| The **ExpansionHeader** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.ExpansionHeader`](M3e.Element.ExpansionHeader) as `expansionHeader`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ExpansionHeaderIs, ExpansionHeaderAttrs, ExpansionHeaderBuilder, ExpansionHeaderAttrCaps, ExpansionHeaderSlotCaps, ExpansionHeaderContent, ExpansionHeaderToggleIconSlot, ExpansionHeaderChildAdmittedBy, ExpansionHeaderToggleDirection, ExpansionHeaderTogglePosition, expansionHeader, expansionHeaderToggleDirection, expansionHeaderTogglePosition, expansionHeaderDisabled, expansionHeaderHideToggle, expansionHeaderOnClick, expansionHeaderToggleIcon, expansionHeaderChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.ExpansionHeader as ExpansionHeader_


{-| The `expansionHeader` element of this family — delegates to [`M3e.Element.ExpansionHeader.component`](M3e.Element.ExpansionHeader#component).
-}
expansionHeader :
    List (Attr ExpansionHeaderAttrs msg)
    -> List (Element ExpansionHeaderContent (ExpansionHeaderChildAdmittedBy childAdm) msg)
    -> Element (ExpansionHeaderIs s) admittedBy msg
expansionHeader =
    ExpansionHeader_.component


{-| See [`M3e.Element.ExpansionHeader.Is`](M3e.Element.ExpansionHeader#Is).
-}
type alias ExpansionHeaderIs s =
    ExpansionHeader_.Is s


{-| See [`M3e.Element.ExpansionHeader.Attrs`](M3e.Element.ExpansionHeader#Attrs).
-}
type alias ExpansionHeaderAttrs =
    ExpansionHeader_.Attrs


{-| See [`M3e.Element.ExpansionHeader.Builder`](M3e.Element.ExpansionHeader#Builder).
-}
type alias ExpansionHeaderBuilder attrCaps slotCaps msg kind =
    ExpansionHeader_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.ExpansionHeader.AttrCaps`](M3e.Element.ExpansionHeader#AttrCaps).
-}
type alias ExpansionHeaderAttrCaps =
    ExpansionHeader_.AttrCaps


{-| See [`M3e.Element.ExpansionHeader.SlotCaps`](M3e.Element.ExpansionHeader#SlotCaps).
-}
type alias ExpansionHeaderSlotCaps =
    ExpansionHeader_.SlotCaps


{-| See [`M3e.Element.ExpansionHeader.Content`](M3e.Element.ExpansionHeader#Content).
-}
type alias ExpansionHeaderContent =
    ExpansionHeader_.Content


{-| See [`M3e.Element.ExpansionHeader.ToggleIconSlot`](M3e.Element.ExpansionHeader#ToggleIconSlot).
-}
type alias ExpansionHeaderToggleIconSlot =
    ExpansionHeader_.ToggleIconSlot


{-| See [`M3e.Element.ExpansionHeader.ChildAdmittedBy`](M3e.Element.ExpansionHeader#ChildAdmittedBy).
-}
type alias ExpansionHeaderChildAdmittedBy childAdm =
    ExpansionHeader_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.ExpansionHeader.ToggleDirection`](M3e.Element.ExpansionHeader#ToggleDirection).
-}
type alias ExpansionHeaderToggleDirection =
    ExpansionHeader_.ToggleDirection


{-| See [`M3e.Element.ExpansionHeader.toggleDirection`](M3e.Element.ExpansionHeader#toggleDirection).
-}
expansionHeaderToggleDirection : Value ExpansionHeaderToggleDirection -> Attr { c | toggleDirection : Supported } msg
expansionHeaderToggleDirection =
    ExpansionHeader_.toggleDirection


{-| See [`M3e.Element.ExpansionHeader.TogglePosition`](M3e.Element.ExpansionHeader#TogglePosition).
-}
type alias ExpansionHeaderTogglePosition =
    ExpansionHeader_.TogglePosition


{-| See [`M3e.Element.ExpansionHeader.togglePosition`](M3e.Element.ExpansionHeader#togglePosition).
-}
expansionHeaderTogglePosition : Value ExpansionHeaderTogglePosition -> Attr { c | togglePosition : Supported } msg
expansionHeaderTogglePosition =
    ExpansionHeader_.togglePosition


{-| See [`M3e.Element.ExpansionHeader.disabled`](M3e.Element.ExpansionHeader#disabled).
-}
expansionHeaderDisabled : Bool -> Attr { c | disabled : Supported } msg
expansionHeaderDisabled =
    ExpansionHeader_.disabled


{-| See [`M3e.Element.ExpansionHeader.hideToggle`](M3e.Element.ExpansionHeader#hideToggle).
-}
expansionHeaderHideToggle : Bool -> Attr { c | hideToggle : Supported } msg
expansionHeaderHideToggle =
    ExpansionHeader_.hideToggle


{-| See [`M3e.Element.ExpansionHeader.onClick`](M3e.Element.ExpansionHeader#onClick).
-}
expansionHeaderOnClick : msg -> Attr { c | onClick : Supported } msg
expansionHeaderOnClick =
    ExpansionHeader_.onClick


{-| See [`M3e.Element.ExpansionHeader.toggleIcon`](M3e.Element.ExpansionHeader#toggleIcon).
-}
expansionHeaderToggleIcon : Element ExpansionHeaderToggleIconSlot admittedBy msg -> Element free freeAdmittedBy msg
expansionHeaderToggleIcon =
    ExpansionHeader_.toggleIcon


{-| See [`M3e.Element.ExpansionHeader.child`](M3e.Element.ExpansionHeader#child).
-}
expansionHeaderChild : Element ExpansionHeaderContent admittedBy msg -> Element free freeAdmittedBy msg
expansionHeaderChild =
    ExpansionHeader_.child
