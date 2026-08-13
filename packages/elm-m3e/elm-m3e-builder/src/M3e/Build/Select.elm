module M3e.Build.Select exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, ArrowSlot, ChildAdmittedBy
    , withClass, withDisabled, withHideSelectionIndicator, withId, withMulti, withName, withOnBeforeinput, withOnChange, withOnInput, withOnToggle, withPanelClass, withRequired, withSlot, withStyle, withValidationmessages
    , arrow, value
    , withArrow, withValue, withChild
    )

{-| The builder module for `m3e-select` — seed, pipe, and close.

This module provides everything you need to BUILD with `Select`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.Select.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, ArrowSlot, ChildAdmittedBy
@docs withClass, withDisabled, withHideSelectionIndicator, withId, withMulti, withName, withOnBeforeinput, withOnChange, withOnInput, withOnToggle, withPanelClass, withRequired, withSlot, withStyle, withValidationmessages
@docs arrow, value
@docs withArrow, withValue, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import Json.Encode
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Select as Component
import M3e.Events as Ev
import M3e.Internal.Types.Select
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.Select.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Select.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.Select.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.Select.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Select.ChildAdmittedBy childAdm


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Select.Content


{-| The kinds the `arrow` slot admits.
-}
type alias ArrowSlot =
    M3e.Internal.Types.Select.ArrowSlot


{-| Seed the pipe-builder with required content (and action).
-}
build :
    { content : Element Component.Content (Component.ChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-select" [] [ El.toNode required_.content ]


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `arrow` slot — calls `B.toElement` internally.
-}
arrow :
    B.Builder childRow childAttrCaps childSlotCaps Component.ArrowSlot msg
    -> Element free freeAdmittedBy msg
arrow builder =
    Component.arrow (B.toElement builder)


{-| Place a builder-built element into the named `value` slot — calls `B.toElement` internally.
-}
value :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
value builder =
    Component.value (B.toElement builder)


{-| Pipe form of the `arrow` slot — accepts a builder directly (no `.toElement`).
-}
withArrow :
    B.Builder childRow childAttrCaps childSlotCaps Component.ArrowSlot msg
    -> Builder attrCaps { s | arrow : Available } msg kind
    -> Builder attrCaps { s | arrow : Used } msg kind
withArrow slotBuilder builder_ =
    B.withChild (El.toNode (Component.arrow (B.toElement slotBuilder))) builder_


{-| Pipe form of the `value` slot — accepts a builder directly (no `.toElement`).
-}
withValue :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | value : Available } msg kind
    -> Builder attrCaps { s | value : Used } msg kind
withValue slotBuilder builder_ =
    B.withChild (El.toNode (Component.value (B.toElement slotBuilder))) builder_


{-| Pipe form of a default-slot child (repeatable) — accepts a builder directly.
-}
withChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


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


{-| Pipe form of `disabled` — consumes its capability (write-once).
-}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| Pipe form of `hideSelectionIndicator` — consumes its capability (write-once).
-}
withHideSelectionIndicator : Bool -> Builder { a | hideSelectionIndicator : Available } slotCaps msg kind -> Builder { a | hideSelectionIndicator : Used } slotCaps msg kind
withHideSelectionIndicator value_ =
    B.withAttribute (A.hideSelectionIndicator value_)


{-| Pipe form of `multi` — consumes its capability (write-once).
-}
withMulti : Bool -> Builder { a | multi : Available } slotCaps msg kind -> Builder { a | multi : Used } slotCaps msg kind
withMulti value_ =
    B.withAttribute (A.multi value_)


{-| Pipe form of `name` — consumes its capability (write-once).
-}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (Ir.attribute "name" value_)


{-| Pipe form of `panelClass` — consumes its capability (write-once).
-}
withPanelClass : String -> Builder { a | panelClass : Available } slotCaps msg kind -> Builder { a | panelClass : Used } slotCaps msg kind
withPanelClass value_ =
    B.withAttribute (A.panelClass value_)


{-| Pipe form of `required` — consumes its capability (write-once).
-}
withRequired : Bool -> Builder { a | required : Available } slotCaps msg kind -> Builder { a | required : Used } slotCaps msg kind
withRequired value_ =
    B.withAttribute (A.required value_)


{-| Pipe form of `validationmessages` — consumes its capability (write-once).
-}
withValidationmessages : String -> Builder { a | validationmessages : Available } slotCaps msg kind -> Builder { a | validationmessages : Used } slotCaps msg kind
withValidationmessages value_ =
    B.withAttribute (A.validationmessages value_)


{-| Pipe form of `onChange` — consumes its capability (write-once).
-}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| Pipe form of `onToggle` — consumes its capability (write-once).
-}
withOnToggle : (String -> msg) -> Builder { a | onToggle : Available } slotCaps msg kind -> Builder { a | onToggle : Used } slotCaps msg kind
withOnToggle value_ =
    B.withAttribute (Component.onToggle value_)


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
