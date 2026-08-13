module M3e.Build.RichTooltip exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, SubheadSlot, ChildAdmittedBy
    , withClass, withDisabled, withFor, withHideDelay, withId, withOnBeforetoggle, withOnToggle, withPosition, withShowDelay, withSlot, withStyle, withTouchGestures
    , actions, subhead
    , withActions, withSubhead, withChild
    )

{-| The builder module for `m3e-rich-tooltip` — seed, pipe, and close.

This module provides everything you need to BUILD with `RichTooltip`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.RichTooltip.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, SubheadSlot, ChildAdmittedBy
@docs withClass, withDisabled, withFor, withHideDelay, withId, withOnBeforetoggle, withOnToggle, withPosition, withShowDelay, withSlot, withStyle, withTouchGestures
@docs actions, subhead
@docs withActions, withSubhead, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.RichTooltip as Component
import M3e.Events as Ev
import M3e.Internal.Types.RichTooltip
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.RichTooltip.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.RichTooltip.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.RichTooltip.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.RichTooltip.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.RichTooltip.ChildAdmittedBy childAdm


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.RichTooltip.Content


{-| The kinds the `subhead` slot admits.
-}
type alias SubheadSlot =
    M3e.Internal.Types.RichTooltip.SubheadSlot


{-| Seed the pipe-builder with required content (and action).
-}
build :
    { content : Element Component.Content (Component.ChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-rich-tooltip" [] [ El.toNode required_.content ]


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `actions` slot — calls `B.toElement` internally.
-}
actions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
actions builder =
    Component.actions (B.toElement builder)


{-| Place a builder-built element into the named `subhead` slot — calls `B.toElement` internally.
-}
subhead :
    B.Builder childRow childAttrCaps childSlotCaps Component.SubheadSlot msg
    -> Element free freeAdmittedBy msg
subhead builder =
    Component.subhead (B.toElement builder)


{-| Pipe form of the `actions` slot — accepts a builder directly (no `.toElement`).
-}
withActions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | actions : Available } msg kind
    -> Builder attrCaps { s | actions : Used } msg kind
withActions slotBuilder builder_ =
    B.withChild (El.toNode (Component.actions (B.toElement slotBuilder))) builder_


{-| Pipe form of the `subhead` slot — accepts a builder directly (no `.toElement`).
-}
withSubhead :
    B.Builder childRow childAttrCaps childSlotCaps Component.SubheadSlot msg
    -> Builder attrCaps { s | subhead : Available } msg kind
    -> Builder attrCaps { s | subhead : Used } msg kind
withSubhead slotBuilder builder_ =
    B.withChild (El.toNode (Component.subhead (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `for` — consumes its capability (write-once).
-}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| Pipe form of `hideDelay` — consumes its capability (write-once).
-}
withHideDelay : Float -> Builder { a | hideDelay : Available } slotCaps msg kind -> Builder { a | hideDelay : Used } slotCaps msg kind
withHideDelay value_ =
    B.withAttribute (A.hideDelay value_)


{-| Pipe form of `position` — consumes its capability (write-once).
-}
withPosition : Value Component.Position -> Builder { a | position : Available } slotCaps msg kind -> Builder { a | position : Used } slotCaps msg kind
withPosition value_ =
    B.withAttribute (Component.position value_)


{-| Pipe form of `showDelay` — consumes its capability (write-once).
-}
withShowDelay : Float -> Builder { a | showDelay : Available } slotCaps msg kind -> Builder { a | showDelay : Used } slotCaps msg kind
withShowDelay value_ =
    B.withAttribute (A.showDelay value_)


{-| Pipe form of `touchGestures` — consumes its capability (write-once).
-}
withTouchGestures : Value Component.TouchGestures -> Builder { a | touchGestures : Available } slotCaps msg kind -> Builder { a | touchGestures : Used } slotCaps msg kind
withTouchGestures value_ =
    B.withAttribute (Component.touchGestures value_)


{-| Pipe form of `onBeforetoggle` — consumes its capability (write-once).
-}
withOnBeforetoggle : msg -> Builder { a | onBeforetoggle : Available } slotCaps msg kind -> Builder { a | onBeforetoggle : Used } slotCaps msg kind
withOnBeforetoggle value_ =
    B.withAttribute (Ev.onBeforetoggle value_)


{-| Pipe form of `onToggle` — consumes its capability (write-once).
-}
withOnToggle : msg -> Builder { a | onToggle : Available } slotCaps msg kind -> Builder { a | onToggle : Used } slotCaps msg kind
withOnToggle value_ =
    B.withAttribute (Ev.onToggle value_)
