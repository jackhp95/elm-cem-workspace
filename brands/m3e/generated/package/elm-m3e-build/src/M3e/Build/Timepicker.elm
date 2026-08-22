module M3e.Build.Timepicker exposing (TimepickerBuilder, TimepickerAttrCaps, TimepickerSlotCaps, TimepickerIs, TimepickerChildAdmittedBy, timepickerBuild, timepickerToElement, timepickerWithClass, timepickerWithConfirmLabel, timepickerWithDate, timepickerWithDialLabel, timepickerWithDismissLabel, timepickerWithFor, timepickerWithFormat, timepickerWithHideModeToggle, timepickerWithHourLabel, timepickerWithId, timepickerWithInputLabel, timepickerWithMaxTime, timepickerWithMinTime, timepickerWithMinuteLabel, timepickerWithMode, timepickerWithModeToggleLabel, timepickerWithOnBeforetoggle, timepickerWithOnChange, timepickerWithOnToggle, timepickerWithOrientation, timepickerWithPeriodToggleLabel, timepickerWithSecondLabel, timepickerWithShowSeconds, timepickerWithSlot, timepickerWithStyle, timepickerWithVariant, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleIs, ToggleChildAdmittedBy, toggleBuild, toggleToElement, toggleWithClass, toggleWithFor, toggleWithId, toggleWithSlot, toggleWithStyle, DialBuilder, DialAttrCaps, DialSlotCaps, DialIs, DialChildAdmittedBy, dialBuild, dialToElement, dialWithClass, dialWithFormat, dialWithHour, dialWithId, dialWithMaxTime, dialWithMinTime, dialWithMinute, dialWithOnChange, dialWithOnInput, dialWithOnViewChange, dialWithPeriod, dialWithSecond, dialWithShowSeconds, dialWithSlot, dialWithStyle, dialWithViewAttr, InputBuilder, InputAttrCaps, InputSlotCaps, InputIs, InputChildAdmittedBy, inputBuild, inputToElement, inputWithClass, inputWithFor, inputWithFormat, inputWithHideLabels, inputWithHour, inputWithHourLabel, inputWithId, inputWithMaxTime, inputWithMinTime, inputWithMinute, inputWithMinuteLabel, inputWithOnChange, inputWithOnViewChange, inputWithOrientation, inputWithPeriod, inputWithPeriodToggleLabel, inputWithSecond, inputWithSecondLabel, inputWithShowSeconds, inputWithSlot, inputWithStyle, inputWithViewAttr, InputPeriodToggleBuilder, InputPeriodToggleAttrCaps, InputPeriodToggleSlotCaps, InputPeriodToggleIs, InputPeriodToggleChildAdmittedBy, inputPeriodToggleBuild, inputPeriodToggleToElement, inputPeriodToggleWithClass, inputPeriodToggleWithId, inputPeriodToggleWithOnChange, inputPeriodToggleWithOrientation, inputPeriodToggleWithPeriod, inputPeriodToggleWithSlot, inputPeriodToggleWithStyle)

{-| The **Timepicker** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.Timepicker`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs TimepickerBuilder, TimepickerAttrCaps, TimepickerSlotCaps, TimepickerIs, TimepickerChildAdmittedBy, timepickerBuild, timepickerToElement, timepickerWithClass, timepickerWithConfirmLabel, timepickerWithDate, timepickerWithDialLabel, timepickerWithDismissLabel, timepickerWithFor, timepickerWithFormat, timepickerWithHideModeToggle, timepickerWithHourLabel, timepickerWithId, timepickerWithInputLabel, timepickerWithMaxTime, timepickerWithMinTime, timepickerWithMinuteLabel, timepickerWithMode, timepickerWithModeToggleLabel, timepickerWithOnBeforetoggle, timepickerWithOnChange, timepickerWithOnToggle, timepickerWithOrientation, timepickerWithPeriodToggleLabel, timepickerWithSecondLabel, timepickerWithShowSeconds, timepickerWithSlot, timepickerWithStyle, timepickerWithVariant, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleIs, ToggleChildAdmittedBy, toggleBuild, toggleToElement, toggleWithClass, toggleWithFor, toggleWithId, toggleWithSlot, toggleWithStyle, DialBuilder, DialAttrCaps, DialSlotCaps, DialIs, DialChildAdmittedBy, dialBuild, dialToElement, dialWithClass, dialWithFormat, dialWithHour, dialWithId, dialWithMaxTime, dialWithMinTime, dialWithMinute, dialWithOnChange, dialWithOnInput, dialWithOnViewChange, dialWithPeriod, dialWithSecond, dialWithShowSeconds, dialWithSlot, dialWithStyle, dialWithViewAttr, InputBuilder, InputAttrCaps, InputSlotCaps, InputIs, InputChildAdmittedBy, inputBuild, inputToElement, inputWithClass, inputWithFor, inputWithFormat, inputWithHideLabels, inputWithHour, inputWithHourLabel, inputWithId, inputWithMaxTime, inputWithMinTime, inputWithMinute, inputWithMinuteLabel, inputWithOnChange, inputWithOnViewChange, inputWithOrientation, inputWithPeriod, inputWithPeriodToggleLabel, inputWithSecond, inputWithSecondLabel, inputWithShowSeconds, inputWithSlot, inputWithStyle, inputWithViewAttr, InputPeriodToggleBuilder, InputPeriodToggleAttrCaps, InputPeriodToggleSlotCaps, InputPeriodToggleIs, InputPeriodToggleChildAdmittedBy, inputPeriodToggleBuild, inputPeriodToggleToElement, inputPeriodToggleWithClass, inputPeriodToggleWithId, inputPeriodToggleWithOnChange, inputPeriodToggleWithOrientation, inputPeriodToggleWithPeriod, inputPeriodToggleWithSlot, inputPeriodToggleWithStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Component.Timepicker as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias TimepickerIs s =
    Component.TimepickerIs s


{-| -}
type alias TimepickerBuilder attrCaps slotCaps msg kind =
    Component.TimepickerBuilder attrCaps slotCaps msg kind


{-| -}
type alias TimepickerAttrCaps =
    Component.TimepickerAttrCaps


{-| -}
type alias TimepickerSlotCaps =
    Component.TimepickerSlotCaps


{-| -}
type alias TimepickerChildAdmittedBy childAdm =
    Component.TimepickerChildAdmittedBy childAdm


{-| -}
timepickerBuild : TimepickerBuilder TimepickerAttrCaps TimepickerSlotCaps msg kind
timepickerBuild =
    B.init "m3e-timepicker" [] []


{-| -}
timepickerToElement : TimepickerBuilder attrCaps slotCaps msg kind -> Element (Component.TimepickerIs kind) admittedBy msg
timepickerToElement =
    B.toElement


{-| -}
timepickerWithClass : String -> TimepickerBuilder { a | class : Available } slotCaps msg kind -> TimepickerBuilder { a | class : Used } slotCaps msg kind
timepickerWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
timepickerWithId : String -> TimepickerBuilder { a | id : Available } slotCaps msg kind -> TimepickerBuilder { a | id : Used } slotCaps msg kind
timepickerWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
timepickerWithSlot : String -> TimepickerBuilder { a | slot : Available } slotCaps msg kind -> TimepickerBuilder { a | slot : Used } slotCaps msg kind
timepickerWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
timepickerWithStyle : String -> String -> TimepickerBuilder { a | style : Available } slotCaps msg kind -> TimepickerBuilder { a | style : Used } slotCaps msg kind
timepickerWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
timepickerWithConfirmLabel : String -> TimepickerBuilder { a | confirmLabel : Available } slotCaps msg kind -> TimepickerBuilder { a | confirmLabel : Used } slotCaps msg kind
timepickerWithConfirmLabel value_ =
    B.withAttribute (A.confirmLabel value_)


{-| -}
timepickerWithDate : String -> TimepickerBuilder { a | date : Available } slotCaps msg kind -> TimepickerBuilder { a | date : Used } slotCaps msg kind
timepickerWithDate value_ =
    B.withAttribute (A.date value_)


{-| -}
timepickerWithDialLabel : String -> TimepickerBuilder { a | dialLabel : Available } slotCaps msg kind -> TimepickerBuilder { a | dialLabel : Used } slotCaps msg kind
timepickerWithDialLabel value_ =
    B.withAttribute (A.dialLabel value_)


{-| -}
timepickerWithDismissLabel : String -> TimepickerBuilder { a | dismissLabel : Available } slotCaps msg kind -> TimepickerBuilder { a | dismissLabel : Used } slotCaps msg kind
timepickerWithDismissLabel value_ =
    B.withAttribute (A.dismissLabel value_)


{-| -}
timepickerWithFor : String -> TimepickerBuilder { a | for : Available } slotCaps msg kind -> TimepickerBuilder { a | for : Used } slotCaps msg kind
timepickerWithFor value_ =
    B.withAttribute (A.for value_)


{-| -}
timepickerWithFormat : Value Component.TimepickerFormat -> TimepickerBuilder { a | format : Available } slotCaps msg kind -> TimepickerBuilder { a | format : Used } slotCaps msg kind
timepickerWithFormat value_ =
    B.withAttribute (Component.timepickerFormat value_)


{-| -}
timepickerWithHideModeToggle : Bool -> TimepickerBuilder { a | hideModeToggle : Available } slotCaps msg kind -> TimepickerBuilder { a | hideModeToggle : Used } slotCaps msg kind
timepickerWithHideModeToggle value_ =
    B.withAttribute (A.hideModeToggle value_)


{-| -}
timepickerWithHourLabel : String -> TimepickerBuilder { a | hourLabel : Available } slotCaps msg kind -> TimepickerBuilder { a | hourLabel : Used } slotCaps msg kind
timepickerWithHourLabel value_ =
    B.withAttribute (A.hourLabel value_)


{-| -}
timepickerWithInputLabel : String -> TimepickerBuilder { a | inputLabel : Available } slotCaps msg kind -> TimepickerBuilder { a | inputLabel : Used } slotCaps msg kind
timepickerWithInputLabel value_ =
    B.withAttribute (A.inputLabel value_)


{-| -}
timepickerWithMaxTime : String -> TimepickerBuilder { a | maxTime : Available } slotCaps msg kind -> TimepickerBuilder { a | maxTime : Used } slotCaps msg kind
timepickerWithMaxTime value_ =
    B.withAttribute (A.maxTime value_)


{-| -}
timepickerWithMinTime : String -> TimepickerBuilder { a | minTime : Available } slotCaps msg kind -> TimepickerBuilder { a | minTime : Used } slotCaps msg kind
timepickerWithMinTime value_ =
    B.withAttribute (A.minTime value_)


{-| -}
timepickerWithMinuteLabel : String -> TimepickerBuilder { a | minuteLabel : Available } slotCaps msg kind -> TimepickerBuilder { a | minuteLabel : Used } slotCaps msg kind
timepickerWithMinuteLabel value_ =
    B.withAttribute (A.minuteLabel value_)


{-| -}
timepickerWithMode : Value Component.TimepickerMode -> TimepickerBuilder { a | mode : Available } slotCaps msg kind -> TimepickerBuilder { a | mode : Used } slotCaps msg kind
timepickerWithMode value_ =
    B.withAttribute (Component.timepickerMode value_)


{-| -}
timepickerWithModeToggleLabel : String -> TimepickerBuilder { a | modeToggleLabel : Available } slotCaps msg kind -> TimepickerBuilder { a | modeToggleLabel : Used } slotCaps msg kind
timepickerWithModeToggleLabel value_ =
    B.withAttribute (A.modeToggleLabel value_)


{-| -}
timepickerWithOrientation : Value Component.TimepickerOrientation -> TimepickerBuilder { a | orientation : Available } slotCaps msg kind -> TimepickerBuilder { a | orientation : Used } slotCaps msg kind
timepickerWithOrientation value_ =
    B.withAttribute (Component.timepickerOrientation value_)


{-| -}
timepickerWithPeriodToggleLabel : String -> TimepickerBuilder { a | periodToggleLabel : Available } slotCaps msg kind -> TimepickerBuilder { a | periodToggleLabel : Used } slotCaps msg kind
timepickerWithPeriodToggleLabel value_ =
    B.withAttribute (A.periodToggleLabel value_)


{-| -}
timepickerWithSecondLabel : String -> TimepickerBuilder { a | secondLabel : Available } slotCaps msg kind -> TimepickerBuilder { a | secondLabel : Used } slotCaps msg kind
timepickerWithSecondLabel value_ =
    B.withAttribute (A.secondLabel value_)


{-| -}
timepickerWithShowSeconds : Bool -> TimepickerBuilder { a | showSeconds : Available } slotCaps msg kind -> TimepickerBuilder { a | showSeconds : Used } slotCaps msg kind
timepickerWithShowSeconds value_ =
    B.withAttribute (A.showSeconds value_)


{-| -}
timepickerWithVariant : Value Component.TimepickerVariant -> TimepickerBuilder { a | variant : Available } slotCaps msg kind -> TimepickerBuilder { a | variant : Used } slotCaps msg kind
timepickerWithVariant value_ =
    B.withAttribute (Component.timepickerVariant value_)


{-| -}
timepickerWithOnChange : msg -> TimepickerBuilder { a | onChange : Available } slotCaps msg kind -> TimepickerBuilder { a | onChange : Used } slotCaps msg kind
timepickerWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
timepickerWithOnBeforetoggle : msg -> TimepickerBuilder { a | onBeforetoggle : Available } slotCaps msg kind -> TimepickerBuilder { a | onBeforetoggle : Used } slotCaps msg kind
timepickerWithOnBeforetoggle value_ =
    B.withAttribute (Ev.onBeforetoggle value_)


{-| -}
timepickerWithOnToggle : msg -> TimepickerBuilder { a | onToggle : Available } slotCaps msg kind -> TimepickerBuilder { a | onToggle : Used } slotCaps msg kind
timepickerWithOnToggle value_ =
    B.withAttribute (Ev.onToggle value_)


{-| -}
type alias ToggleIs s =
    Component.ToggleIs s


{-| -}
type alias ToggleBuilder attrCaps slotCaps msg kind =
    Component.ToggleBuilder attrCaps slotCaps msg kind


{-| -}
type alias ToggleAttrCaps =
    Component.ToggleAttrCaps


{-| -}
type alias ToggleSlotCaps =
    Component.ToggleSlotCaps


{-| -}
type alias ToggleChildAdmittedBy childAdm =
    Component.ToggleChildAdmittedBy childAdm


{-| -}
toggleBuild : ToggleBuilder ToggleAttrCaps ToggleSlotCaps msg kind
toggleBuild =
    B.init "m3e-timepicker-toggle" [] []


{-| -}
toggleToElement : ToggleBuilder attrCaps slotCaps msg kind -> Element (Component.ToggleIs kind) admittedBy msg
toggleToElement =
    B.toElement


{-| -}
toggleWithClass : String -> ToggleBuilder { a | class : Available } slotCaps msg kind -> ToggleBuilder { a | class : Used } slotCaps msg kind
toggleWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
toggleWithId : String -> ToggleBuilder { a | id : Available } slotCaps msg kind -> ToggleBuilder { a | id : Used } slotCaps msg kind
toggleWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
toggleWithSlot : String -> ToggleBuilder { a | slot : Available } slotCaps msg kind -> ToggleBuilder { a | slot : Used } slotCaps msg kind
toggleWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
toggleWithStyle : String -> String -> ToggleBuilder { a | style : Available } slotCaps msg kind -> ToggleBuilder { a | style : Used } slotCaps msg kind
toggleWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
toggleWithFor : String -> ToggleBuilder { a | for : Available } slotCaps msg kind -> ToggleBuilder { a | for : Used } slotCaps msg kind
toggleWithFor value_ =
    B.withAttribute (A.for value_)


{-| -}
type alias DialIs s =
    Component.DialIs s


{-| -}
type alias DialBuilder attrCaps slotCaps msg kind =
    Component.DialBuilder attrCaps slotCaps msg kind


{-| -}
type alias DialAttrCaps =
    Component.DialAttrCaps


{-| -}
type alias DialSlotCaps =
    Component.DialSlotCaps


{-| -}
type alias DialChildAdmittedBy childAdm =
    Component.DialChildAdmittedBy childAdm


{-| -}
dialBuild : DialBuilder DialAttrCaps DialSlotCaps msg kind
dialBuild =
    B.init "m3e-timepicker-dial" [] []


{-| -}
dialToElement : DialBuilder attrCaps slotCaps msg kind -> Element (Component.DialIs kind) admittedBy msg
dialToElement =
    B.toElement


{-| -}
dialWithClass : String -> DialBuilder { a | class : Available } slotCaps msg kind -> DialBuilder { a | class : Used } slotCaps msg kind
dialWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
dialWithId : String -> DialBuilder { a | id : Available } slotCaps msg kind -> DialBuilder { a | id : Used } slotCaps msg kind
dialWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
dialWithSlot : String -> DialBuilder { a | slot : Available } slotCaps msg kind -> DialBuilder { a | slot : Used } slotCaps msg kind
dialWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
dialWithStyle : String -> String -> DialBuilder { a | style : Available } slotCaps msg kind -> DialBuilder { a | style : Used } slotCaps msg kind
dialWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
dialWithFormat : Value Component.DialFormat -> DialBuilder { a | format : Available } slotCaps msg kind -> DialBuilder { a | format : Used } slotCaps msg kind
dialWithFormat value_ =
    B.withAttribute (Component.dialFormat value_)


{-| -}
dialWithHour : Float -> DialBuilder { a | hour : Available } slotCaps msg kind -> DialBuilder { a | hour : Used } slotCaps msg kind
dialWithHour value_ =
    B.withAttribute (A.hour value_)


{-| -}
dialWithMaxTime : String -> DialBuilder { a | maxTime : Available } slotCaps msg kind -> DialBuilder { a | maxTime : Used } slotCaps msg kind
dialWithMaxTime value_ =
    B.withAttribute (A.maxTime value_)


{-| -}
dialWithMinTime : String -> DialBuilder { a | minTime : Available } slotCaps msg kind -> DialBuilder { a | minTime : Used } slotCaps msg kind
dialWithMinTime value_ =
    B.withAttribute (A.minTime value_)


{-| -}
dialWithMinute : Float -> DialBuilder { a | minute : Available } slotCaps msg kind -> DialBuilder { a | minute : Used } slotCaps msg kind
dialWithMinute value_ =
    B.withAttribute (A.minute value_)


{-| -}
dialWithPeriod : Value Component.DialPeriod -> DialBuilder { a | period : Available } slotCaps msg kind -> DialBuilder { a | period : Used } slotCaps msg kind
dialWithPeriod value_ =
    B.withAttribute (Component.dialPeriod value_)


{-| -}
dialWithSecond : Float -> DialBuilder { a | second : Available } slotCaps msg kind -> DialBuilder { a | second : Used } slotCaps msg kind
dialWithSecond value_ =
    B.withAttribute (A.second value_)


{-| -}
dialWithShowSeconds : Bool -> DialBuilder { a | showSeconds : Available } slotCaps msg kind -> DialBuilder { a | showSeconds : Used } slotCaps msg kind
dialWithShowSeconds value_ =
    B.withAttribute (A.showSeconds value_)


{-| -}
dialWithViewAttr : Value Component.DialViewAttr -> DialBuilder { a | viewAttr : Available } slotCaps msg kind -> DialBuilder { a | viewAttr : Used } slotCaps msg kind
dialWithViewAttr value_ =
    B.withAttribute (Component.dialViewAttr value_)


{-| -}
dialWithOnInput : msg -> DialBuilder { a | onInput : Available } slotCaps msg kind -> DialBuilder { a | onInput : Used } slotCaps msg kind
dialWithOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
dialWithOnChange : msg -> DialBuilder { a | onChange : Available } slotCaps msg kind -> DialBuilder { a | onChange : Used } slotCaps msg kind
dialWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
dialWithOnViewChange : msg -> DialBuilder { a | onViewChange : Available } slotCaps msg kind -> DialBuilder { a | onViewChange : Used } slotCaps msg kind
dialWithOnViewChange value_ =
    B.withAttribute (Ev.onViewChange value_)


{-| -}
type alias InputIs s =
    Component.InputIs s


{-| -}
type alias InputBuilder attrCaps slotCaps msg kind =
    Component.InputBuilder attrCaps slotCaps msg kind


{-| -}
type alias InputAttrCaps =
    Component.InputAttrCaps


{-| -}
type alias InputSlotCaps =
    Component.InputSlotCaps


{-| -}
type alias InputChildAdmittedBy childAdm =
    Component.InputChildAdmittedBy childAdm


{-| -}
inputBuild : InputBuilder InputAttrCaps InputSlotCaps msg kind
inputBuild =
    B.init "m3e-timepicker-input" [] []


{-| -}
inputToElement : InputBuilder attrCaps slotCaps msg kind -> Element (Component.InputIs kind) admittedBy msg
inputToElement =
    B.toElement


{-| -}
inputWithClass : String -> InputBuilder { a | class : Available } slotCaps msg kind -> InputBuilder { a | class : Used } slotCaps msg kind
inputWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
inputWithId : String -> InputBuilder { a | id : Available } slotCaps msg kind -> InputBuilder { a | id : Used } slotCaps msg kind
inputWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
inputWithSlot : String -> InputBuilder { a | slot : Available } slotCaps msg kind -> InputBuilder { a | slot : Used } slotCaps msg kind
inputWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
inputWithStyle : String -> String -> InputBuilder { a | style : Available } slotCaps msg kind -> InputBuilder { a | style : Used } slotCaps msg kind
inputWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
inputWithFor : String -> InputBuilder { a | for : Available } slotCaps msg kind -> InputBuilder { a | for : Used } slotCaps msg kind
inputWithFor value_ =
    B.withAttribute (A.for value_)


{-| -}
inputWithFormat : Value Component.InputFormat -> InputBuilder { a | format : Available } slotCaps msg kind -> InputBuilder { a | format : Used } slotCaps msg kind
inputWithFormat value_ =
    B.withAttribute (Component.inputFormat value_)


{-| -}
inputWithHideLabels : Bool -> InputBuilder { a | hideLabels : Available } slotCaps msg kind -> InputBuilder { a | hideLabels : Used } slotCaps msg kind
inputWithHideLabels value_ =
    B.withAttribute (A.hideLabels value_)


{-| -}
inputWithHour : Float -> InputBuilder { a | hour : Available } slotCaps msg kind -> InputBuilder { a | hour : Used } slotCaps msg kind
inputWithHour value_ =
    B.withAttribute (A.hour value_)


{-| -}
inputWithHourLabel : String -> InputBuilder { a | hourLabel : Available } slotCaps msg kind -> InputBuilder { a | hourLabel : Used } slotCaps msg kind
inputWithHourLabel value_ =
    B.withAttribute (A.hourLabel value_)


{-| -}
inputWithMaxTime : String -> InputBuilder { a | maxTime : Available } slotCaps msg kind -> InputBuilder { a | maxTime : Used } slotCaps msg kind
inputWithMaxTime value_ =
    B.withAttribute (A.maxTime value_)


{-| -}
inputWithMinTime : String -> InputBuilder { a | minTime : Available } slotCaps msg kind -> InputBuilder { a | minTime : Used } slotCaps msg kind
inputWithMinTime value_ =
    B.withAttribute (A.minTime value_)


{-| -}
inputWithMinute : Float -> InputBuilder { a | minute : Available } slotCaps msg kind -> InputBuilder { a | minute : Used } slotCaps msg kind
inputWithMinute value_ =
    B.withAttribute (A.minute value_)


{-| -}
inputWithMinuteLabel : String -> InputBuilder { a | minuteLabel : Available } slotCaps msg kind -> InputBuilder { a | minuteLabel : Used } slotCaps msg kind
inputWithMinuteLabel value_ =
    B.withAttribute (A.minuteLabel value_)


{-| -}
inputWithOrientation : String -> InputBuilder { a | orientation : Available } slotCaps msg kind -> InputBuilder { a | orientation : Used } slotCaps msg kind
inputWithOrientation value_ =
    B.withAttribute (Ir.attribute "orientation" value_)


{-| -}
inputWithPeriod : Value Component.InputPeriod -> InputBuilder { a | period : Available } slotCaps msg kind -> InputBuilder { a | period : Used } slotCaps msg kind
inputWithPeriod value_ =
    B.withAttribute (Component.inputPeriod value_)


{-| -}
inputWithPeriodToggleLabel : String -> InputBuilder { a | periodToggleLabel : Available } slotCaps msg kind -> InputBuilder { a | periodToggleLabel : Used } slotCaps msg kind
inputWithPeriodToggleLabel value_ =
    B.withAttribute (A.periodToggleLabel value_)


{-| -}
inputWithSecond : Float -> InputBuilder { a | second : Available } slotCaps msg kind -> InputBuilder { a | second : Used } slotCaps msg kind
inputWithSecond value_ =
    B.withAttribute (A.second value_)


{-| -}
inputWithSecondLabel : String -> InputBuilder { a | secondLabel : Available } slotCaps msg kind -> InputBuilder { a | secondLabel : Used } slotCaps msg kind
inputWithSecondLabel value_ =
    B.withAttribute (A.secondLabel value_)


{-| -}
inputWithShowSeconds : Bool -> InputBuilder { a | showSeconds : Available } slotCaps msg kind -> InputBuilder { a | showSeconds : Used } slotCaps msg kind
inputWithShowSeconds value_ =
    B.withAttribute (A.showSeconds value_)


{-| -}
inputWithViewAttr : Value Component.InputViewAttr -> InputBuilder { a | viewAttr : Available } slotCaps msg kind -> InputBuilder { a | viewAttr : Used } slotCaps msg kind
inputWithViewAttr value_ =
    B.withAttribute (Component.inputViewAttr value_)


{-| -}
inputWithOnViewChange : msg -> InputBuilder { a | onViewChange : Available } slotCaps msg kind -> InputBuilder { a | onViewChange : Used } slotCaps msg kind
inputWithOnViewChange value_ =
    B.withAttribute (Ev.onViewChange value_)


{-| -}
inputWithOnChange : msg -> InputBuilder { a | onChange : Available } slotCaps msg kind -> InputBuilder { a | onChange : Used } slotCaps msg kind
inputWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
type alias InputPeriodToggleIs s =
    Component.InputPeriodToggleIs s


{-| -}
type alias InputPeriodToggleBuilder attrCaps slotCaps msg kind =
    Component.InputPeriodToggleBuilder attrCaps slotCaps msg kind


{-| -}
type alias InputPeriodToggleAttrCaps =
    Component.InputPeriodToggleAttrCaps


{-| -}
type alias InputPeriodToggleSlotCaps =
    Component.InputPeriodToggleSlotCaps


{-| -}
type alias InputPeriodToggleChildAdmittedBy childAdm =
    Component.InputPeriodToggleChildAdmittedBy childAdm


{-| -}
inputPeriodToggleBuild : InputPeriodToggleBuilder InputPeriodToggleAttrCaps InputPeriodToggleSlotCaps msg kind
inputPeriodToggleBuild =
    B.init "m3e-timepicker-input-period-toggle" [] []


{-| -}
inputPeriodToggleToElement : InputPeriodToggleBuilder attrCaps slotCaps msg kind -> Element (Component.InputPeriodToggleIs kind) admittedBy msg
inputPeriodToggleToElement =
    B.toElement


{-| -}
inputPeriodToggleWithClass : String -> InputPeriodToggleBuilder { a | class : Available } slotCaps msg kind -> InputPeriodToggleBuilder { a | class : Used } slotCaps msg kind
inputPeriodToggleWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
inputPeriodToggleWithId : String -> InputPeriodToggleBuilder { a | id : Available } slotCaps msg kind -> InputPeriodToggleBuilder { a | id : Used } slotCaps msg kind
inputPeriodToggleWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
inputPeriodToggleWithSlot : String -> InputPeriodToggleBuilder { a | slot : Available } slotCaps msg kind -> InputPeriodToggleBuilder { a | slot : Used } slotCaps msg kind
inputPeriodToggleWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
inputPeriodToggleWithStyle : String -> String -> InputPeriodToggleBuilder { a | style : Available } slotCaps msg kind -> InputPeriodToggleBuilder { a | style : Used } slotCaps msg kind
inputPeriodToggleWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
inputPeriodToggleWithOrientation : String -> InputPeriodToggleBuilder { a | orientation : Available } slotCaps msg kind -> InputPeriodToggleBuilder { a | orientation : Used } slotCaps msg kind
inputPeriodToggleWithOrientation value_ =
    B.withAttribute (Ir.attribute "orientation" value_)


{-| -}
inputPeriodToggleWithPeriod : Value Component.InputPeriodTogglePeriod -> InputPeriodToggleBuilder { a | period : Available } slotCaps msg kind -> InputPeriodToggleBuilder { a | period : Used } slotCaps msg kind
inputPeriodToggleWithPeriod value_ =
    B.withAttribute (Component.inputPeriodTogglePeriod value_)


{-| -}
inputPeriodToggleWithOnChange : msg -> InputPeriodToggleBuilder { a | onChange : Available } slotCaps msg kind -> InputPeriodToggleBuilder { a | onChange : Used } slotCaps msg kind
inputPeriodToggleWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)
