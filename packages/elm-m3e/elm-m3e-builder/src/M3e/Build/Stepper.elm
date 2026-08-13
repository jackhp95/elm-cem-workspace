module M3e.Build.Stepper exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, PanelSlot, StepSlot, ChildAdmittedBy
    , withClass, withHeaderPosition, withId, withLabelPosition, withLinear, withOnBeforeinput, withOnChange, withOnInput, withOrientation, withSlot, withStyle
    , panel, step
    , withPanel, withStep
    )

{-| The builder module for `m3e-stepper` — seed, pipe, and close.

This module provides everything you need to BUILD with `Stepper`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.Stepper.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, PanelSlot, StepSlot, ChildAdmittedBy
@docs withClass, withHeaderPosition, withId, withLabelPosition, withLinear, withOnBeforeinput, withOnChange, withOnInput, withOrientation, withSlot, withStyle
@docs panel, step
@docs withPanel, withStep

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Stepper as Component
import M3e.Events as Ev
import M3e.Internal.Types.Stepper
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.Stepper.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Stepper.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.Stepper.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    {}


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Stepper.ChildAdmittedBy childAdm


{-| The kinds the `panel` slot admits.
-}
type alias PanelSlot =
    M3e.Internal.Types.Stepper.PanelSlot


{-| The kinds the `step` slot admits.
-}
type alias StepSlot =
    M3e.Internal.Types.Stepper.StepSlot


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-stepper" [] []


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `panel` slot — calls `B.toElement` internally.
-}
panel :
    B.Builder childRow childAttrCaps childSlotCaps Component.PanelSlot msg
    -> Element free freeAdmittedBy msg
panel builder =
    Component.panel (B.toElement builder)


{-| Place a builder-built element into the named `step` slot — calls `B.toElement` internally.
-}
step :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepSlot msg
    -> Element free freeAdmittedBy msg
step builder =
    Component.step (B.toElement builder)


{-| Pipe form of the `panel` slot (repeatable) — accepts a builder directly.
-}
withPanel :
    B.Builder childRow childAttrCaps childSlotCaps Component.PanelSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withPanel slotBuilder builder_ =
    B.withChild (El.toNode (Component.panel (B.toElement slotBuilder))) builder_


{-| Pipe form of the `step` slot (repeatable) — accepts a builder directly.
-}
withStep :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withStep slotBuilder builder_ =
    B.withChild (El.toNode (Component.step (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `headerPosition` — consumes its capability (write-once).
-}
withHeaderPosition : Value Component.HeaderPosition -> Builder { a | headerPosition : Available } slotCaps msg kind -> Builder { a | headerPosition : Used } slotCaps msg kind
withHeaderPosition value_ =
    B.withAttribute (Component.headerPosition value_)


{-| Pipe form of `labelPosition` — consumes its capability (write-once).
-}
withLabelPosition : Value Component.LabelPosition -> Builder { a | labelPosition : Available } slotCaps msg kind -> Builder { a | labelPosition : Used } slotCaps msg kind
withLabelPosition value_ =
    B.withAttribute (Component.labelPosition value_)


{-| Pipe form of `linear` — consumes its capability (write-once).
-}
withLinear : Bool -> Builder { a | linear : Available } slotCaps msg kind -> Builder { a | linear : Used } slotCaps msg kind
withLinear value_ =
    B.withAttribute (A.linear value_)


{-| Pipe form of `orientation` — consumes its capability (write-once).
-}
withOrientation : Value Component.Orientation -> Builder { a | orientation : Available } slotCaps msg kind -> Builder { a | orientation : Used } slotCaps msg kind
withOrientation value_ =
    B.withAttribute (Component.orientation value_)


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
