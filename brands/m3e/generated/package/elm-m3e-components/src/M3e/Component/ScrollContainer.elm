module M3e.Component.ScrollContainer exposing (ScrollContainerIs, ScrollContainerAttrs, ScrollContainerBuilder, ScrollContainerAttrCaps, ScrollContainerSlotCaps, ScrollContainerChildAdmittedBy, ScrollContainerDividers, scrollContainer, scrollContainerDividers, scrollContainerThin, scrollContainerChild)

{-| The **ScrollContainer** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.ScrollContainer`](M3e.Element.ScrollContainer) as `scrollContainer`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ScrollContainerIs, ScrollContainerAttrs, ScrollContainerBuilder, ScrollContainerAttrCaps, ScrollContainerSlotCaps, ScrollContainerChildAdmittedBy, ScrollContainerDividers, scrollContainer, scrollContainerDividers, scrollContainerThin, scrollContainerChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.ScrollContainer as ScrollContainer_


{-| The `scrollContainer` element of this family — delegates to [`M3e.Element.ScrollContainer.component`](M3e.Element.ScrollContainer#component).
-}
scrollContainer :
    List (Attr ScrollContainerAttrs msg)
    -> List (Element childAccepts (ScrollContainerChildAdmittedBy childAdm) msg)
    -> Element (ScrollContainerIs s) admittedBy msg
scrollContainer =
    ScrollContainer_.component


{-| See [`M3e.Element.ScrollContainer.Is`](M3e.Element.ScrollContainer#Is).
-}
type alias ScrollContainerIs s =
    ScrollContainer_.Is s


{-| See [`M3e.Element.ScrollContainer.Attrs`](M3e.Element.ScrollContainer#Attrs).
-}
type alias ScrollContainerAttrs =
    ScrollContainer_.Attrs


{-| See [`M3e.Element.ScrollContainer.Builder`](M3e.Element.ScrollContainer#Builder).
-}
type alias ScrollContainerBuilder attrCaps slotCaps msg kind =
    ScrollContainer_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.ScrollContainer.AttrCaps`](M3e.Element.ScrollContainer#AttrCaps).
-}
type alias ScrollContainerAttrCaps =
    ScrollContainer_.AttrCaps


{-| See [`M3e.Element.ScrollContainer.SlotCaps`](M3e.Element.ScrollContainer#SlotCaps).
-}
type alias ScrollContainerSlotCaps =
    ScrollContainer_.SlotCaps


{-| See [`M3e.Element.ScrollContainer.ChildAdmittedBy`](M3e.Element.ScrollContainer#ChildAdmittedBy).
-}
type alias ScrollContainerChildAdmittedBy childAdm =
    ScrollContainer_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.ScrollContainer.Dividers`](M3e.Element.ScrollContainer#Dividers).
-}
type alias ScrollContainerDividers =
    ScrollContainer_.Dividers


{-| See [`M3e.Element.ScrollContainer.dividers`](M3e.Element.ScrollContainer#dividers).
-}
scrollContainerDividers : Value ScrollContainerDividers -> Attr { c | dividers : Supported } msg
scrollContainerDividers =
    ScrollContainer_.dividers


{-| See [`M3e.Element.ScrollContainer.thin`](M3e.Element.ScrollContainer#thin).
-}
scrollContainerThin : Bool -> Attr { c | thin : Supported } msg
scrollContainerThin =
    ScrollContainer_.thin


{-| See [`M3e.Element.ScrollContainer.child`](M3e.Element.ScrollContainer#child).
-}
scrollContainerChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
scrollContainerChild =
    ScrollContainer_.child
