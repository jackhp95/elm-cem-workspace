module M3e.Build.TimepickerDial exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withFormat, withHour, withId, withMaxTime, withMinTime, withMinute, withOnChange, withOnInput, withOnViewChange, withPeriod, withSecond, withShowSeconds, withSlot, withStyle, withViewAttr
    )

{-| The builder module for `m3e-timepicker-dial` — seed, pipe, and close.

This module provides everything you need to BUILD with `TimepickerDial`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.TimepickerDial.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withFormat, withHour, withId, withMaxTime, withMinTime, withMinute, withOnChange, withOnInput, withOnViewChange, withPeriod, withSecond, withShowSeconds, withSlot, withStyle, withViewAttr

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.TimepickerDial as Component
import M3e.Events as Ev
import M3e.Internal.Types.TimepickerDial
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.TimepickerDial.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.TimepickerDial.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.TimepickerDial.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    {}


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.TimepickerDial.ChildAdmittedBy childAdm


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-timepicker-dial" [] []


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


{-| Pipe form of `format` — consumes its capability (write-once).
-}
withFormat : Value Component.Format -> Builder { a | format : Available } slotCaps msg kind -> Builder { a | format : Used } slotCaps msg kind
withFormat value_ =
    B.withAttribute (Component.format value_)


{-| Pipe form of `hour` — consumes its capability (write-once).
-}
withHour : Float -> Builder { a | hour : Available } slotCaps msg kind -> Builder { a | hour : Used } slotCaps msg kind
withHour value_ =
    B.withAttribute (A.hour value_)


{-| Pipe form of `maxTime` — consumes its capability (write-once).
-}
withMaxTime : String -> Builder { a | maxTime : Available } slotCaps msg kind -> Builder { a | maxTime : Used } slotCaps msg kind
withMaxTime value_ =
    B.withAttribute (A.maxTime value_)


{-| Pipe form of `minTime` — consumes its capability (write-once).
-}
withMinTime : String -> Builder { a | minTime : Available } slotCaps msg kind -> Builder { a | minTime : Used } slotCaps msg kind
withMinTime value_ =
    B.withAttribute (A.minTime value_)


{-| Pipe form of `minute` — consumes its capability (write-once).
-}
withMinute : Float -> Builder { a | minute : Available } slotCaps msg kind -> Builder { a | minute : Used } slotCaps msg kind
withMinute value_ =
    B.withAttribute (A.minute value_)


{-| Pipe form of `period` — consumes its capability (write-once).
-}
withPeriod : Value Component.Period -> Builder { a | period : Available } slotCaps msg kind -> Builder { a | period : Used } slotCaps msg kind
withPeriod value_ =
    B.withAttribute (Component.period value_)


{-| Pipe form of `second` — consumes its capability (write-once).
-}
withSecond : Float -> Builder { a | second : Available } slotCaps msg kind -> Builder { a | second : Used } slotCaps msg kind
withSecond value_ =
    B.withAttribute (A.second value_)


{-| Pipe form of `showSeconds` — consumes its capability (write-once).
-}
withShowSeconds : Bool -> Builder { a | showSeconds : Available } slotCaps msg kind -> Builder { a | showSeconds : Used } slotCaps msg kind
withShowSeconds value_ =
    B.withAttribute (A.showSeconds value_)


{-| Pipe form of `viewAttr` — consumes its capability (write-once).
-}
withViewAttr : Value Component.ViewAttr -> Builder { a | viewAttr : Available } slotCaps msg kind -> Builder { a | viewAttr : Used } slotCaps msg kind
withViewAttr value_ =
    B.withAttribute (Component.viewAttr value_)


{-| Pipe form of `onInput` — consumes its capability (write-once).
-}
withOnInput : msg -> Builder { a | onInput : Available } slotCaps msg kind -> Builder { a | onInput : Used } slotCaps msg kind
withOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| Pipe form of `onChange` — consumes its capability (write-once).
-}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| Pipe form of `onViewChange` — consumes its capability (write-once).
-}
withOnViewChange : msg -> Builder { a | onViewChange : Available } slotCaps msg kind -> Builder { a | onViewChange : Used } slotCaps msg kind
withOnViewChange value_ =
    B.withAttribute (Ev.onViewChange value_)
