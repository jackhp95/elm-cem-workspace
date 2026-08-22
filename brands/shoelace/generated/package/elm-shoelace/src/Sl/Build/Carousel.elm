module Sl.Build.Carousel exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
    , withAutoplay, withAutoplayInterval, withClass, withId, withLoop, withMouseDragging, withNavigation, withOnSlideChange, withOrientation, withPagination, withSlidesPerMove, withSlidesPerPage, withSlot, withStyle
    , withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
@docs withAutoplay, withAutoplayInterval, withClass, withId, withLoop, withMouseDragging, withNavigation, withOnSlideChange, withOrientation, withPagination, withSlidesPerMove, withSlidesPerPage, withSlot, withStyle
@docs withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Element.Carousel as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.AttrCaps


{-| -}
type alias SlotCaps =
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.Content


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-carousel" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
withChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
withClass : String -> Builder { a | class : Available } slotCaps msg kind -> Builder { a | class : Used } slotCaps msg kind
withClass value_ =
    B.withAttribute (A.class value_)


{-| -}
withId : String -> Builder { a | id : Available } slotCaps msg kind -> Builder { a | id : Used } slotCaps msg kind
withId value_ =
    B.withAttribute (A.id value_)


{-| -}
withSlot : String -> Builder { a | slot : Available } slotCaps msg kind -> Builder { a | slot : Used } slotCaps msg kind
withSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
withStyle : String -> String -> Builder { a | style : Available } slotCaps msg kind -> Builder { a | style : Used } slotCaps msg kind
withStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
withAutoplay : Bool -> Builder { a | autoplay : Available } slotCaps msg kind -> Builder { a | autoplay : Used } slotCaps msg kind
withAutoplay value_ =
    B.withAttribute (A.autoplay value_)


{-| -}
withAutoplayInterval : Float -> Builder { a | autoplayInterval : Available } slotCaps msg kind -> Builder { a | autoplayInterval : Used } slotCaps msg kind
withAutoplayInterval value_ =
    B.withAttribute (A.autoplayInterval value_)


{-| -}
withLoop : Bool -> Builder { a | loop : Available } slotCaps msg kind -> Builder { a | loop : Used } slotCaps msg kind
withLoop value_ =
    B.withAttribute (A.loop value_)


{-| -}
withMouseDragging : Bool -> Builder { a | mouseDragging : Available } slotCaps msg kind -> Builder { a | mouseDragging : Used } slotCaps msg kind
withMouseDragging value_ =
    B.withAttribute (A.mouseDragging value_)


{-| -}
withNavigation : Bool -> Builder { a | navigation : Available } slotCaps msg kind -> Builder { a | navigation : Used } slotCaps msg kind
withNavigation value_ =
    B.withAttribute (A.navigation value_)


{-| -}
withOrientation : Value Component.Orientation -> Builder { a | orientation : Available } slotCaps msg kind -> Builder { a | orientation : Used } slotCaps msg kind
withOrientation value_ =
    B.withAttribute (Component.orientation value_)


{-| -}
withPagination : Bool -> Builder { a | pagination : Available } slotCaps msg kind -> Builder { a | pagination : Used } slotCaps msg kind
withPagination value_ =
    B.withAttribute (A.pagination value_)


{-| -}
withSlidesPerMove : Float -> Builder { a | slidesPerMove : Available } slotCaps msg kind -> Builder { a | slidesPerMove : Used } slotCaps msg kind
withSlidesPerMove value_ =
    B.withAttribute (A.slidesPerMove value_)


{-| -}
withSlidesPerPage : Float -> Builder { a | slidesPerPage : Available } slotCaps msg kind -> Builder { a | slidesPerPage : Used } slotCaps msg kind
withSlidesPerPage value_ =
    B.withAttribute (A.slidesPerPage value_)


{-| -}
withOnSlideChange : msg -> Builder { a | onSlideChange : Available } slotCaps msg kind -> Builder { a | onSlideChange : Used } slotCaps msg kind
withOnSlideChange value_ =
    B.withAttribute (Ev.onSlideChange value_)
