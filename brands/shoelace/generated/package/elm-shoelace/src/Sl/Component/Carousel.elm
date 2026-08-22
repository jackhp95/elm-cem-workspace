module Sl.Component.Carousel exposing (CarouselIs, CarouselAttrs, CarouselBuilder, CarouselAttrCaps, CarouselSlotCaps, CarouselChildAdmittedBy, CarouselOrientation, carousel, carouselOrientation, carouselAutoplay, carouselAutoplayInterval, carouselLoop, carouselMouseDragging, carouselNavigation, carouselPagination, carouselSlidesPerMove, carouselSlidesPerPage, carouselOnSlideChange)

{-| The **Carousel** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Carousel`](Sl.Element.Carousel) as `carousel`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs CarouselIs, CarouselAttrs, CarouselBuilder, CarouselAttrCaps, CarouselSlotCaps, CarouselChildAdmittedBy, CarouselOrientation, carousel, carouselOrientation, carouselAutoplay, carouselAutoplayInterval, carouselLoop, carouselMouseDragging, carouselNavigation, carouselPagination, carouselSlidesPerMove, carouselSlidesPerPage, carouselOnSlideChange

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Carousel as Carousel_


{-| The `carousel` element of this family — delegates to [`Sl.Element.Carousel.component`](Sl.Element.Carousel#component).
-}
carousel :
    List (Attr CarouselAttrs msg)
    -> List (Element childAccepts (CarouselChildAdmittedBy childAdm) msg)
    -> Element (CarouselIs s) admittedBy msg
carousel =
    Carousel_.component


{-| See [`Sl.Element.Carousel.Is`](Sl.Element.Carousel#Is).
-}
type alias CarouselIs s =
    Carousel_.Is s


{-| See [`Sl.Element.Carousel.Attrs`](Sl.Element.Carousel#Attrs).
-}
type alias CarouselAttrs =
    Carousel_.Attrs


{-| See [`Sl.Element.Carousel.Builder`](Sl.Element.Carousel#Builder).
-}
type alias CarouselBuilder attrCaps slotCaps msg kind =
    Carousel_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Carousel.AttrCaps`](Sl.Element.Carousel#AttrCaps).
-}
type alias CarouselAttrCaps =
    Carousel_.AttrCaps


{-| See [`Sl.Element.Carousel.SlotCaps`](Sl.Element.Carousel#SlotCaps).
-}
type alias CarouselSlotCaps =
    Carousel_.SlotCaps


{-| See [`Sl.Element.Carousel.ChildAdmittedBy`](Sl.Element.Carousel#ChildAdmittedBy).
-}
type alias CarouselChildAdmittedBy childAdm =
    Carousel_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Carousel.Orientation`](Sl.Element.Carousel#Orientation).
-}
type alias CarouselOrientation =
    Carousel_.Orientation


{-| See [`Sl.Element.Carousel.orientation`](Sl.Element.Carousel#orientation).
-}
carouselOrientation : Value CarouselOrientation -> Attr { c | orientation : Supported } msg
carouselOrientation =
    Carousel_.orientation


{-| See [`Sl.Element.Carousel.autoplay`](Sl.Element.Carousel#autoplay).
-}
carouselAutoplay : Bool -> Attr { c | autoplay : Supported } msg
carouselAutoplay =
    Carousel_.autoplay


{-| See [`Sl.Element.Carousel.autoplayInterval`](Sl.Element.Carousel#autoplayInterval).
-}
carouselAutoplayInterval : Float -> Attr { c | autoplayInterval : Supported } msg
carouselAutoplayInterval =
    Carousel_.autoplayInterval


{-| See [`Sl.Element.Carousel.loop`](Sl.Element.Carousel#loop).
-}
carouselLoop : Bool -> Attr { c | loop : Supported } msg
carouselLoop =
    Carousel_.loop


{-| See [`Sl.Element.Carousel.mouseDragging`](Sl.Element.Carousel#mouseDragging).
-}
carouselMouseDragging : Bool -> Attr { c | mouseDragging : Supported } msg
carouselMouseDragging =
    Carousel_.mouseDragging


{-| See [`Sl.Element.Carousel.navigation`](Sl.Element.Carousel#navigation).
-}
carouselNavigation : Bool -> Attr { c | navigation : Supported } msg
carouselNavigation =
    Carousel_.navigation


{-| See [`Sl.Element.Carousel.pagination`](Sl.Element.Carousel#pagination).
-}
carouselPagination : Bool -> Attr { c | pagination : Supported } msg
carouselPagination =
    Carousel_.pagination


{-| See [`Sl.Element.Carousel.slidesPerMove`](Sl.Element.Carousel#slidesPerMove).
-}
carouselSlidesPerMove : Float -> Attr { c | slidesPerMove : Supported } msg
carouselSlidesPerMove =
    Carousel_.slidesPerMove


{-| See [`Sl.Element.Carousel.slidesPerPage`](Sl.Element.Carousel#slidesPerPage).
-}
carouselSlidesPerPage : Float -> Attr { c | slidesPerPage : Supported } msg
carouselSlidesPerPage =
    Carousel_.slidesPerPage


{-| See [`Sl.Element.Carousel.onSlideChange`](Sl.Element.Carousel#onSlideChange).
-}
carouselOnSlideChange : msg -> Attr { c | onSlideChange : Supported } msg
carouselOnSlideChange =
    Carousel_.onSlideChange
