module M3e.Build.DateInput exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withDayLabel, withDisabled, withHourLabel, withId, withMaxDate, withMaxTime, withMinDate, withMinTime, withMinuteLabel, withMonthLabel, withName, withOnBeforeinput, withOnChange, withOnInput, withOnInvalid, withPeriodLabel, withReadonly, withRequired, withSecondLabel, withShowSeconds, withSlot, withStyle, withTimeFormat, withType, withValidationmessages, withValue, withYearLabel
    )

{-| The builder module for `m3e-date-input` — seed, pipe, and close.

This module provides everything you need to BUILD with `DateInput`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.DateInput.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withDayLabel, withDisabled, withHourLabel, withId, withMaxDate, withMaxTime, withMinDate, withMinTime, withMinuteLabel, withMonthLabel, withName, withOnBeforeinput, withOnChange, withOnInput, withOnInvalid, withPeriodLabel, withReadonly, withRequired, withSecondLabel, withShowSeconds, withSlot, withStyle, withTimeFormat, withType, withValidationmessages, withValue, withYearLabel

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.DateInput as Component
import M3e.Events as Ev
import M3e.Internal.Types.DateInput
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.DateInput.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.DateInput.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.DateInput.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    {}


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.DateInput.ChildAdmittedBy childAdm


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-date-input" [] []


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Pipe form of `class` — consumes its capability (write-once).
-}
withClass : String -> Builder { a | class : Available } slotCaps msg kind -> Builder { a | class : Used } slotCaps msg kind
withClass value_ =
    B.withAttribute (A.class value_)


{-| Pipe form of `id` — consumes its capability (write-once).
-}
withId : String -> Builder { a | id : Available } slotCaps msg kind -> Builder { a | id : Used } slotCaps msg kind
withId value_ =
    B.withAttribute (A.id value_)


{-| Pipe form of `slot` — consumes its capability (write-once).
-}
withSlot : String -> Builder { a | slot : Available } slotCaps msg kind -> Builder { a | slot : Used } slotCaps msg kind
withSlot value_ =
    B.withAttribute (A.slot value_)


{-| Pipe form of `style` — consumes its capability (write-once).
-}
withStyle : String -> String -> Builder { a | style : Available } slotCaps msg kind -> Builder { a | style : Used } slotCaps msg kind
withStyle property value_ =
    B.withAttribute (A.style property value_)


{-| Pipe form of `dayLabel` — consumes its capability (write-once).
-}
withDayLabel : String -> Builder { a | dayLabel : Available } slotCaps msg kind -> Builder { a | dayLabel : Used } slotCaps msg kind
withDayLabel value_ =
    B.withAttribute (A.dayLabel value_)


{-| Pipe form of `disabled` — consumes its capability (write-once).
-}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| Pipe form of `hourLabel` — consumes its capability (write-once).
-}
withHourLabel : String -> Builder { a | hourLabel : Available } slotCaps msg kind -> Builder { a | hourLabel : Used } slotCaps msg kind
withHourLabel value_ =
    B.withAttribute (A.hourLabel value_)


{-| Pipe form of `maxDate` — consumes its capability (write-once).
-}
withMaxDate : String -> Builder { a | maxDate : Available } slotCaps msg kind -> Builder { a | maxDate : Used } slotCaps msg kind
withMaxDate value_ =
    B.withAttribute (A.maxDate value_)


{-| Pipe form of `maxTime` — consumes its capability (write-once).
-}
withMaxTime : String -> Builder { a | maxTime : Available } slotCaps msg kind -> Builder { a | maxTime : Used } slotCaps msg kind
withMaxTime value_ =
    B.withAttribute (A.maxTime value_)


{-| Pipe form of `minDate` — consumes its capability (write-once).
-}
withMinDate : String -> Builder { a | minDate : Available } slotCaps msg kind -> Builder { a | minDate : Used } slotCaps msg kind
withMinDate value_ =
    B.withAttribute (A.minDate value_)


{-| Pipe form of `minTime` — consumes its capability (write-once).
-}
withMinTime : String -> Builder { a | minTime : Available } slotCaps msg kind -> Builder { a | minTime : Used } slotCaps msg kind
withMinTime value_ =
    B.withAttribute (A.minTime value_)


{-| Pipe form of `minuteLabel` — consumes its capability (write-once).
-}
withMinuteLabel : String -> Builder { a | minuteLabel : Available } slotCaps msg kind -> Builder { a | minuteLabel : Used } slotCaps msg kind
withMinuteLabel value_ =
    B.withAttribute (A.minuteLabel value_)


{-| Pipe form of `monthLabel` — consumes its capability (write-once).
-}
withMonthLabel : String -> Builder { a | monthLabel : Available } slotCaps msg kind -> Builder { a | monthLabel : Used } slotCaps msg kind
withMonthLabel value_ =
    B.withAttribute (A.monthLabel value_)


{-| Pipe form of `name` — consumes its capability (write-once).
-}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (Ir.attribute "name" value_)


{-| Pipe form of `periodLabel` — consumes its capability (write-once).
-}
withPeriodLabel : String -> Builder { a | periodLabel : Available } slotCaps msg kind -> Builder { a | periodLabel : Used } slotCaps msg kind
withPeriodLabel value_ =
    B.withAttribute (A.periodLabel value_)


{-| Pipe form of `readonly` — consumes its capability (write-once).
-}
withReadonly : Bool -> Builder { a | readonly : Available } slotCaps msg kind -> Builder { a | readonly : Used } slotCaps msg kind
withReadonly value_ =
    B.withAttribute (A.readonly value_)


{-| Pipe form of `required` — consumes its capability (write-once).
-}
withRequired : Bool -> Builder { a | required : Available } slotCaps msg kind -> Builder { a | required : Used } slotCaps msg kind
withRequired value_ =
    B.withAttribute (A.required value_)


{-| Pipe form of `secondLabel` — consumes its capability (write-once).
-}
withSecondLabel : String -> Builder { a | secondLabel : Available } slotCaps msg kind -> Builder { a | secondLabel : Used } slotCaps msg kind
withSecondLabel value_ =
    B.withAttribute (A.secondLabel value_)


{-| Pipe form of `showSeconds` — consumes its capability (write-once).
-}
withShowSeconds : Bool -> Builder { a | showSeconds : Available } slotCaps msg kind -> Builder { a | showSeconds : Used } slotCaps msg kind
withShowSeconds value_ =
    B.withAttribute (A.showSeconds value_)


{-| Pipe form of `timeFormat` — consumes its capability (write-once).
-}
withTimeFormat : Value Component.TimeFormat -> Builder { a | timeFormat : Available } slotCaps msg kind -> Builder { a | timeFormat : Used } slotCaps msg kind
withTimeFormat value_ =
    B.withAttribute (Component.timeFormat value_)


{-| Pipe form of `type_` — consumes its capability (write-once).
-}
withType : Value Component.Type -> Builder { a | type_ : Available } slotCaps msg kind -> Builder { a | type_ : Used } slotCaps msg kind
withType value_ =
    B.withAttribute (Component.type_ value_)


{-| Pipe form of `validationmessages` — consumes its capability (write-once).
-}
withValidationmessages : String -> Builder { a | validationmessages : Available } slotCaps msg kind -> Builder { a | validationmessages : Used } slotCaps msg kind
withValidationmessages value_ =
    B.withAttribute (A.validationmessages value_)


{-| Pipe form of `value` — consumes its capability (write-once).
-}
withValue : String -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (A.value value_)


{-| Pipe form of `yearLabel` — consumes its capability (write-once).
-}
withYearLabel : String -> Builder { a | yearLabel : Available } slotCaps msg kind -> Builder { a | yearLabel : Used } slotCaps msg kind
withYearLabel value_ =
    B.withAttribute (A.yearLabel value_)


{-| Pipe form of `onChange` — consumes its capability (write-once).
-}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| Pipe form of `onBeforeinput` — consumes its capability (write-once).
-}
withOnBeforeinput : msg -> Builder { a | onBeforeinput : Available } slotCaps msg kind -> Builder { a | onBeforeinput : Used } slotCaps msg kind
withOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| Pipe form of `onInput` — consumes its capability (write-once).
-}
withOnInput : msg -> Builder { a | onInput : Available } slotCaps msg kind -> Builder { a | onInput : Used } slotCaps msg kind
withOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| Pipe form of `onInvalid` — consumes its capability (write-once).
-}
withOnInvalid : msg -> Builder { a | onInvalid : Available } slotCaps msg kind -> Builder { a | onInvalid : Used } slotCaps msg kind
withOnInvalid value_ =
    B.withAttribute (Ev.onInvalid value_)
