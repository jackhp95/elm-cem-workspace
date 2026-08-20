module Sl.Component.Carousel exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Orientation, orientation
    , autoplay, autoplayInterval, loop, mouseDragging, navigation, pagination, slidesPerMove, slidesPerPage, onSlideChange
    )

{-| The `sl-carousel` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Orientation, orientation
@docs autoplay, autoplayInterval, loop, mouseDragging, navigation, pagination, slidesPerMove, slidesPerPage, onSlideChange

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Carousel
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-carousel` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Carousel.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Carousel.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Carousel.ChildAdmittedBy childAdm


{-| The `orientation` values valid on this component (compile-tight narrowing).
-}
type alias Orientation =
    Sl.Internal.Types.Carousel.Orientation


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Carousel.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Carousel.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.carousel


{-| Specifies the orientation in which the carousel will lay out. (default: `'horizontal'`)
-}
orientation : Value Orientation -> Attr { c | orientation : Supported } msg
orientation value_ =
    Ir.attribute "orientation" (Val.toString value_)


{-| See `Sl.Attributes.autoplay`.
-}
autoplay : Bool -> Attr { c | autoplay : Supported } msg
autoplay =
    A.autoplay


{-| See `Sl.Attributes.autoplayInterval`.
-}
autoplayInterval : Float -> Attr { c | autoplayInterval : Supported } msg
autoplayInterval =
    A.autoplayInterval


{-| See `Sl.Attributes.loop`.
-}
loop : Bool -> Attr { c | loop : Supported } msg
loop =
    A.loop


{-| See `Sl.Attributes.mouseDragging`.
-}
mouseDragging : Bool -> Attr { c | mouseDragging : Supported } msg
mouseDragging =
    A.mouseDragging


{-| See `Sl.Attributes.navigation`.
-}
navigation : Bool -> Attr { c | navigation : Supported } msg
navigation =
    A.navigation


{-| See `Sl.Attributes.pagination`.
-}
pagination : Bool -> Attr { c | pagination : Supported } msg
pagination =
    A.pagination


{-| See `Sl.Attributes.slidesPerMove`.
-}
slidesPerMove : Float -> Attr { c | slidesPerMove : Supported } msg
slidesPerMove =
    A.slidesPerMove


{-| See `Sl.Attributes.slidesPerPage`.
-}
slidesPerPage : Float -> Attr { c | slidesPerPage : Supported } msg
slidesPerPage =
    A.slidesPerPage


{-| See `Sl.Events.onSlideChange`.
-}
onSlideChange : msg -> Attr { c | onSlideChange : Supported } msg
onSlideChange =
    Ev.onSlideChange
