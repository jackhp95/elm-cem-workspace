module M3e.Component.Timepicker exposing (TimepickerIs, TimepickerAttrs, TimepickerBuilder, TimepickerAttrCaps, TimepickerSlotCaps, TimepickerChildAdmittedBy, TimepickerFormat, TimepickerMode, TimepickerOrientation, TimepickerVariant, ToggleIs, ToggleAttrs, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleChildAdmittedBy, DialIs, DialAttrs, DialBuilder, DialAttrCaps, DialSlotCaps, DialChildAdmittedBy, DialFormat, DialPeriod, DialViewAttr, InputIs, InputAttrs, InputBuilder, InputAttrCaps, InputSlotCaps, InputChildAdmittedBy, InputFormat, InputPeriod, InputViewAttr, InputPeriodToggleIs, InputPeriodToggleAttrs, InputPeriodToggleBuilder, InputPeriodToggleAttrCaps, InputPeriodToggleSlotCaps, InputPeriodToggleChildAdmittedBy, InputPeriodTogglePeriod, timepicker, timepickerFormat, timepickerMode, timepickerOrientation, timepickerVariant, timepickerConfirmLabel, timepickerDate, timepickerDialLabel, timepickerDismissLabel, timepickerFor, timepickerHideModeToggle, timepickerHourLabel, timepickerInputLabel, timepickerMaxTime, timepickerMinTime, timepickerMinuteLabel, timepickerModeToggleLabel, timepickerPeriodToggleLabel, timepickerSecondLabel, timepickerShowSeconds, timepickerOnChange, timepickerOnBeforetoggle, timepickerOnToggle, toggle, toggleFor, dial, dialFormat, dialPeriod, dialViewAttr, dialHour, dialMaxTime, dialMinTime, dialMinute, dialSecond, dialShowSeconds, dialOnInput, dialOnChange, dialOnViewChange, input, inputFormat, inputPeriod, inputViewAttr, inputFor, inputHideLabels, inputHour, inputHourLabel, inputMaxTime, inputMinTime, inputMinute, inputMinuteLabel, inputOrientation, inputPeriodToggleLabel, inputSecond, inputSecondLabel, inputShowSeconds, inputOnViewChange, inputOnChange, inputPeriodToggle, inputPeriodTogglePeriod, inputPeriodToggleOrientation, inputPeriodToggleOnChange)

{-| The **Timepicker** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Timepicker`](M3e.Element.Timepicker) as `timepicker`, [`M3e.Element.TimepickerToggle`](M3e.Element.TimepickerToggle) as `toggle`, [`M3e.Element.TimepickerDial`](M3e.Element.TimepickerDial) as `dial`, [`M3e.Element.TimepickerInput`](M3e.Element.TimepickerInput) as `input`, [`M3e.Element.TimepickerInputPeriodToggle`](M3e.Element.TimepickerInputPeriodToggle) as `inputPeriodToggle`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs TimepickerIs, TimepickerAttrs, TimepickerBuilder, TimepickerAttrCaps, TimepickerSlotCaps, TimepickerChildAdmittedBy, TimepickerFormat, TimepickerMode, TimepickerOrientation, TimepickerVariant, ToggleIs, ToggleAttrs, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleChildAdmittedBy, DialIs, DialAttrs, DialBuilder, DialAttrCaps, DialSlotCaps, DialChildAdmittedBy, DialFormat, DialPeriod, DialViewAttr, InputIs, InputAttrs, InputBuilder, InputAttrCaps, InputSlotCaps, InputChildAdmittedBy, InputFormat, InputPeriod, InputViewAttr, InputPeriodToggleIs, InputPeriodToggleAttrs, InputPeriodToggleBuilder, InputPeriodToggleAttrCaps, InputPeriodToggleSlotCaps, InputPeriodToggleChildAdmittedBy, InputPeriodTogglePeriod, timepicker, timepickerFormat, timepickerMode, timepickerOrientation, timepickerVariant, timepickerConfirmLabel, timepickerDate, timepickerDialLabel, timepickerDismissLabel, timepickerFor, timepickerHideModeToggle, timepickerHourLabel, timepickerInputLabel, timepickerMaxTime, timepickerMinTime, timepickerMinuteLabel, timepickerModeToggleLabel, timepickerPeriodToggleLabel, timepickerSecondLabel, timepickerShowSeconds, timepickerOnChange, timepickerOnBeforetoggle, timepickerOnToggle, toggle, toggleFor, dial, dialFormat, dialPeriod, dialViewAttr, dialHour, dialMaxTime, dialMinTime, dialMinute, dialSecond, dialShowSeconds, dialOnInput, dialOnChange, dialOnViewChange, input, inputFormat, inputPeriod, inputViewAttr, inputFor, inputHideLabels, inputHour, inputHourLabel, inputMaxTime, inputMinTime, inputMinute, inputMinuteLabel, inputOrientation, inputPeriodToggleLabel, inputSecond, inputSecondLabel, inputShowSeconds, inputOnViewChange, inputOnChange, inputPeriodToggle, inputPeriodTogglePeriod, inputPeriodToggleOrientation, inputPeriodToggleOnChange

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Timepicker as Timepicker_
import M3e.Element.TimepickerDial as Dial_
import M3e.Element.TimepickerInput as Input_
import M3e.Element.TimepickerInputPeriodToggle as InputPeriodToggle_
import M3e.Element.TimepickerToggle as Toggle_


{-| The `timepicker` element of this family — delegates to [`M3e.Element.Timepicker.component`](M3e.Element.Timepicker#component).
-}
timepicker :
    List (Attr TimepickerAttrs msg)
    -> List (Element childAccepts (TimepickerChildAdmittedBy childAdm) msg)
    -> Element (TimepickerIs s) admittedBy msg
timepicker =
    Timepicker_.component


{-| See [`M3e.Element.Timepicker.Is`](M3e.Element.Timepicker#Is).
-}
type alias TimepickerIs s =
    Timepicker_.Is s


{-| See [`M3e.Element.Timepicker.Attrs`](M3e.Element.Timepicker#Attrs).
-}
type alias TimepickerAttrs =
    Timepicker_.Attrs


{-| See [`M3e.Element.Timepicker.Builder`](M3e.Element.Timepicker#Builder).
-}
type alias TimepickerBuilder attrCaps slotCaps msg kind =
    Timepicker_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Timepicker.AttrCaps`](M3e.Element.Timepicker#AttrCaps).
-}
type alias TimepickerAttrCaps =
    Timepicker_.AttrCaps


{-| See [`M3e.Element.Timepicker.SlotCaps`](M3e.Element.Timepicker#SlotCaps).
-}
type alias TimepickerSlotCaps =
    Timepicker_.SlotCaps


{-| See [`M3e.Element.Timepicker.ChildAdmittedBy`](M3e.Element.Timepicker#ChildAdmittedBy).
-}
type alias TimepickerChildAdmittedBy childAdm =
    Timepicker_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Timepicker.Format`](M3e.Element.Timepicker#Format).
-}
type alias TimepickerFormat =
    Timepicker_.Format


{-| See [`M3e.Element.Timepicker.format`](M3e.Element.Timepicker#format).
-}
timepickerFormat : Value TimepickerFormat -> Attr { c | format : Supported } msg
timepickerFormat =
    Timepicker_.format


{-| See [`M3e.Element.Timepicker.Mode`](M3e.Element.Timepicker#Mode).
-}
type alias TimepickerMode =
    Timepicker_.Mode


{-| See [`M3e.Element.Timepicker.mode`](M3e.Element.Timepicker#mode).
-}
timepickerMode : Value TimepickerMode -> Attr { c | mode : Supported } msg
timepickerMode =
    Timepicker_.mode


{-| See [`M3e.Element.Timepicker.Orientation`](M3e.Element.Timepicker#Orientation).
-}
type alias TimepickerOrientation =
    Timepicker_.Orientation


{-| See [`M3e.Element.Timepicker.orientation`](M3e.Element.Timepicker#orientation).
-}
timepickerOrientation : Value TimepickerOrientation -> Attr { c | orientation : Supported } msg
timepickerOrientation =
    Timepicker_.orientation


{-| See [`M3e.Element.Timepicker.Variant`](M3e.Element.Timepicker#Variant).
-}
type alias TimepickerVariant =
    Timepicker_.Variant


{-| See [`M3e.Element.Timepicker.variant`](M3e.Element.Timepicker#variant).
-}
timepickerVariant : Value TimepickerVariant -> Attr { c | variant : Supported } msg
timepickerVariant =
    Timepicker_.variant


{-| See [`M3e.Element.Timepicker.confirmLabel`](M3e.Element.Timepicker#confirmLabel).
-}
timepickerConfirmLabel : String -> Attr { c | confirmLabel : Supported } msg
timepickerConfirmLabel =
    Timepicker_.confirmLabel


{-| See [`M3e.Element.Timepicker.date`](M3e.Element.Timepicker#date).
-}
timepickerDate : String -> Attr { c | date : Supported } msg
timepickerDate =
    Timepicker_.date


{-| See [`M3e.Element.Timepicker.dialLabel`](M3e.Element.Timepicker#dialLabel).
-}
timepickerDialLabel : String -> Attr { c | dialLabel : Supported } msg
timepickerDialLabel =
    Timepicker_.dialLabel


{-| See [`M3e.Element.Timepicker.dismissLabel`](M3e.Element.Timepicker#dismissLabel).
-}
timepickerDismissLabel : String -> Attr { c | dismissLabel : Supported } msg
timepickerDismissLabel =
    Timepicker_.dismissLabel


{-| See [`M3e.Element.Timepicker.for`](M3e.Element.Timepicker#for).
-}
timepickerFor : String -> Attr { c | for : Supported } msg
timepickerFor =
    Timepicker_.for


{-| See [`M3e.Element.Timepicker.hideModeToggle`](M3e.Element.Timepicker#hideModeToggle).
-}
timepickerHideModeToggle : Bool -> Attr { c | hideModeToggle : Supported } msg
timepickerHideModeToggle =
    Timepicker_.hideModeToggle


{-| See [`M3e.Element.Timepicker.hourLabel`](M3e.Element.Timepicker#hourLabel).
-}
timepickerHourLabel : String -> Attr { c | hourLabel : Supported } msg
timepickerHourLabel =
    Timepicker_.hourLabel


{-| See [`M3e.Element.Timepicker.inputLabel`](M3e.Element.Timepicker#inputLabel).
-}
timepickerInputLabel : String -> Attr { c | inputLabel : Supported } msg
timepickerInputLabel =
    Timepicker_.inputLabel


{-| See [`M3e.Element.Timepicker.maxTime`](M3e.Element.Timepicker#maxTime).
-}
timepickerMaxTime : String -> Attr { c | maxTime : Supported } msg
timepickerMaxTime =
    Timepicker_.maxTime


{-| See [`M3e.Element.Timepicker.minTime`](M3e.Element.Timepicker#minTime).
-}
timepickerMinTime : String -> Attr { c | minTime : Supported } msg
timepickerMinTime =
    Timepicker_.minTime


{-| See [`M3e.Element.Timepicker.minuteLabel`](M3e.Element.Timepicker#minuteLabel).
-}
timepickerMinuteLabel : String -> Attr { c | minuteLabel : Supported } msg
timepickerMinuteLabel =
    Timepicker_.minuteLabel


{-| See [`M3e.Element.Timepicker.modeToggleLabel`](M3e.Element.Timepicker#modeToggleLabel).
-}
timepickerModeToggleLabel : String -> Attr { c | modeToggleLabel : Supported } msg
timepickerModeToggleLabel =
    Timepicker_.modeToggleLabel


{-| See [`M3e.Element.Timepicker.periodToggleLabel`](M3e.Element.Timepicker#periodToggleLabel).
-}
timepickerPeriodToggleLabel : String -> Attr { c | periodToggleLabel : Supported } msg
timepickerPeriodToggleLabel =
    Timepicker_.periodToggleLabel


{-| See [`M3e.Element.Timepicker.secondLabel`](M3e.Element.Timepicker#secondLabel).
-}
timepickerSecondLabel : String -> Attr { c | secondLabel : Supported } msg
timepickerSecondLabel =
    Timepicker_.secondLabel


{-| See [`M3e.Element.Timepicker.showSeconds`](M3e.Element.Timepicker#showSeconds).
-}
timepickerShowSeconds : Bool -> Attr { c | showSeconds : Supported } msg
timepickerShowSeconds =
    Timepicker_.showSeconds


{-| See [`M3e.Element.Timepicker.onChange`](M3e.Element.Timepicker#onChange).
-}
timepickerOnChange : msg -> Attr { c | onChange : Supported } msg
timepickerOnChange =
    Timepicker_.onChange


{-| See [`M3e.Element.Timepicker.onBeforetoggle`](M3e.Element.Timepicker#onBeforetoggle).
-}
timepickerOnBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
timepickerOnBeforetoggle =
    Timepicker_.onBeforetoggle


{-| See [`M3e.Element.Timepicker.onToggle`](M3e.Element.Timepicker#onToggle).
-}
timepickerOnToggle : msg -> Attr { c | onToggle : Supported } msg
timepickerOnToggle =
    Timepicker_.onToggle


{-| The `toggle` element of this family — delegates to [`M3e.Element.TimepickerToggle.component`](M3e.Element.TimepickerToggle#component).
-}
toggle :
    List (Attr ToggleAttrs msg)
    -> List (Element childAccepts (ToggleChildAdmittedBy childAdm) msg)
    -> Element (ToggleIs s) admittedBy msg
toggle =
    Toggle_.component


{-| See [`M3e.Element.TimepickerToggle.Is`](M3e.Element.TimepickerToggle#Is).
-}
type alias ToggleIs s =
    Toggle_.Is s


{-| See [`M3e.Element.TimepickerToggle.Attrs`](M3e.Element.TimepickerToggle#Attrs).
-}
type alias ToggleAttrs =
    Toggle_.Attrs


{-| See [`M3e.Element.TimepickerToggle.Builder`](M3e.Element.TimepickerToggle#Builder).
-}
type alias ToggleBuilder attrCaps slotCaps msg kind =
    Toggle_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.TimepickerToggle.AttrCaps`](M3e.Element.TimepickerToggle#AttrCaps).
-}
type alias ToggleAttrCaps =
    Toggle_.AttrCaps


{-| See [`M3e.Element.TimepickerToggle.SlotCaps`](M3e.Element.TimepickerToggle#SlotCaps).
-}
type alias ToggleSlotCaps =
    Toggle_.SlotCaps


{-| See [`M3e.Element.TimepickerToggle.ChildAdmittedBy`](M3e.Element.TimepickerToggle#ChildAdmittedBy).
-}
type alias ToggleChildAdmittedBy childAdm =
    Toggle_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.TimepickerToggle.for`](M3e.Element.TimepickerToggle#for).
-}
toggleFor : String -> Attr { c | for : Supported } msg
toggleFor =
    Toggle_.for


{-| The `dial` element of this family — delegates to [`M3e.Element.TimepickerDial.component`](M3e.Element.TimepickerDial#component).
-}
dial :
    List (Attr DialAttrs msg)
    -> List (Element childAccepts (DialChildAdmittedBy childAdm) msg)
    -> Element (DialIs s) admittedBy msg
dial =
    Dial_.component


{-| See [`M3e.Element.TimepickerDial.Is`](M3e.Element.TimepickerDial#Is).
-}
type alias DialIs s =
    Dial_.Is s


{-| See [`M3e.Element.TimepickerDial.Attrs`](M3e.Element.TimepickerDial#Attrs).
-}
type alias DialAttrs =
    Dial_.Attrs


{-| See [`M3e.Element.TimepickerDial.Builder`](M3e.Element.TimepickerDial#Builder).
-}
type alias DialBuilder attrCaps slotCaps msg kind =
    Dial_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.TimepickerDial.AttrCaps`](M3e.Element.TimepickerDial#AttrCaps).
-}
type alias DialAttrCaps =
    Dial_.AttrCaps


{-| See [`M3e.Element.TimepickerDial.SlotCaps`](M3e.Element.TimepickerDial#SlotCaps).
-}
type alias DialSlotCaps =
    Dial_.SlotCaps


{-| See [`M3e.Element.TimepickerDial.ChildAdmittedBy`](M3e.Element.TimepickerDial#ChildAdmittedBy).
-}
type alias DialChildAdmittedBy childAdm =
    Dial_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.TimepickerDial.Format`](M3e.Element.TimepickerDial#Format).
-}
type alias DialFormat =
    Dial_.Format


{-| See [`M3e.Element.TimepickerDial.format`](M3e.Element.TimepickerDial#format).
-}
dialFormat : Value DialFormat -> Attr { c | format : Supported } msg
dialFormat =
    Dial_.format


{-| See [`M3e.Element.TimepickerDial.Period`](M3e.Element.TimepickerDial#Period).
-}
type alias DialPeriod =
    Dial_.Period


{-| See [`M3e.Element.TimepickerDial.period`](M3e.Element.TimepickerDial#period).
-}
dialPeriod : Value DialPeriod -> Attr { c | period : Supported } msg
dialPeriod =
    Dial_.period


{-| See [`M3e.Element.TimepickerDial.ViewAttr`](M3e.Element.TimepickerDial#ViewAttr).
-}
type alias DialViewAttr =
    Dial_.ViewAttr


{-| See [`M3e.Element.TimepickerDial.viewAttr`](M3e.Element.TimepickerDial#viewAttr).
-}
dialViewAttr : Value DialViewAttr -> Attr { c | viewAttr : Supported } msg
dialViewAttr =
    Dial_.viewAttr


{-| See [`M3e.Element.TimepickerDial.hour`](M3e.Element.TimepickerDial#hour).
-}
dialHour : Float -> Attr { c | hour : Supported } msg
dialHour =
    Dial_.hour


{-| See [`M3e.Element.TimepickerDial.maxTime`](M3e.Element.TimepickerDial#maxTime).
-}
dialMaxTime : String -> Attr { c | maxTime : Supported } msg
dialMaxTime =
    Dial_.maxTime


{-| See [`M3e.Element.TimepickerDial.minTime`](M3e.Element.TimepickerDial#minTime).
-}
dialMinTime : String -> Attr { c | minTime : Supported } msg
dialMinTime =
    Dial_.minTime


{-| See [`M3e.Element.TimepickerDial.minute`](M3e.Element.TimepickerDial#minute).
-}
dialMinute : Float -> Attr { c | minute : Supported } msg
dialMinute =
    Dial_.minute


{-| See [`M3e.Element.TimepickerDial.second`](M3e.Element.TimepickerDial#second).
-}
dialSecond : Float -> Attr { c | second : Supported } msg
dialSecond =
    Dial_.second


{-| See [`M3e.Element.TimepickerDial.showSeconds`](M3e.Element.TimepickerDial#showSeconds).
-}
dialShowSeconds : Bool -> Attr { c | showSeconds : Supported } msg
dialShowSeconds =
    Dial_.showSeconds


{-| See [`M3e.Element.TimepickerDial.onInput`](M3e.Element.TimepickerDial#onInput).
-}
dialOnInput : msg -> Attr { c | onInput : Supported } msg
dialOnInput =
    Dial_.onInput


{-| See [`M3e.Element.TimepickerDial.onChange`](M3e.Element.TimepickerDial#onChange).
-}
dialOnChange : msg -> Attr { c | onChange : Supported } msg
dialOnChange =
    Dial_.onChange


{-| See [`M3e.Element.TimepickerDial.onViewChange`](M3e.Element.TimepickerDial#onViewChange).
-}
dialOnViewChange : msg -> Attr { c | onViewChange : Supported } msg
dialOnViewChange =
    Dial_.onViewChange


{-| The `input` element of this family — delegates to [`M3e.Element.TimepickerInput.component`](M3e.Element.TimepickerInput#component).
-}
input :
    List (Attr InputAttrs msg)
    -> List (Element childAccepts (InputChildAdmittedBy childAdm) msg)
    -> Element (InputIs s) admittedBy msg
input =
    Input_.component


{-| See [`M3e.Element.TimepickerInput.Is`](M3e.Element.TimepickerInput#Is).
-}
type alias InputIs s =
    Input_.Is s


{-| See [`M3e.Element.TimepickerInput.Attrs`](M3e.Element.TimepickerInput#Attrs).
-}
type alias InputAttrs =
    Input_.Attrs


{-| See [`M3e.Element.TimepickerInput.Builder`](M3e.Element.TimepickerInput#Builder).
-}
type alias InputBuilder attrCaps slotCaps msg kind =
    Input_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.TimepickerInput.AttrCaps`](M3e.Element.TimepickerInput#AttrCaps).
-}
type alias InputAttrCaps =
    Input_.AttrCaps


{-| See [`M3e.Element.TimepickerInput.SlotCaps`](M3e.Element.TimepickerInput#SlotCaps).
-}
type alias InputSlotCaps =
    Input_.SlotCaps


{-| See [`M3e.Element.TimepickerInput.ChildAdmittedBy`](M3e.Element.TimepickerInput#ChildAdmittedBy).
-}
type alias InputChildAdmittedBy childAdm =
    Input_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.TimepickerInput.Format`](M3e.Element.TimepickerInput#Format).
-}
type alias InputFormat =
    Input_.Format


{-| See [`M3e.Element.TimepickerInput.format`](M3e.Element.TimepickerInput#format).
-}
inputFormat : Value InputFormat -> Attr { c | format : Supported } msg
inputFormat =
    Input_.format


{-| See [`M3e.Element.TimepickerInput.Period`](M3e.Element.TimepickerInput#Period).
-}
type alias InputPeriod =
    Input_.Period


{-| See [`M3e.Element.TimepickerInput.period`](M3e.Element.TimepickerInput#period).
-}
inputPeriod : Value InputPeriod -> Attr { c | period : Supported } msg
inputPeriod =
    Input_.period


{-| See [`M3e.Element.TimepickerInput.ViewAttr`](M3e.Element.TimepickerInput#ViewAttr).
-}
type alias InputViewAttr =
    Input_.ViewAttr


{-| See [`M3e.Element.TimepickerInput.viewAttr`](M3e.Element.TimepickerInput#viewAttr).
-}
inputViewAttr : Value InputViewAttr -> Attr { c | viewAttr : Supported } msg
inputViewAttr =
    Input_.viewAttr


{-| See [`M3e.Element.TimepickerInput.for`](M3e.Element.TimepickerInput#for).
-}
inputFor : String -> Attr { c | for : Supported } msg
inputFor =
    Input_.for


{-| See [`M3e.Element.TimepickerInput.hideLabels`](M3e.Element.TimepickerInput#hideLabels).
-}
inputHideLabels : Bool -> Attr { c | hideLabels : Supported } msg
inputHideLabels =
    Input_.hideLabels


{-| See [`M3e.Element.TimepickerInput.hour`](M3e.Element.TimepickerInput#hour).
-}
inputHour : Float -> Attr { c | hour : Supported } msg
inputHour =
    Input_.hour


{-| See [`M3e.Element.TimepickerInput.hourLabel`](M3e.Element.TimepickerInput#hourLabel).
-}
inputHourLabel : String -> Attr { c | hourLabel : Supported } msg
inputHourLabel =
    Input_.hourLabel


{-| See [`M3e.Element.TimepickerInput.maxTime`](M3e.Element.TimepickerInput#maxTime).
-}
inputMaxTime : String -> Attr { c | maxTime : Supported } msg
inputMaxTime =
    Input_.maxTime


{-| See [`M3e.Element.TimepickerInput.minTime`](M3e.Element.TimepickerInput#minTime).
-}
inputMinTime : String -> Attr { c | minTime : Supported } msg
inputMinTime =
    Input_.minTime


{-| See [`M3e.Element.TimepickerInput.minute`](M3e.Element.TimepickerInput#minute).
-}
inputMinute : Float -> Attr { c | minute : Supported } msg
inputMinute =
    Input_.minute


{-| See [`M3e.Element.TimepickerInput.minuteLabel`](M3e.Element.TimepickerInput#minuteLabel).
-}
inputMinuteLabel : String -> Attr { c | minuteLabel : Supported } msg
inputMinuteLabel =
    Input_.minuteLabel


{-| See [`M3e.Element.TimepickerInput.orientation`](M3e.Element.TimepickerInput#orientation).
-}
inputOrientation : String -> Attr { c | orientation : Supported } msg
inputOrientation =
    Input_.orientation


{-| See [`M3e.Element.TimepickerInput.periodToggleLabel`](M3e.Element.TimepickerInput#periodToggleLabel).
-}
inputPeriodToggleLabel : String -> Attr { c | periodToggleLabel : Supported } msg
inputPeriodToggleLabel =
    Input_.periodToggleLabel


{-| See [`M3e.Element.TimepickerInput.second`](M3e.Element.TimepickerInput#second).
-}
inputSecond : Float -> Attr { c | second : Supported } msg
inputSecond =
    Input_.second


{-| See [`M3e.Element.TimepickerInput.secondLabel`](M3e.Element.TimepickerInput#secondLabel).
-}
inputSecondLabel : String -> Attr { c | secondLabel : Supported } msg
inputSecondLabel =
    Input_.secondLabel


{-| See [`M3e.Element.TimepickerInput.showSeconds`](M3e.Element.TimepickerInput#showSeconds).
-}
inputShowSeconds : Bool -> Attr { c | showSeconds : Supported } msg
inputShowSeconds =
    Input_.showSeconds


{-| See [`M3e.Element.TimepickerInput.onViewChange`](M3e.Element.TimepickerInput#onViewChange).
-}
inputOnViewChange : msg -> Attr { c | onViewChange : Supported } msg
inputOnViewChange =
    Input_.onViewChange


{-| See [`M3e.Element.TimepickerInput.onChange`](M3e.Element.TimepickerInput#onChange).
-}
inputOnChange : msg -> Attr { c | onChange : Supported } msg
inputOnChange =
    Input_.onChange


{-| The `inputPeriodToggle` element of this family — delegates to [`M3e.Element.TimepickerInputPeriodToggle.component`](M3e.Element.TimepickerInputPeriodToggle#component).
-}
inputPeriodToggle :
    List (Attr InputPeriodToggleAttrs msg)
    -> List (Element childAccepts (InputPeriodToggleChildAdmittedBy childAdm) msg)
    -> Element (InputPeriodToggleIs s) admittedBy msg
inputPeriodToggle =
    InputPeriodToggle_.component


{-| See [`M3e.Element.TimepickerInputPeriodToggle.Is`](M3e.Element.TimepickerInputPeriodToggle#Is).
-}
type alias InputPeriodToggleIs s =
    InputPeriodToggle_.Is s


{-| See [`M3e.Element.TimepickerInputPeriodToggle.Attrs`](M3e.Element.TimepickerInputPeriodToggle#Attrs).
-}
type alias InputPeriodToggleAttrs =
    InputPeriodToggle_.Attrs


{-| See [`M3e.Element.TimepickerInputPeriodToggle.Builder`](M3e.Element.TimepickerInputPeriodToggle#Builder).
-}
type alias InputPeriodToggleBuilder attrCaps slotCaps msg kind =
    InputPeriodToggle_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.TimepickerInputPeriodToggle.AttrCaps`](M3e.Element.TimepickerInputPeriodToggle#AttrCaps).
-}
type alias InputPeriodToggleAttrCaps =
    InputPeriodToggle_.AttrCaps


{-| See [`M3e.Element.TimepickerInputPeriodToggle.SlotCaps`](M3e.Element.TimepickerInputPeriodToggle#SlotCaps).
-}
type alias InputPeriodToggleSlotCaps =
    InputPeriodToggle_.SlotCaps


{-| See [`M3e.Element.TimepickerInputPeriodToggle.ChildAdmittedBy`](M3e.Element.TimepickerInputPeriodToggle#ChildAdmittedBy).
-}
type alias InputPeriodToggleChildAdmittedBy childAdm =
    InputPeriodToggle_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.TimepickerInputPeriodToggle.Period`](M3e.Element.TimepickerInputPeriodToggle#Period).
-}
type alias InputPeriodTogglePeriod =
    InputPeriodToggle_.Period


{-| See [`M3e.Element.TimepickerInputPeriodToggle.period`](M3e.Element.TimepickerInputPeriodToggle#period).
-}
inputPeriodTogglePeriod : Value InputPeriodTogglePeriod -> Attr { c | period : Supported } msg
inputPeriodTogglePeriod =
    InputPeriodToggle_.period


{-| See [`M3e.Element.TimepickerInputPeriodToggle.orientation`](M3e.Element.TimepickerInputPeriodToggle#orientation).
-}
inputPeriodToggleOrientation : String -> Attr { c | orientation : Supported } msg
inputPeriodToggleOrientation =
    InputPeriodToggle_.orientation


{-| See [`M3e.Element.TimepickerInputPeriodToggle.onChange`](M3e.Element.TimepickerInputPeriodToggle#onChange).
-}
inputPeriodToggleOnChange : msg -> Attr { c | onChange : Supported } msg
inputPeriodToggleOnChange =
    InputPeriodToggle_.onChange
