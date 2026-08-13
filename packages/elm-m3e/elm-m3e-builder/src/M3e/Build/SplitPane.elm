module M3e.Build.SplitPane exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withDetents, withDisabled, withId, withLabel, withMax, withMin, withName, withOnBeforeinput, withOnChange, withOnInput, withOrientation, withOvershootLimit, withSlot, withStep, withStyle, withValue, withWrapDetents
    , end, start
    , withEnd, withStart
    )

{-| The builder module for `m3e-split-pane` — seed, pipe, and close.

This module provides everything you need to BUILD with `SplitPane`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.SplitPane.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withDetents, withDisabled, withId, withLabel, withMax, withMin, withName, withOnBeforeinput, withOnChange, withOnInput, withOrientation, withOvershootLimit, withSlot, withStep, withStyle, withValue, withWrapDetents
@docs end, start
@docs withEnd, withStart

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.SplitPane as Component
import M3e.Events as Ev
import M3e.Internal.Types.SplitPane
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.SplitPane.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.SplitPane.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.SplitPane.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.SplitPane.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.SplitPane.ChildAdmittedBy childAdm


{-| Seed the pipe-builder with required content (and action).
-}
build :
    { end : Element childAccepts (Component.ChildAdmittedBy childAdm) msg
    , start : Element childAccepts (Component.ChildAdmittedBy childAdm) msg
    }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-split-pane" [] [ El.toNode (Component.end required_.end), El.toNode (Component.start required_.start) ]


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `end` slot — calls `B.toElement` internally.
-}
end :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
end builder =
    Component.end (B.toElement builder)


{-| Place a builder-built element into the named `start` slot — calls `B.toElement` internally.
-}
start :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
start builder =
    Component.start (B.toElement builder)


{-| Pipe form of the `end` slot — accepts a builder directly (no `.toElement`).
-}
withEnd :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | end : Available } msg kind
    -> Builder attrCaps { s | end : Used } msg kind
withEnd slotBuilder builder_ =
    B.withChild (El.toNode (Component.end (B.toElement slotBuilder))) builder_


{-| Pipe form of the `start` slot — accepts a builder directly (no `.toElement`).
-}
withStart :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | start : Available } msg kind
    -> Builder attrCaps { s | start : Used } msg kind
withStart slotBuilder builder_ =
    B.withChild (El.toNode (Component.start (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `detents` — consumes its capability (write-once).
-}
withDetents : String -> Builder { a | detents : Available } slotCaps msg kind -> Builder { a | detents : Used } slotCaps msg kind
withDetents value_ =
    B.withAttribute (A.detents value_)


{-| Pipe form of `disabled` — consumes its capability (write-once).
-}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| Pipe form of `label` — consumes its capability (write-once).
-}
withLabel : String -> Builder { a | label : Available } slotCaps msg kind -> Builder { a | label : Used } slotCaps msg kind
withLabel value_ =
    B.withAttribute (A.label value_)


{-| Pipe form of `max` — consumes its capability (write-once).
-}
withMax : Float -> Builder { a | max : Available } slotCaps msg kind -> Builder { a | max : Used } slotCaps msg kind
withMax value_ =
    B.withAttribute (A.max value_)


{-| Pipe form of `min` — consumes its capability (write-once).
-}
withMin : Float -> Builder { a | min : Available } slotCaps msg kind -> Builder { a | min : Used } slotCaps msg kind
withMin value_ =
    B.withAttribute (A.min value_)


{-| Pipe form of `name` — consumes its capability (write-once).
-}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (Ir.attribute "name" value_)


{-| Pipe form of `orientation` — consumes its capability (write-once).
-}
withOrientation : Value Component.Orientation -> Builder { a | orientation : Available } slotCaps msg kind -> Builder { a | orientation : Used } slotCaps msg kind
withOrientation value_ =
    B.withAttribute (Component.orientation value_)


{-| Pipe form of `overshootLimit` — consumes its capability (write-once).
-}
withOvershootLimit : Float -> Builder { a | overshootLimit : Available } slotCaps msg kind -> Builder { a | overshootLimit : Used } slotCaps msg kind
withOvershootLimit value_ =
    B.withAttribute (A.overshootLimit value_)


{-| Pipe form of `step` — consumes its capability (write-once).
-}
withStep : Float -> Builder { a | step : Available } slotCaps msg kind -> Builder { a | step : Used } slotCaps msg kind
withStep value_ =
    B.withAttribute (A.step value_)


{-| Pipe form of `value` — consumes its capability (write-once).
-}
withValue : Float -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (Ir.property "value" (Json.Encode.float value_))


{-| Pipe form of `wrapDetents` — consumes its capability (write-once).
-}
withWrapDetents : Bool -> Builder { a | wrapDetents : Available } slotCaps msg kind -> Builder { a | wrapDetents : Used } slotCaps msg kind
withWrapDetents value_ =
    B.withAttribute (A.wrapDetents value_)


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
