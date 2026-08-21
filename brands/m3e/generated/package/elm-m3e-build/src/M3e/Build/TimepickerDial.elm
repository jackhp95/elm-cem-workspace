module M3e.Build.TimepickerDial exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withFormat, withHour, withId, withMaxTime, withMinTime, withMinute, withOnChange, withOnInput, withOnViewChange, withPeriod, withSecond, withShowSeconds, withSlot, withStyle, withViewAttr
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withFormat, withHour, withId, withMaxTime, withMinTime, withMinute, withOnChange, withOnInput, withOnViewChange, withPeriod, withSecond, withShowSeconds, withSlot, withStyle, withViewAttr

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Component.TimepickerDial as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


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
    B.init "m3e-timepicker-dial" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


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
withFormat : Value Component.Format -> Builder { a | format : Available } slotCaps msg kind -> Builder { a | format : Used } slotCaps msg kind
withFormat value_ =
    B.withAttribute (Component.format value_)


{-| -}
withHour : Float -> Builder { a | hour : Available } slotCaps msg kind -> Builder { a | hour : Used } slotCaps msg kind
withHour value_ =
    B.withAttribute (A.hour value_)


{-| -}
withMaxTime : String -> Builder { a | maxTime : Available } slotCaps msg kind -> Builder { a | maxTime : Used } slotCaps msg kind
withMaxTime value_ =
    B.withAttribute (A.maxTime value_)


{-| -}
withMinTime : String -> Builder { a | minTime : Available } slotCaps msg kind -> Builder { a | minTime : Used } slotCaps msg kind
withMinTime value_ =
    B.withAttribute (A.minTime value_)


{-| -}
withMinute : Float -> Builder { a | minute : Available } slotCaps msg kind -> Builder { a | minute : Used } slotCaps msg kind
withMinute value_ =
    B.withAttribute (A.minute value_)


{-| -}
withPeriod : Value Component.Period -> Builder { a | period : Available } slotCaps msg kind -> Builder { a | period : Used } slotCaps msg kind
withPeriod value_ =
    B.withAttribute (Component.period value_)


{-| -}
withSecond : Float -> Builder { a | second : Available } slotCaps msg kind -> Builder { a | second : Used } slotCaps msg kind
withSecond value_ =
    B.withAttribute (A.second value_)


{-| -}
withShowSeconds : Bool -> Builder { a | showSeconds : Available } slotCaps msg kind -> Builder { a | showSeconds : Used } slotCaps msg kind
withShowSeconds value_ =
    B.withAttribute (A.showSeconds value_)


{-| -}
withViewAttr : Value Component.ViewAttr -> Builder { a | viewAttr : Available } slotCaps msg kind -> Builder { a | viewAttr : Used } slotCaps msg kind
withViewAttr value_ =
    B.withAttribute (Component.viewAttr value_)


{-| -}
withOnInput : msg -> Builder { a | onInput : Available } slotCaps msg kind -> Builder { a | onInput : Used } slotCaps msg kind
withOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
withOnViewChange : msg -> Builder { a | onViewChange : Available } slotCaps msg kind -> Builder { a | onViewChange : Used } slotCaps msg kind
withOnViewChange value_ =
    B.withAttribute (Ev.onViewChange value_)
