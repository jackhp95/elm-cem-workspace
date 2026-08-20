module M3e.Family.Timepicker exposing (TimepickerIs, TimepickerAttrs, TimepickerBuilder, TimepickerAttrCaps, TimepickerSlotCaps, TimepickerChildAdmittedBy, TimepickerFormat, TimepickerMode, TimepickerOrientation, TimepickerVariant, ToggleIs, ToggleAttrs, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleChildAdmittedBy, DialIs, DialAttrs, DialBuilder, DialAttrCaps, DialSlotCaps, DialChildAdmittedBy, DialFormat, DialPeriod, DialViewAttr, InputIs, InputAttrs, InputBuilder, InputAttrCaps, InputSlotCaps, InputChildAdmittedBy, InputFormat, InputPeriod, InputViewAttr, InputPeriodToggleIs, InputPeriodToggleAttrs, InputPeriodToggleBuilder, InputPeriodToggleAttrCaps, InputPeriodToggleSlotCaps, InputPeriodToggleChildAdmittedBy, InputPeriodTogglePeriod, timepicker, timepickerFormat, timepickerMode, timepickerOrientation, timepickerVariant, timepickerConfirmLabel, timepickerDate, timepickerDialLabel, timepickerDismissLabel, timepickerFor, timepickerHideModeToggle, timepickerHourLabel, timepickerInputLabel, timepickerMaxTime, timepickerMinTime, timepickerMinuteLabel, timepickerModeToggleLabel, timepickerPeriodToggleLabel, timepickerSecondLabel, timepickerShowSeconds, timepickerOnChange, timepickerOnBeforetoggle, timepickerOnToggle, toggle, toggleFor, dial, dialFormat, dialPeriod, dialViewAttr, dialHour, dialMaxTime, dialMinTime, dialMinute, dialSecond, dialShowSeconds, dialOnInput, dialOnChange, dialOnViewChange, input, inputFormat, inputPeriod, inputViewAttr, inputFor, inputHideLabels, inputHour, inputHourLabel, inputMaxTime, inputMinTime, inputMinute, inputMinuteLabel, inputOrientation, inputPeriodToggleLabel, inputSecond, inputSecondLabel, inputShowSeconds, inputOnViewChange, inputOnChange, inputPeriodToggle, inputPeriodTogglePeriod, inputPeriodToggleOrientation, inputPeriodToggleOnChange)

{-| The **Timepicker** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.Timepicker`](M3e.Component.Timepicker) as `timepicker`, [`M3e.Component.TimepickerToggle`](M3e.Component.TimepickerToggle) as `toggle`, [`M3e.Component.TimepickerDial`](M3e.Component.TimepickerDial) as `dial`, [`M3e.Component.TimepickerInput`](M3e.Component.TimepickerInput) as `input`, [`M3e.Component.TimepickerInputPeriodToggle`](M3e.Component.TimepickerInputPeriodToggle) as `inputPeriodToggle`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs TimepickerIs, TimepickerAttrs, TimepickerBuilder, TimepickerAttrCaps, TimepickerSlotCaps, TimepickerChildAdmittedBy, TimepickerFormat, TimepickerMode, TimepickerOrientation, TimepickerVariant, ToggleIs, ToggleAttrs, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleChildAdmittedBy, DialIs, DialAttrs, DialBuilder, DialAttrCaps, DialSlotCaps, DialChildAdmittedBy, DialFormat, DialPeriod, DialViewAttr, InputIs, InputAttrs, InputBuilder, InputAttrCaps, InputSlotCaps, InputChildAdmittedBy, InputFormat, InputPeriod, InputViewAttr, InputPeriodToggleIs, InputPeriodToggleAttrs, InputPeriodToggleBuilder, InputPeriodToggleAttrCaps, InputPeriodToggleSlotCaps, InputPeriodToggleChildAdmittedBy, InputPeriodTogglePeriod, timepicker, timepickerFormat, timepickerMode, timepickerOrientation, timepickerVariant, timepickerConfirmLabel, timepickerDate, timepickerDialLabel, timepickerDismissLabel, timepickerFor, timepickerHideModeToggle, timepickerHourLabel, timepickerInputLabel, timepickerMaxTime, timepickerMinTime, timepickerMinuteLabel, timepickerModeToggleLabel, timepickerPeriodToggleLabel, timepickerSecondLabel, timepickerShowSeconds, timepickerOnChange, timepickerOnBeforetoggle, timepickerOnToggle, toggle, toggleFor, dial, dialFormat, dialPeriod, dialViewAttr, dialHour, dialMaxTime, dialMinTime, dialMinute, dialSecond, dialShowSeconds, dialOnInput, dialOnChange, dialOnViewChange, input, inputFormat, inputPeriod, inputViewAttr, inputFor, inputHideLabels, inputHour, inputHourLabel, inputMaxTime, inputMinTime, inputMinute, inputMinuteLabel, inputOrientation, inputPeriodToggleLabel, inputSecond, inputSecondLabel, inputShowSeconds, inputOnViewChange, inputOnChange, inputPeriodToggle, inputPeriodTogglePeriod, inputPeriodToggleOrientation, inputPeriodToggleOnChange

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Component.Timepicker as Timepicker_
import M3e.Component.TimepickerDial as Dial_
import M3e.Component.TimepickerInput as Input_
import M3e.Component.TimepickerInputPeriodToggle as InputPeriodToggle_
import M3e.Component.TimepickerToggle as Toggle_


{-| The `timepicker` element of this family — delegates to [`M3e.Component.Timepicker.component`](M3e.Component.Timepicker#component).
-}
timepicker :
    List (Attr TimepickerAttrs msg)
    -> List (Element childAccepts (TimepickerChildAdmittedBy childAdm) msg)
    -> Element (TimepickerIs s) admittedBy msg
timepicker =
    Timepicker_.component


{-| See [`M3e.Component.Timepicker.Is`](M3e.Component.Timepicker#Is).
-}
type alias TimepickerIs s =
    Timepicker_.Is s


{-| See [`M3e.Component.Timepicker.Attrs`](M3e.Component.Timepicker#Attrs).
-}
type alias TimepickerAttrs =
    Timepicker_.Attrs


{-| See [`M3e.Component.Timepicker.Builder`](M3e.Component.Timepicker#Builder).
-}
type alias TimepickerBuilder attrCaps slotCaps msg kind =
    Timepicker_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.Timepicker.AttrCaps`](M3e.Component.Timepicker#AttrCaps).
-}
type alias TimepickerAttrCaps =
    Timepicker_.AttrCaps


{-| See [`M3e.Component.Timepicker.SlotCaps`](M3e.Component.Timepicker#SlotCaps).
-}
type alias TimepickerSlotCaps =
    Timepicker_.SlotCaps


{-| See [`M3e.Component.Timepicker.ChildAdmittedBy`](M3e.Component.Timepicker#ChildAdmittedBy).
-}
type alias TimepickerChildAdmittedBy childAdm =
    Timepicker_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.Timepicker.Format`](M3e.Component.Timepicker#Format).
-}
type alias TimepickerFormat =
    Timepicker_.Format


{-| See [`M3e.Component.Timepicker.format`](M3e.Component.Timepicker#format).
-}
timepickerFormat : Value TimepickerFormat -> Attr { c | format : Supported } msg
timepickerFormat =
    Timepicker_.format


{-| See [`M3e.Component.Timepicker.Mode`](M3e.Component.Timepicker#Mode).
-}
type alias TimepickerMode =
    Timepicker_.Mode


{-| See [`M3e.Component.Timepicker.mode`](M3e.Component.Timepicker#mode).
-}
timepickerMode : Value TimepickerMode -> Attr { c | mode : Supported } msg
timepickerMode =
    Timepicker_.mode


{-| See [`M3e.Component.Timepicker.Orientation`](M3e.Component.Timepicker#Orientation).
-}
type alias TimepickerOrientation =
    Timepicker_.Orientation


{-| See [`M3e.Component.Timepicker.orientation`](M3e.Component.Timepicker#orientation).
-}
timepickerOrientation : Value TimepickerOrientation -> Attr { c | orientation : Supported } msg
timepickerOrientation =
    Timepicker_.orientation


{-| See [`M3e.Component.Timepicker.Variant`](M3e.Component.Timepicker#Variant).
-}
type alias TimepickerVariant =
    Timepicker_.Variant


{-| See [`M3e.Component.Timepicker.variant`](M3e.Component.Timepicker#variant).
-}
timepickerVariant : Value TimepickerVariant -> Attr { c | variant : Supported } msg
timepickerVariant =
    Timepicker_.variant


{-| See [`M3e.Component.Timepicker.confirmLabel`](M3e.Component.Timepicker#confirmLabel).
-}
timepickerConfirmLabel : String -> Attr { c | confirmLabel : Supported } msg
timepickerConfirmLabel =
    Timepicker_.confirmLabel


{-| See [`M3e.Component.Timepicker.date`](M3e.Component.Timepicker#date).
-}
timepickerDate : String -> Attr { c | date : Supported } msg
timepickerDate =
    Timepicker_.date


{-| See [`M3e.Component.Timepicker.dialLabel`](M3e.Component.Timepicker#dialLabel).
-}
timepickerDialLabel : String -> Attr { c | dialLabel : Supported } msg
timepickerDialLabel =
    Timepicker_.dialLabel


{-| See [`M3e.Component.Timepicker.dismissLabel`](M3e.Component.Timepicker#dismissLabel).
-}
timepickerDismissLabel : String -> Attr { c | dismissLabel : Supported } msg
timepickerDismissLabel =
    Timepicker_.dismissLabel


{-| See [`M3e.Component.Timepicker.for`](M3e.Component.Timepicker#for).
-}
timepickerFor : String -> Attr { c | for : Supported } msg
timepickerFor =
    Timepicker_.for


{-| See [`M3e.Component.Timepicker.hideModeToggle`](M3e.Component.Timepicker#hideModeToggle).
-}
timepickerHideModeToggle : Bool -> Attr { c | hideModeToggle : Supported } msg
timepickerHideModeToggle =
    Timepicker_.hideModeToggle


{-| See [`M3e.Component.Timepicker.hourLabel`](M3e.Component.Timepicker#hourLabel).
-}
timepickerHourLabel : String -> Attr { c | hourLabel : Supported } msg
timepickerHourLabel =
    Timepicker_.hourLabel


{-| See [`M3e.Component.Timepicker.inputLabel`](M3e.Component.Timepicker#inputLabel).
-}
timepickerInputLabel : String -> Attr { c | inputLabel : Supported } msg
timepickerInputLabel =
    Timepicker_.inputLabel


{-| See [`M3e.Component.Timepicker.maxTime`](M3e.Component.Timepicker#maxTime).
-}
timepickerMaxTime : String -> Attr { c | maxTime : Supported } msg
timepickerMaxTime =
    Timepicker_.maxTime


{-| See [`M3e.Component.Timepicker.minTime`](M3e.Component.Timepicker#minTime).
-}
timepickerMinTime : String -> Attr { c | minTime : Supported } msg
timepickerMinTime =
    Timepicker_.minTime


{-| See [`M3e.Component.Timepicker.minuteLabel`](M3e.Component.Timepicker#minuteLabel).
-}
timepickerMinuteLabel : String -> Attr { c | minuteLabel : Supported } msg
timepickerMinuteLabel =
    Timepicker_.minuteLabel


{-| See [`M3e.Component.Timepicker.modeToggleLabel`](M3e.Component.Timepicker#modeToggleLabel).
-}
timepickerModeToggleLabel : String -> Attr { c | modeToggleLabel : Supported } msg
timepickerModeToggleLabel =
    Timepicker_.modeToggleLabel


{-| See [`M3e.Component.Timepicker.periodToggleLabel`](M3e.Component.Timepicker#periodToggleLabel).
-}
timepickerPeriodToggleLabel : String -> Attr { c | periodToggleLabel : Supported } msg
timepickerPeriodToggleLabel =
    Timepicker_.periodToggleLabel


{-| See [`M3e.Component.Timepicker.secondLabel`](M3e.Component.Timepicker#secondLabel).
-}
timepickerSecondLabel : String -> Attr { c | secondLabel : Supported } msg
timepickerSecondLabel =
    Timepicker_.secondLabel


{-| See [`M3e.Component.Timepicker.showSeconds`](M3e.Component.Timepicker#showSeconds).
-}
timepickerShowSeconds : Bool -> Attr { c | showSeconds : Supported } msg
timepickerShowSeconds =
    Timepicker_.showSeconds


{-| See [`M3e.Component.Timepicker.onChange`](M3e.Component.Timepicker#onChange).
-}
timepickerOnChange : msg -> Attr { c | onChange : Supported } msg
timepickerOnChange =
    Timepicker_.onChange


{-| See [`M3e.Component.Timepicker.onBeforetoggle`](M3e.Component.Timepicker#onBeforetoggle).
-}
timepickerOnBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
timepickerOnBeforetoggle =
    Timepicker_.onBeforetoggle


{-| See [`M3e.Component.Timepicker.onToggle`](M3e.Component.Timepicker#onToggle).
-}
timepickerOnToggle : msg -> Attr { c | onToggle : Supported } msg
timepickerOnToggle =
    Timepicker_.onToggle


{-| The `toggle` element of this family — delegates to [`M3e.Component.TimepickerToggle.component`](M3e.Component.TimepickerToggle#component).
-}
toggle :
    List (Attr ToggleAttrs msg)
    -> List (Element childAccepts (ToggleChildAdmittedBy childAdm) msg)
    -> Element (ToggleIs s) admittedBy msg
toggle =
    Toggle_.component


{-| See [`M3e.Component.TimepickerToggle.Is`](M3e.Component.TimepickerToggle#Is).
-}
type alias ToggleIs s =
    Toggle_.Is s


{-| See [`M3e.Component.TimepickerToggle.Attrs`](M3e.Component.TimepickerToggle#Attrs).
-}
type alias ToggleAttrs =
    Toggle_.Attrs


{-| See [`M3e.Component.TimepickerToggle.Builder`](M3e.Component.TimepickerToggle#Builder).
-}
type alias ToggleBuilder attrCaps slotCaps msg kind =
    Toggle_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.TimepickerToggle.AttrCaps`](M3e.Component.TimepickerToggle#AttrCaps).
-}
type alias ToggleAttrCaps =
    Toggle_.AttrCaps


{-| See [`M3e.Component.TimepickerToggle.SlotCaps`](M3e.Component.TimepickerToggle#SlotCaps).
-}
type alias ToggleSlotCaps =
    Toggle_.SlotCaps


{-| See [`M3e.Component.TimepickerToggle.ChildAdmittedBy`](M3e.Component.TimepickerToggle#ChildAdmittedBy).
-}
type alias ToggleChildAdmittedBy childAdm =
    Toggle_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.TimepickerToggle.for`](M3e.Component.TimepickerToggle#for).
-}
toggleFor : String -> Attr { c | for : Supported } msg
toggleFor =
    Toggle_.for


{-| The `dial` element of this family — delegates to [`M3e.Component.TimepickerDial.component`](M3e.Component.TimepickerDial#component).
-}
dial :
    List (Attr DialAttrs msg)
    -> List (Element childAccepts (DialChildAdmittedBy childAdm) msg)
    -> Element (DialIs s) admittedBy msg
dial =
    Dial_.component


{-| See [`M3e.Component.TimepickerDial.Is`](M3e.Component.TimepickerDial#Is).
-}
type alias DialIs s =
    Dial_.Is s


{-| See [`M3e.Component.TimepickerDial.Attrs`](M3e.Component.TimepickerDial#Attrs).
-}
type alias DialAttrs =
    Dial_.Attrs


{-| See [`M3e.Component.TimepickerDial.Builder`](M3e.Component.TimepickerDial#Builder).
-}
type alias DialBuilder attrCaps slotCaps msg kind =
    Dial_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.TimepickerDial.AttrCaps`](M3e.Component.TimepickerDial#AttrCaps).
-}
type alias DialAttrCaps =
    Dial_.AttrCaps


{-| See [`M3e.Component.TimepickerDial.SlotCaps`](M3e.Component.TimepickerDial#SlotCaps).
-}
type alias DialSlotCaps =
    Dial_.SlotCaps


{-| See [`M3e.Component.TimepickerDial.ChildAdmittedBy`](M3e.Component.TimepickerDial#ChildAdmittedBy).
-}
type alias DialChildAdmittedBy childAdm =
    Dial_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.TimepickerDial.Format`](M3e.Component.TimepickerDial#Format).
-}
type alias DialFormat =
    Dial_.Format


{-| See [`M3e.Component.TimepickerDial.format`](M3e.Component.TimepickerDial#format).
-}
dialFormat : Value DialFormat -> Attr { c | format : Supported } msg
dialFormat =
    Dial_.format


{-| See [`M3e.Component.TimepickerDial.Period`](M3e.Component.TimepickerDial#Period).
-}
type alias DialPeriod =
    Dial_.Period


{-| See [`M3e.Component.TimepickerDial.period`](M3e.Component.TimepickerDial#period).
-}
dialPeriod : Value DialPeriod -> Attr { c | period : Supported } msg
dialPeriod =
    Dial_.period


{-| See [`M3e.Component.TimepickerDial.ViewAttr`](M3e.Component.TimepickerDial#ViewAttr).
-}
type alias DialViewAttr =
    Dial_.ViewAttr


{-| See [`M3e.Component.TimepickerDial.viewAttr`](M3e.Component.TimepickerDial#viewAttr).
-}
dialViewAttr : Value DialViewAttr -> Attr { c | viewAttr : Supported } msg
dialViewAttr =
    Dial_.viewAttr


{-| See [`M3e.Component.TimepickerDial.hour`](M3e.Component.TimepickerDial#hour).
-}
dialHour : Float -> Attr { c | hour : Supported } msg
dialHour =
    Dial_.hour


{-| See [`M3e.Component.TimepickerDial.maxTime`](M3e.Component.TimepickerDial#maxTime).
-}
dialMaxTime : String -> Attr { c | maxTime : Supported } msg
dialMaxTime =
    Dial_.maxTime


{-| See [`M3e.Component.TimepickerDial.minTime`](M3e.Component.TimepickerDial#minTime).
-}
dialMinTime : String -> Attr { c | minTime : Supported } msg
dialMinTime =
    Dial_.minTime


{-| See [`M3e.Component.TimepickerDial.minute`](M3e.Component.TimepickerDial#minute).
-}
dialMinute : Float -> Attr { c | minute : Supported } msg
dialMinute =
    Dial_.minute


{-| See [`M3e.Component.TimepickerDial.second`](M3e.Component.TimepickerDial#second).
-}
dialSecond : Float -> Attr { c | second : Supported } msg
dialSecond =
    Dial_.second


{-| See [`M3e.Component.TimepickerDial.showSeconds`](M3e.Component.TimepickerDial#showSeconds).
-}
dialShowSeconds : Bool -> Attr { c | showSeconds : Supported } msg
dialShowSeconds =
    Dial_.showSeconds


{-| See [`M3e.Component.TimepickerDial.onInput`](M3e.Component.TimepickerDial#onInput).
-}
dialOnInput : msg -> Attr { c | onInput : Supported } msg
dialOnInput =
    Dial_.onInput


{-| See [`M3e.Component.TimepickerDial.onChange`](M3e.Component.TimepickerDial#onChange).
-}
dialOnChange : msg -> Attr { c | onChange : Supported } msg
dialOnChange =
    Dial_.onChange


{-| See [`M3e.Component.TimepickerDial.onViewChange`](M3e.Component.TimepickerDial#onViewChange).
-}
dialOnViewChange : msg -> Attr { c | onViewChange : Supported } msg
dialOnViewChange =
    Dial_.onViewChange


{-| The `input` element of this family — delegates to [`M3e.Component.TimepickerInput.component`](M3e.Component.TimepickerInput#component).
-}
input :
    List (Attr InputAttrs msg)
    -> List (Element childAccepts (InputChildAdmittedBy childAdm) msg)
    -> Element (InputIs s) admittedBy msg
input =
    Input_.component


{-| See [`M3e.Component.TimepickerInput.Is`](M3e.Component.TimepickerInput#Is).
-}
type alias InputIs s =
    Input_.Is s


{-| See [`M3e.Component.TimepickerInput.Attrs`](M3e.Component.TimepickerInput#Attrs).
-}
type alias InputAttrs =
    Input_.Attrs


{-| See [`M3e.Component.TimepickerInput.Builder`](M3e.Component.TimepickerInput#Builder).
-}
type alias InputBuilder attrCaps slotCaps msg kind =
    Input_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.TimepickerInput.AttrCaps`](M3e.Component.TimepickerInput#AttrCaps).
-}
type alias InputAttrCaps =
    Input_.AttrCaps


{-| See [`M3e.Component.TimepickerInput.SlotCaps`](M3e.Component.TimepickerInput#SlotCaps).
-}
type alias InputSlotCaps =
    Input_.SlotCaps


{-| See [`M3e.Component.TimepickerInput.ChildAdmittedBy`](M3e.Component.TimepickerInput#ChildAdmittedBy).
-}
type alias InputChildAdmittedBy childAdm =
    Input_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.TimepickerInput.Format`](M3e.Component.TimepickerInput#Format).
-}
type alias InputFormat =
    Input_.Format


{-| See [`M3e.Component.TimepickerInput.format`](M3e.Component.TimepickerInput#format).
-}
inputFormat : Value InputFormat -> Attr { c | format : Supported } msg
inputFormat =
    Input_.format


{-| See [`M3e.Component.TimepickerInput.Period`](M3e.Component.TimepickerInput#Period).
-}
type alias InputPeriod =
    Input_.Period


{-| See [`M3e.Component.TimepickerInput.period`](M3e.Component.TimepickerInput#period).
-}
inputPeriod : Value InputPeriod -> Attr { c | period : Supported } msg
inputPeriod =
    Input_.period


{-| See [`M3e.Component.TimepickerInput.ViewAttr`](M3e.Component.TimepickerInput#ViewAttr).
-}
type alias InputViewAttr =
    Input_.ViewAttr


{-| See [`M3e.Component.TimepickerInput.viewAttr`](M3e.Component.TimepickerInput#viewAttr).
-}
inputViewAttr : Value InputViewAttr -> Attr { c | viewAttr : Supported } msg
inputViewAttr =
    Input_.viewAttr


{-| See [`M3e.Component.TimepickerInput.for`](M3e.Component.TimepickerInput#for).
-}
inputFor : String -> Attr { c | for : Supported } msg
inputFor =
    Input_.for


{-| See [`M3e.Component.TimepickerInput.hideLabels`](M3e.Component.TimepickerInput#hideLabels).
-}
inputHideLabels : Bool -> Attr { c | hideLabels : Supported } msg
inputHideLabels =
    Input_.hideLabels


{-| See [`M3e.Component.TimepickerInput.hour`](M3e.Component.TimepickerInput#hour).
-}
inputHour : Float -> Attr { c | hour : Supported } msg
inputHour =
    Input_.hour


{-| See [`M3e.Component.TimepickerInput.hourLabel`](M3e.Component.TimepickerInput#hourLabel).
-}
inputHourLabel : String -> Attr { c | hourLabel : Supported } msg
inputHourLabel =
    Input_.hourLabel


{-| See [`M3e.Component.TimepickerInput.maxTime`](M3e.Component.TimepickerInput#maxTime).
-}
inputMaxTime : String -> Attr { c | maxTime : Supported } msg
inputMaxTime =
    Input_.maxTime


{-| See [`M3e.Component.TimepickerInput.minTime`](M3e.Component.TimepickerInput#minTime).
-}
inputMinTime : String -> Attr { c | minTime : Supported } msg
inputMinTime =
    Input_.minTime


{-| See [`M3e.Component.TimepickerInput.minute`](M3e.Component.TimepickerInput#minute).
-}
inputMinute : Float -> Attr { c | minute : Supported } msg
inputMinute =
    Input_.minute


{-| See [`M3e.Component.TimepickerInput.minuteLabel`](M3e.Component.TimepickerInput#minuteLabel).
-}
inputMinuteLabel : String -> Attr { c | minuteLabel : Supported } msg
inputMinuteLabel =
    Input_.minuteLabel


{-| See [`M3e.Component.TimepickerInput.orientation`](M3e.Component.TimepickerInput#orientation).
-}
inputOrientation : String -> Attr { c | orientation : Supported } msg
inputOrientation =
    Input_.orientation


{-| See [`M3e.Component.TimepickerInput.periodToggleLabel`](M3e.Component.TimepickerInput#periodToggleLabel).
-}
inputPeriodToggleLabel : String -> Attr { c | periodToggleLabel : Supported } msg
inputPeriodToggleLabel =
    Input_.periodToggleLabel


{-| See [`M3e.Component.TimepickerInput.second`](M3e.Component.TimepickerInput#second).
-}
inputSecond : Float -> Attr { c | second : Supported } msg
inputSecond =
    Input_.second


{-| See [`M3e.Component.TimepickerInput.secondLabel`](M3e.Component.TimepickerInput#secondLabel).
-}
inputSecondLabel : String -> Attr { c | secondLabel : Supported } msg
inputSecondLabel =
    Input_.secondLabel


{-| See [`M3e.Component.TimepickerInput.showSeconds`](M3e.Component.TimepickerInput#showSeconds).
-}
inputShowSeconds : Bool -> Attr { c | showSeconds : Supported } msg
inputShowSeconds =
    Input_.showSeconds


{-| See [`M3e.Component.TimepickerInput.onViewChange`](M3e.Component.TimepickerInput#onViewChange).
-}
inputOnViewChange : msg -> Attr { c | onViewChange : Supported } msg
inputOnViewChange =
    Input_.onViewChange


{-| See [`M3e.Component.TimepickerInput.onChange`](M3e.Component.TimepickerInput#onChange).
-}
inputOnChange : msg -> Attr { c | onChange : Supported } msg
inputOnChange =
    Input_.onChange


{-| The `inputPeriodToggle` element of this family — delegates to [`M3e.Component.TimepickerInputPeriodToggle.component`](M3e.Component.TimepickerInputPeriodToggle#component).
-}
inputPeriodToggle :
    List (Attr InputPeriodToggleAttrs msg)
    -> List (Element childAccepts (InputPeriodToggleChildAdmittedBy childAdm) msg)
    -> Element (InputPeriodToggleIs s) admittedBy msg
inputPeriodToggle =
    InputPeriodToggle_.component


{-| See [`M3e.Component.TimepickerInputPeriodToggle.Is`](M3e.Component.TimepickerInputPeriodToggle#Is).
-}
type alias InputPeriodToggleIs s =
    InputPeriodToggle_.Is s


{-| See [`M3e.Component.TimepickerInputPeriodToggle.Attrs`](M3e.Component.TimepickerInputPeriodToggle#Attrs).
-}
type alias InputPeriodToggleAttrs =
    InputPeriodToggle_.Attrs


{-| See [`M3e.Component.TimepickerInputPeriodToggle.Builder`](M3e.Component.TimepickerInputPeriodToggle#Builder).
-}
type alias InputPeriodToggleBuilder attrCaps slotCaps msg kind =
    InputPeriodToggle_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.TimepickerInputPeriodToggle.AttrCaps`](M3e.Component.TimepickerInputPeriodToggle#AttrCaps).
-}
type alias InputPeriodToggleAttrCaps =
    InputPeriodToggle_.AttrCaps


{-| See [`M3e.Component.TimepickerInputPeriodToggle.SlotCaps`](M3e.Component.TimepickerInputPeriodToggle#SlotCaps).
-}
type alias InputPeriodToggleSlotCaps =
    InputPeriodToggle_.SlotCaps


{-| See [`M3e.Component.TimepickerInputPeriodToggle.ChildAdmittedBy`](M3e.Component.TimepickerInputPeriodToggle#ChildAdmittedBy).
-}
type alias InputPeriodToggleChildAdmittedBy childAdm =
    InputPeriodToggle_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.TimepickerInputPeriodToggle.Period`](M3e.Component.TimepickerInputPeriodToggle#Period).
-}
type alias InputPeriodTogglePeriod =
    InputPeriodToggle_.Period


{-| See [`M3e.Component.TimepickerInputPeriodToggle.period`](M3e.Component.TimepickerInputPeriodToggle#period).
-}
inputPeriodTogglePeriod : Value InputPeriodTogglePeriod -> Attr { c | period : Supported } msg
inputPeriodTogglePeriod =
    InputPeriodToggle_.period


{-| See [`M3e.Component.TimepickerInputPeriodToggle.orientation`](M3e.Component.TimepickerInputPeriodToggle#orientation).
-}
inputPeriodToggleOrientation : String -> Attr { c | orientation : Supported } msg
inputPeriodToggleOrientation =
    InputPeriodToggle_.orientation


{-| See [`M3e.Component.TimepickerInputPeriodToggle.onChange`](M3e.Component.TimepickerInputPeriodToggle#onChange).
-}
inputPeriodToggleOnChange : msg -> Attr { c | onChange : Supported } msg
inputPeriodToggleOnChange =
    InputPeriodToggle_.onChange
