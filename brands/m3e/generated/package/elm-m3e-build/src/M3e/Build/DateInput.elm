module M3e.Build.DateInput exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDayLabel, withDisabled, withHourLabel, withId, withMaxDate, withMaxTime, withMinDate, withMinTime, withMinuteLabel, withMonthLabel, withName, withOnBeforeinput, withOnChange, withOnInput, withOnInvalid, withPeriodLabel, withReadonly, withRequired, withSecondLabel, withShowSeconds, withSlot, withStyle, withTimeFormat, withType, withValidationmessages, withValue, withYearLabel)

{-| The **DateInput** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.DateInput`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDayLabel, withDisabled, withHourLabel, withId, withMaxDate, withMaxTime, withMinDate, withMinTime, withMinuteLabel, withMonthLabel, withName, withOnBeforeinput, withOnChange, withOnInput, withOnInvalid, withPeriodLabel, withReadonly, withRequired, withSecondLabel, withShowSeconds, withSlot, withStyle, withTimeFormat, withType, withValidationmessages, withValue, withYearLabel

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Component.DateInput as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.DateInputIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.DateInputBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.DateInputAttrCaps


{-| -}
type alias SlotCaps =
    Component.DateInputSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.DateInputChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-date-input" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.DateInputIs kind) admittedBy msg
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
withDayLabel : String -> Builder { a | dayLabel : Available } slotCaps msg kind -> Builder { a | dayLabel : Used } slotCaps msg kind
withDayLabel value_ =
    B.withAttribute (A.dayLabel value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withHourLabel : String -> Builder { a | hourLabel : Available } slotCaps msg kind -> Builder { a | hourLabel : Used } slotCaps msg kind
withHourLabel value_ =
    B.withAttribute (A.hourLabel value_)


{-| -}
withMaxDate : String -> Builder { a | maxDate : Available } slotCaps msg kind -> Builder { a | maxDate : Used } slotCaps msg kind
withMaxDate value_ =
    B.withAttribute (A.maxDate value_)


{-| -}
withMaxTime : String -> Builder { a | maxTime : Available } slotCaps msg kind -> Builder { a | maxTime : Used } slotCaps msg kind
withMaxTime value_ =
    B.withAttribute (A.maxTime value_)


{-| -}
withMinDate : String -> Builder { a | minDate : Available } slotCaps msg kind -> Builder { a | minDate : Used } slotCaps msg kind
withMinDate value_ =
    B.withAttribute (A.minDate value_)


{-| -}
withMinTime : String -> Builder { a | minTime : Available } slotCaps msg kind -> Builder { a | minTime : Used } slotCaps msg kind
withMinTime value_ =
    B.withAttribute (A.minTime value_)


{-| -}
withMinuteLabel : String -> Builder { a | minuteLabel : Available } slotCaps msg kind -> Builder { a | minuteLabel : Used } slotCaps msg kind
withMinuteLabel value_ =
    B.withAttribute (A.minuteLabel value_)


{-| -}
withMonthLabel : String -> Builder { a | monthLabel : Available } slotCaps msg kind -> Builder { a | monthLabel : Used } slotCaps msg kind
withMonthLabel value_ =
    B.withAttribute (A.monthLabel value_)


{-| -}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (Ir.attribute "name" value_)


{-| -}
withPeriodLabel : String -> Builder { a | periodLabel : Available } slotCaps msg kind -> Builder { a | periodLabel : Used } slotCaps msg kind
withPeriodLabel value_ =
    B.withAttribute (A.periodLabel value_)


{-| -}
withReadonly : Bool -> Builder { a | readonly : Available } slotCaps msg kind -> Builder { a | readonly : Used } slotCaps msg kind
withReadonly value_ =
    B.withAttribute (A.readonly value_)


{-| -}
withRequired : Bool -> Builder { a | required : Available } slotCaps msg kind -> Builder { a | required : Used } slotCaps msg kind
withRequired value_ =
    B.withAttribute (A.required value_)


{-| -}
withSecondLabel : String -> Builder { a | secondLabel : Available } slotCaps msg kind -> Builder { a | secondLabel : Used } slotCaps msg kind
withSecondLabel value_ =
    B.withAttribute (A.secondLabel value_)


{-| -}
withShowSeconds : Bool -> Builder { a | showSeconds : Available } slotCaps msg kind -> Builder { a | showSeconds : Used } slotCaps msg kind
withShowSeconds value_ =
    B.withAttribute (A.showSeconds value_)


{-| -}
withTimeFormat : Value Component.DateInputTimeFormat -> Builder { a | timeFormat : Available } slotCaps msg kind -> Builder { a | timeFormat : Used } slotCaps msg kind
withTimeFormat value_ =
    B.withAttribute (Component.dateInputTimeFormat value_)


{-| -}
withType : Value Component.DateInputType -> Builder { a | type_ : Available } slotCaps msg kind -> Builder { a | type_ : Used } slotCaps msg kind
withType value_ =
    B.withAttribute (Component.dateInputType_ value_)


{-| -}
withValidationmessages : String -> Builder { a | validationmessages : Available } slotCaps msg kind -> Builder { a | validationmessages : Used } slotCaps msg kind
withValidationmessages value_ =
    B.withAttribute (A.validationmessages value_)


{-| -}
withValue : String -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (A.value value_)


{-| -}
withYearLabel : String -> Builder { a | yearLabel : Available } slotCaps msg kind -> Builder { a | yearLabel : Used } slotCaps msg kind
withYearLabel value_ =
    B.withAttribute (A.yearLabel value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
withOnBeforeinput : msg -> Builder { a | onBeforeinput : Available } slotCaps msg kind -> Builder { a | onBeforeinput : Used } slotCaps msg kind
withOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
withOnInput : msg -> Builder { a | onInput : Available } slotCaps msg kind -> Builder { a | onInput : Used } slotCaps msg kind
withOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
withOnInvalid : msg -> Builder { a | onInvalid : Available } slotCaps msg kind -> Builder { a | onInvalid : Used } slotCaps msg kind
withOnInvalid value_ =
    B.withAttribute (Ev.onInvalid value_)
