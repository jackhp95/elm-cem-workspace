module Sl.Component.CarouselItem exposing (CarouselItemIs, CarouselItemAttrs, CarouselItemBuilder, CarouselItemAttrCaps, CarouselItemSlotCaps, CarouselItemChildAdmittedBy, carouselItem, carouselItemChild)

{-| The **CarouselItem** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.CarouselItem`](Sl.Element.CarouselItem) as `carouselItem`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs CarouselItemIs, CarouselItemAttrs, CarouselItemBuilder, CarouselItemAttrCaps, CarouselItemSlotCaps, CarouselItemChildAdmittedBy, carouselItem, carouselItemChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import Sl.Element.CarouselItem as CarouselItem_


{-| The `carouselItem` element of this family — delegates to [`Sl.Element.CarouselItem.component`](Sl.Element.CarouselItem#component).
-}
carouselItem :
    List (Attr CarouselItemAttrs msg)
    -> List (Element childAccepts (CarouselItemChildAdmittedBy childAdm) msg)
    -> Element (CarouselItemIs s) admittedBy msg
carouselItem =
    CarouselItem_.component


{-| See [`Sl.Element.CarouselItem.Is`](Sl.Element.CarouselItem#Is).
-}
type alias CarouselItemIs s =
    CarouselItem_.Is s


{-| See [`Sl.Element.CarouselItem.Attrs`](Sl.Element.CarouselItem#Attrs).
-}
type alias CarouselItemAttrs =
    CarouselItem_.Attrs


{-| See [`Sl.Element.CarouselItem.Builder`](Sl.Element.CarouselItem#Builder).
-}
type alias CarouselItemBuilder attrCaps slotCaps msg kind =
    CarouselItem_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.CarouselItem.AttrCaps`](Sl.Element.CarouselItem#AttrCaps).
-}
type alias CarouselItemAttrCaps =
    CarouselItem_.AttrCaps


{-| See [`Sl.Element.CarouselItem.SlotCaps`](Sl.Element.CarouselItem#SlotCaps).
-}
type alias CarouselItemSlotCaps =
    CarouselItem_.SlotCaps


{-| See [`Sl.Element.CarouselItem.ChildAdmittedBy`](Sl.Element.CarouselItem#ChildAdmittedBy).
-}
type alias CarouselItemChildAdmittedBy childAdm =
    CarouselItem_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.CarouselItem.child`](Sl.Element.CarouselItem#child).
-}
carouselItemChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
carouselItemChild =
    CarouselItem_.child
