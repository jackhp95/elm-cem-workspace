module M3e.Build.Timepicker exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withConfirmLabel, withDate, withDialLabel, withDismissLabel, withFor, withFormat, withHideModeToggle, withHourLabel, withId, withInputLabel, withMaxTime, withMinTime, withMinuteLabel, withMode, withModeToggleLabel, withOnBeforetoggle, withOnChange, withOnToggle, withOrientation, withPeriodToggleLabel, withSecondLabel, withShowSeconds, withSlot, withStyle, withVariant
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withConfirmLabel, withDate, withDialLabel, withDismissLabel, withFor, withFormat, withHideModeToggle, withHourLabel, withId, withInputLabel, withMaxTime, withMinTime, withMinuteLabel, withMode, withModeToggleLabel, withOnBeforetoggle, withOnChange, withOnToggle, withOrientation, withPeriodToggleLabel, withSecondLabel, withShowSeconds, withSlot, withStyle, withVariant

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Timepicker as Component
import M3e.Events as Ev
import M3e.Internal.Types.Timepicker
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    M3e.Internal.Types.Timepicker.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Timepicker.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.Timepicker.AttrCaps


{-| -}
type alias SlotCaps =
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Timepicker.ChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-timepicker" [] []


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
withConfirmLabel : String -> Builder { a | confirmLabel : Available } slotCaps msg kind -> Builder { a | confirmLabel : Used } slotCaps msg kind
withConfirmLabel value_ =
    B.withAttribute (A.confirmLabel value_)


{-| -}
withDate : String -> Builder { a | date : Available } slotCaps msg kind -> Builder { a | date : Used } slotCaps msg kind
withDate value_ =
    B.withAttribute (A.date value_)


{-| -}
withDialLabel : String -> Builder { a | dialLabel : Available } slotCaps msg kind -> Builder { a | dialLabel : Used } slotCaps msg kind
withDialLabel value_ =
    B.withAttribute (A.dialLabel value_)


{-| -}
withDismissLabel : String -> Builder { a | dismissLabel : Available } slotCaps msg kind -> Builder { a | dismissLabel : Used } slotCaps msg kind
withDismissLabel value_ =
    B.withAttribute (A.dismissLabel value_)


{-| -}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| -}
withFormat : Value Component.Format -> Builder { a | format : Available } slotCaps msg kind -> Builder { a | format : Used } slotCaps msg kind
withFormat value_ =
    B.withAttribute (Component.format value_)


{-| -}
withHideModeToggle : Bool -> Builder { a | hideModeToggle : Available } slotCaps msg kind -> Builder { a | hideModeToggle : Used } slotCaps msg kind
withHideModeToggle value_ =
    B.withAttribute (A.hideModeToggle value_)


{-| -}
withHourLabel : String -> Builder { a | hourLabel : Available } slotCaps msg kind -> Builder { a | hourLabel : Used } slotCaps msg kind
withHourLabel value_ =
    B.withAttribute (A.hourLabel value_)


{-| -}
withInputLabel : String -> Builder { a | inputLabel : Available } slotCaps msg kind -> Builder { a | inputLabel : Used } slotCaps msg kind
withInputLabel value_ =
    B.withAttribute (A.inputLabel value_)


{-| -}
withMaxTime : String -> Builder { a | maxTime : Available } slotCaps msg kind -> Builder { a | maxTime : Used } slotCaps msg kind
withMaxTime value_ =
    B.withAttribute (A.maxTime value_)


{-| -}
withMinTime : String -> Builder { a | minTime : Available } slotCaps msg kind -> Builder { a | minTime : Used } slotCaps msg kind
withMinTime value_ =
    B.withAttribute (A.minTime value_)


{-| -}
withMinuteLabel : String -> Builder { a | minuteLabel : Available } slotCaps msg kind -> Builder { a | minuteLabel : Used } slotCaps msg kind
withMinuteLabel value_ =
    B.withAttribute (A.minuteLabel value_)


{-| -}
withMode : Value Component.Mode -> Builder { a | mode : Available } slotCaps msg kind -> Builder { a | mode : Used } slotCaps msg kind
withMode value_ =
    B.withAttribute (Component.mode value_)


{-| -}
withModeToggleLabel : String -> Builder { a | modeToggleLabel : Available } slotCaps msg kind -> Builder { a | modeToggleLabel : Used } slotCaps msg kind
withModeToggleLabel value_ =
    B.withAttribute (A.modeToggleLabel value_)


{-| -}
withOrientation : Value Component.Orientation -> Builder { a | orientation : Available } slotCaps msg kind -> Builder { a | orientation : Used } slotCaps msg kind
withOrientation value_ =
    B.withAttribute (Component.orientation value_)


{-| -}
withPeriodToggleLabel : String -> Builder { a | periodToggleLabel : Available } slotCaps msg kind -> Builder { a | periodToggleLabel : Used } slotCaps msg kind
withPeriodToggleLabel value_ =
    B.withAttribute (A.periodToggleLabel value_)


{-| -}
withSecondLabel : String -> Builder { a | secondLabel : Available } slotCaps msg kind -> Builder { a | secondLabel : Used } slotCaps msg kind
withSecondLabel value_ =
    B.withAttribute (A.secondLabel value_)


{-| -}
withShowSeconds : Bool -> Builder { a | showSeconds : Available } slotCaps msg kind -> Builder { a | showSeconds : Used } slotCaps msg kind
withShowSeconds value_ =
    B.withAttribute (A.showSeconds value_)


{-| -}
withVariant : Value Component.Variant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.variant value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
withOnBeforetoggle : msg -> Builder { a | onBeforetoggle : Available } slotCaps msg kind -> Builder { a | onBeforetoggle : Used } slotCaps msg kind
withOnBeforetoggle value_ =
    B.withAttribute (Ev.onBeforetoggle value_)


{-| -}
withOnToggle : msg -> Builder { a | onToggle : Available } slotCaps msg kind -> Builder { a | onToggle : Used } slotCaps msg kind
withOnToggle value_ =
    B.withAttribute (Ev.onToggle value_)
