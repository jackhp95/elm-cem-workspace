module Sl.Build.Animation exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withDelay, withDirection, withDuration, withEasing, withEndDelay, withFill, withId, withIterationStart, withIterations, withName, withOnCancel, withOnFinish, withOnStart, withPlay, withPlaybackRate, withSlot, withStyle
    , withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withDelay, withDirection, withDuration, withEasing, withEndDelay, withFill, withId, withIterationStart, withIterations, withName, withOnCancel, withOnFinish, withOnStart, withPlay, withPlaybackRate, withSlot, withStyle
@docs withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Sl.Attributes as A
import Sl.Element.Animation as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


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
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-animation" [] []


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
withDelay : Float -> Builder { a | delay : Available } slotCaps msg kind -> Builder { a | delay : Used } slotCaps msg kind
withDelay value_ =
    B.withAttribute (A.delay value_)


{-| -}
withDirection : String -> Builder { a | direction : Available } slotCaps msg kind -> Builder { a | direction : Used } slotCaps msg kind
withDirection value_ =
    B.withAttribute (A.direction value_)


{-| -}
withDuration : Float -> Builder { a | duration : Available } slotCaps msg kind -> Builder { a | duration : Used } slotCaps msg kind
withDuration value_ =
    B.withAttribute (A.duration value_)


{-| -}
withEasing : String -> Builder { a | easing : Available } slotCaps msg kind -> Builder { a | easing : Used } slotCaps msg kind
withEasing value_ =
    B.withAttribute (A.easing value_)


{-| -}
withEndDelay : Float -> Builder { a | endDelay : Available } slotCaps msg kind -> Builder { a | endDelay : Used } slotCaps msg kind
withEndDelay value_ =
    B.withAttribute (A.endDelay value_)


{-| -}
withFill : String -> Builder { a | fill : Available } slotCaps msg kind -> Builder { a | fill : Used } slotCaps msg kind
withFill value_ =
    B.withAttribute (A.fill value_)


{-| -}
withIterationStart : Float -> Builder { a | iterationStart : Available } slotCaps msg kind -> Builder { a | iterationStart : Used } slotCaps msg kind
withIterationStart value_ =
    B.withAttribute (A.iterationStart value_)


{-| -}
withIterations : String -> Builder { a | iterations : Available } slotCaps msg kind -> Builder { a | iterations : Used } slotCaps msg kind
withIterations value_ =
    B.withAttribute (A.iterations value_)


{-| -}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (A.name value_)


{-| -}
withPlay : Bool -> Builder { a | play : Available } slotCaps msg kind -> Builder { a | play : Used } slotCaps msg kind
withPlay value_ =
    B.withAttribute (A.play value_)


{-| -}
withPlaybackRate : Float -> Builder { a | playbackRate : Available } slotCaps msg kind -> Builder { a | playbackRate : Used } slotCaps msg kind
withPlaybackRate value_ =
    B.withAttribute (A.playbackRate value_)


{-| -}
withOnCancel : msg -> Builder { a | onCancel : Available } slotCaps msg kind -> Builder { a | onCancel : Used } slotCaps msg kind
withOnCancel value_ =
    B.withAttribute (Ev.onCancel value_)


{-| -}
withOnFinish : msg -> Builder { a | onFinish : Available } slotCaps msg kind -> Builder { a | onFinish : Used } slotCaps msg kind
withOnFinish value_ =
    B.withAttribute (Ev.onFinish value_)


{-| -}
withOnStart : msg -> Builder { a | onStart : Available } slotCaps msg kind -> Builder { a | onStart : Used } slotCaps msg kind
withOnStart value_ =
    B.withAttribute (Ev.onStart value_)
