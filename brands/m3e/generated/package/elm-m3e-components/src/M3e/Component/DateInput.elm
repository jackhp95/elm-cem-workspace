module M3e.Component.DateInput exposing (DateInputIs, DateInputAttrs, DateInputBuilder, DateInputAttrCaps, DateInputSlotCaps, DateInputChildAdmittedBy, DateInputTimeFormat, DateInputType, dateInput, dateInputTimeFormat, dateInputType_, dateInputDayLabel, dateInputDisabled, dateInputHourLabel, dateInputMaxDate, dateInputMaxTime, dateInputMinDate, dateInputMinTime, dateInputMinuteLabel, dateInputMonthLabel, dateInputName, dateInputPeriodLabel, dateInputReadonly, dateInputRequired, dateInputSecondLabel, dateInputShowSeconds, dateInputValidationmessages, dateInputValue, dateInputYearLabel, dateInputDefaultValue, dateInputOnChange, dateInputOnBeforeinput, dateInputOnInput, dateInputOnInvalid)

{-| The **DateInput** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.DateInput`](M3e.Element.DateInput) as `dateInput`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs DateInputIs, DateInputAttrs, DateInputBuilder, DateInputAttrCaps, DateInputSlotCaps, DateInputChildAdmittedBy, DateInputTimeFormat, DateInputType, dateInput, dateInputTimeFormat, dateInputType_, dateInputDayLabel, dateInputDisabled, dateInputHourLabel, dateInputMaxDate, dateInputMaxTime, dateInputMinDate, dateInputMinTime, dateInputMinuteLabel, dateInputMonthLabel, dateInputName, dateInputPeriodLabel, dateInputReadonly, dateInputRequired, dateInputSecondLabel, dateInputShowSeconds, dateInputValidationmessages, dateInputValue, dateInputYearLabel, dateInputDefaultValue, dateInputOnChange, dateInputOnBeforeinput, dateInputOnInput, dateInputOnInvalid

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.DateInput as DateInput_


{-| The `dateInput` element of this family — delegates to [`M3e.Element.DateInput.component`](M3e.Element.DateInput#component).
-}
dateInput :
    List (Attr DateInputAttrs msg)
    -> List (Element childAccepts (DateInputChildAdmittedBy childAdm) msg)
    -> Element (DateInputIs s) admittedBy msg
dateInput =
    DateInput_.component


{-| See [`M3e.Element.DateInput.Is`](M3e.Element.DateInput#Is).
-}
type alias DateInputIs s =
    DateInput_.Is s


{-| See [`M3e.Element.DateInput.Attrs`](M3e.Element.DateInput#Attrs).
-}
type alias DateInputAttrs =
    DateInput_.Attrs


{-| See [`M3e.Element.DateInput.Builder`](M3e.Element.DateInput#Builder).
-}
type alias DateInputBuilder attrCaps slotCaps msg kind =
    DateInput_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.DateInput.AttrCaps`](M3e.Element.DateInput#AttrCaps).
-}
type alias DateInputAttrCaps =
    DateInput_.AttrCaps


{-| See [`M3e.Element.DateInput.SlotCaps`](M3e.Element.DateInput#SlotCaps).
-}
type alias DateInputSlotCaps =
    DateInput_.SlotCaps


{-| See [`M3e.Element.DateInput.ChildAdmittedBy`](M3e.Element.DateInput#ChildAdmittedBy).
-}
type alias DateInputChildAdmittedBy childAdm =
    DateInput_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.DateInput.TimeFormat`](M3e.Element.DateInput#TimeFormat).
-}
type alias DateInputTimeFormat =
    DateInput_.TimeFormat


{-| See [`M3e.Element.DateInput.timeFormat`](M3e.Element.DateInput#timeFormat).
-}
dateInputTimeFormat : Value DateInputTimeFormat -> Attr { c | timeFormat : Supported } msg
dateInputTimeFormat =
    DateInput_.timeFormat


{-| See [`M3e.Element.DateInput.Type`](M3e.Element.DateInput#Type).
-}
type alias DateInputType =
    DateInput_.Type


{-| See [`M3e.Element.DateInput.type_`](M3e.Element.DateInput#type_).
-}
dateInputType_ : Value DateInputType -> Attr { c | type_ : Supported } msg
dateInputType_ =
    DateInput_.type_


{-| See [`M3e.Element.DateInput.dayLabel`](M3e.Element.DateInput#dayLabel).
-}
dateInputDayLabel : String -> Attr { c | dayLabel : Supported } msg
dateInputDayLabel =
    DateInput_.dayLabel


{-| See [`M3e.Element.DateInput.disabled`](M3e.Element.DateInput#disabled).
-}
dateInputDisabled : Bool -> Attr { c | disabled : Supported } msg
dateInputDisabled =
    DateInput_.disabled


{-| See [`M3e.Element.DateInput.hourLabel`](M3e.Element.DateInput#hourLabel).
-}
dateInputHourLabel : String -> Attr { c | hourLabel : Supported } msg
dateInputHourLabel =
    DateInput_.hourLabel


{-| See [`M3e.Element.DateInput.maxDate`](M3e.Element.DateInput#maxDate).
-}
dateInputMaxDate : String -> Attr { c | maxDate : Supported } msg
dateInputMaxDate =
    DateInput_.maxDate


{-| See [`M3e.Element.DateInput.maxTime`](M3e.Element.DateInput#maxTime).
-}
dateInputMaxTime : String -> Attr { c | maxTime : Supported } msg
dateInputMaxTime =
    DateInput_.maxTime


{-| See [`M3e.Element.DateInput.minDate`](M3e.Element.DateInput#minDate).
-}
dateInputMinDate : String -> Attr { c | minDate : Supported } msg
dateInputMinDate =
    DateInput_.minDate


{-| See [`M3e.Element.DateInput.minTime`](M3e.Element.DateInput#minTime).
-}
dateInputMinTime : String -> Attr { c | minTime : Supported } msg
dateInputMinTime =
    DateInput_.minTime


{-| See [`M3e.Element.DateInput.minuteLabel`](M3e.Element.DateInput#minuteLabel).
-}
dateInputMinuteLabel : String -> Attr { c | minuteLabel : Supported } msg
dateInputMinuteLabel =
    DateInput_.minuteLabel


{-| See [`M3e.Element.DateInput.monthLabel`](M3e.Element.DateInput#monthLabel).
-}
dateInputMonthLabel : String -> Attr { c | monthLabel : Supported } msg
dateInputMonthLabel =
    DateInput_.monthLabel


{-| See [`M3e.Element.DateInput.name`](M3e.Element.DateInput#name).
-}
dateInputName : String -> Attr { c | name : Supported } msg
dateInputName =
    DateInput_.name


{-| See [`M3e.Element.DateInput.periodLabel`](M3e.Element.DateInput#periodLabel).
-}
dateInputPeriodLabel : String -> Attr { c | periodLabel : Supported } msg
dateInputPeriodLabel =
    DateInput_.periodLabel


{-| See [`M3e.Element.DateInput.readonly`](M3e.Element.DateInput#readonly).
-}
dateInputReadonly : Bool -> Attr { c | readonly : Supported } msg
dateInputReadonly =
    DateInput_.readonly


{-| See [`M3e.Element.DateInput.required`](M3e.Element.DateInput#required).
-}
dateInputRequired : Bool -> Attr { c | required : Supported } msg
dateInputRequired =
    DateInput_.required


{-| See [`M3e.Element.DateInput.secondLabel`](M3e.Element.DateInput#secondLabel).
-}
dateInputSecondLabel : String -> Attr { c | secondLabel : Supported } msg
dateInputSecondLabel =
    DateInput_.secondLabel


{-| See [`M3e.Element.DateInput.showSeconds`](M3e.Element.DateInput#showSeconds).
-}
dateInputShowSeconds : Bool -> Attr { c | showSeconds : Supported } msg
dateInputShowSeconds =
    DateInput_.showSeconds


{-| See [`M3e.Element.DateInput.validationmessages`](M3e.Element.DateInput#validationmessages).
-}
dateInputValidationmessages : String -> Attr { c | validationmessages : Supported } msg
dateInputValidationmessages =
    DateInput_.validationmessages


{-| See [`M3e.Element.DateInput.value`](M3e.Element.DateInput#value).
-}
dateInputValue : String -> Attr { c | value : Supported } msg
dateInputValue =
    DateInput_.value


{-| See [`M3e.Element.DateInput.yearLabel`](M3e.Element.DateInput#yearLabel).
-}
dateInputYearLabel : String -> Attr { c | yearLabel : Supported } msg
dateInputYearLabel =
    DateInput_.yearLabel


{-| See [`M3e.Element.DateInput.defaultValue`](M3e.Element.DateInput#defaultValue).
-}
dateInputDefaultValue : String -> Attr { c | value : Supported } msg
dateInputDefaultValue =
    DateInput_.defaultValue


{-| See [`M3e.Element.DateInput.onChange`](M3e.Element.DateInput#onChange).
-}
dateInputOnChange : msg -> Attr { c | onChange : Supported } msg
dateInputOnChange =
    DateInput_.onChange


{-| See [`M3e.Element.DateInput.onBeforeinput`](M3e.Element.DateInput#onBeforeinput).
-}
dateInputOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
dateInputOnBeforeinput =
    DateInput_.onBeforeinput


{-| See [`M3e.Element.DateInput.onInput`](M3e.Element.DateInput#onInput).
-}
dateInputOnInput : msg -> Attr { c | onInput : Supported } msg
dateInputOnInput =
    DateInput_.onInput


{-| See [`M3e.Element.DateInput.onInvalid`](M3e.Element.DateInput#onInvalid).
-}
dateInputOnInvalid : msg -> Attr { c | onInvalid : Supported } msg
dateInputOnInvalid =
    DateInput_.onInvalid
