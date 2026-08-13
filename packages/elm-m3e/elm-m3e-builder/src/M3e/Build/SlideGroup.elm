module M3e.Build.SlideGroup exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, NextIconSlot, PrevIconSlot, ChildAdmittedBy
    , withClass, withDisabled, withId, withNextPageLabel, withPreviousPageLabel, withSlot, withStyle, withThreshold, withVertical
    , nextIcon, prevIcon
    , withNextIcon, withPrevIcon, withChild
    )

{-| The builder module for `m3e-slide-group` — seed, pipe, and close.

This module provides everything you need to BUILD with `SlideGroup`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.SlideGroup.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, NextIconSlot, PrevIconSlot, ChildAdmittedBy
@docs withClass, withDisabled, withId, withNextPageLabel, withPreviousPageLabel, withSlot, withStyle, withThreshold, withVertical
@docs nextIcon, prevIcon
@docs withNextIcon, withPrevIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.SlideGroup as Component
import M3e.Internal.Types.SlideGroup
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.SlideGroup.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.SlideGroup.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.SlideGroup.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.SlideGroup.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.SlideGroup.ChildAdmittedBy childAdm


{-| The kinds the `next-icon` slot admits.
-}
type alias NextIconSlot =
    M3e.Internal.Types.SlideGroup.NextIconSlot


{-| The kinds the `prev-icon` slot admits.
-}
type alias PrevIconSlot =
    M3e.Internal.Types.SlideGroup.PrevIconSlot


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-slide-group" [] []


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `next-icon` slot — calls `B.toElement` internally.
-}
nextIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.NextIconSlot msg
    -> Element free freeAdmittedBy msg
nextIcon builder =
    Component.nextIcon (B.toElement builder)


{-| Place a builder-built element into the named `prev-icon` slot — calls `B.toElement` internally.
-}
prevIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PrevIconSlot msg
    -> Element free freeAdmittedBy msg
prevIcon builder =
    Component.prevIcon (B.toElement builder)


{-| Pipe form of the `next-icon` slot — accepts a builder directly (no `.toElement`).
-}
withNextIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.NextIconSlot msg
    -> Builder attrCaps { s | nextIcon : Available } msg kind
    -> Builder attrCaps { s | nextIcon : Used } msg kind
withNextIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.nextIcon (B.toElement slotBuilder))) builder_


{-| Pipe form of the `prev-icon` slot — accepts a builder directly (no `.toElement`).
-}
withPrevIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PrevIconSlot msg
    -> Builder attrCaps { s | prevIcon : Available } msg kind
    -> Builder attrCaps { s | prevIcon : Used } msg kind
withPrevIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.prevIcon (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `nextPageLabel` — consumes its capability (write-once).
-}
withNextPageLabel : String -> Builder { a | nextPageLabel : Available } slotCaps msg kind -> Builder { a | nextPageLabel : Used } slotCaps msg kind
withNextPageLabel value_ =
    B.withAttribute (A.nextPageLabel value_)


{-| Pipe form of `previousPageLabel` — consumes its capability (write-once).
-}
withPreviousPageLabel : String -> Builder { a | previousPageLabel : Available } slotCaps msg kind -> Builder { a | previousPageLabel : Used } slotCaps msg kind
withPreviousPageLabel value_ =
    B.withAttribute (A.previousPageLabel value_)


{-| Pipe form of `threshold` — consumes its capability (write-once).
-}
withThreshold : Float -> Builder { a | threshold : Available } slotCaps msg kind -> Builder { a | threshold : Used } slotCaps msg kind
withThreshold value_ =
    B.withAttribute (A.threshold value_)


{-| Pipe form of `vertical` — consumes its capability (write-once).
-}
withVertical : Bool -> Builder { a | vertical : Available } slotCaps msg kind -> Builder { a | vertical : Used } slotCaps msg kind
withVertical value_ =
    B.withAttribute (A.vertical value_)
