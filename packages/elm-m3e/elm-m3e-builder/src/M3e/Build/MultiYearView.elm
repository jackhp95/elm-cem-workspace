module M3e.Build.MultiYearView exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withActive, withActiveDate, withClass, withDate, withId, withMaxDate, withMinDate, withOnActiveChange, withOnChange, withSlot, withStyle, withToday
    )

{-| The builder module for `m3e-multi-year-view` — seed, pipe, and close.

This module provides everything you need to BUILD with `MultiYearView`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.MultiYearView.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withActive, withActiveDate, withClass, withDate, withId, withMaxDate, withMinDate, withOnActiveChange, withOnChange, withSlot, withStyle, withToday

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.MultiYearView as Component
import M3e.Events as Ev
import M3e.Internal.Types.MultiYearView
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.MultiYearView.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.MultiYearView.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.MultiYearView.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    {}


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.MultiYearView.ChildAdmittedBy childAdm


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-multi-year-view" [] []


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


{-| Pipe form of `active` — consumes its capability (write-once).
-}
withActive : Bool -> Builder { a | active : Available } slotCaps msg kind -> Builder { a | active : Used } slotCaps msg kind
withActive value_ =
    B.withAttribute (A.active value_)


{-| Pipe form of `activeDate` — consumes its capability (write-once).
-}
withActiveDate : String -> Builder { a | activeDate : Available } slotCaps msg kind -> Builder { a | activeDate : Used } slotCaps msg kind
withActiveDate value_ =
    B.withAttribute (A.activeDate value_)


{-| Pipe form of `date` — consumes its capability (write-once).
-}
withDate : String -> Builder { a | date : Available } slotCaps msg kind -> Builder { a | date : Used } slotCaps msg kind
withDate value_ =
    B.withAttribute (A.date value_)


{-| Pipe form of `maxDate` — consumes its capability (write-once).
-}
withMaxDate : String -> Builder { a | maxDate : Available } slotCaps msg kind -> Builder { a | maxDate : Used } slotCaps msg kind
withMaxDate value_ =
    B.withAttribute (A.maxDate value_)


{-| Pipe form of `minDate` — consumes its capability (write-once).
-}
withMinDate : String -> Builder { a | minDate : Available } slotCaps msg kind -> Builder { a | minDate : Used } slotCaps msg kind
withMinDate value_ =
    B.withAttribute (A.minDate value_)


{-| Pipe form of `today` — consumes its capability (write-once).
-}
withToday : String -> Builder { a | today : Available } slotCaps msg kind -> Builder { a | today : Used } slotCaps msg kind
withToday value_ =
    B.withAttribute (A.today value_)


{-| Pipe form of `onChange` — consumes its capability (write-once).
-}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| Pipe form of `onActiveChange` — consumes its capability (write-once).
-}
withOnActiveChange : msg -> Builder { a | onActiveChange : Available } slotCaps msg kind -> Builder { a | onActiveChange : Used } slotCaps msg kind
withOnActiveChange value_ =
    B.withAttribute (Ev.onActiveChange value_)
