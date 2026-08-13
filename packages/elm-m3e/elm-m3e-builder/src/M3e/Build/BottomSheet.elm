module M3e.Build.BottomSheet exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withDetent, withDetents, withHandle, withHandleLabel, withHideFriction, withHideable, withId, withModal, withOnCancel, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withOvershootLimit, withSlot, withStyle
    , header
    , withHeader, withChild
    )

{-| The builder module for `m3e-bottom-sheet` — seed, pipe, and close.

This module provides everything you need to BUILD with `BottomSheet`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.BottomSheet.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withDetent, withDetents, withHandle, withHandleLabel, withHideFriction, withHideable, withId, withModal, withOnCancel, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withOvershootLimit, withSlot, withStyle
@docs header
@docs withHeader, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.BottomSheet as Component
import M3e.Events as Ev
import M3e.Internal.Types.BottomSheet
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.BottomSheet.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.BottomSheet.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.BottomSheet.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.BottomSheet.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.BottomSheet.ChildAdmittedBy childAdm


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-bottom-sheet" [] []


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `header` slot — calls `B.toElement` internally.
-}
header :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
header builder =
    Component.header (B.toElement builder)


{-| Pipe form of the `header` slot — accepts a builder directly (no `.toElement`).
-}
withHeader :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | header : Available } msg kind
    -> Builder attrCaps { s | header : Used } msg kind
withHeader slotBuilder builder_ =
    B.withChild (El.toNode (Component.header (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `detent` — consumes its capability (write-once).
-}
withDetent : Float -> Builder { a | detent : Available } slotCaps msg kind -> Builder { a | detent : Used } slotCaps msg kind
withDetent value_ =
    B.withAttribute (A.detent value_)


{-| Pipe form of `detents` — consumes its capability (write-once).
-}
withDetents : String -> Builder { a | detents : Available } slotCaps msg kind -> Builder { a | detents : Used } slotCaps msg kind
withDetents value_ =
    B.withAttribute (A.detents value_)


{-| Pipe form of `handle` — consumes its capability (write-once).
-}
withHandle : Bool -> Builder { a | handle : Available } slotCaps msg kind -> Builder { a | handle : Used } slotCaps msg kind
withHandle value_ =
    B.withAttribute (A.handle value_)


{-| Pipe form of `handleLabel` — consumes its capability (write-once).
-}
withHandleLabel : String -> Builder { a | handleLabel : Available } slotCaps msg kind -> Builder { a | handleLabel : Used } slotCaps msg kind
withHandleLabel value_ =
    B.withAttribute (A.handleLabel value_)


{-| Pipe form of `hideFriction` — consumes its capability (write-once).
-}
withHideFriction : Float -> Builder { a | hideFriction : Available } slotCaps msg kind -> Builder { a | hideFriction : Used } slotCaps msg kind
withHideFriction value_ =
    B.withAttribute (A.hideFriction value_)


{-| Pipe form of `hideable` — consumes its capability (write-once).
-}
withHideable : Bool -> Builder { a | hideable : Available } slotCaps msg kind -> Builder { a | hideable : Used } slotCaps msg kind
withHideable value_ =
    B.withAttribute (A.hideable value_)


{-| Pipe form of `modal` — consumes its capability (write-once).
-}
withModal : Bool -> Builder { a | modal : Available } slotCaps msg kind -> Builder { a | modal : Used } slotCaps msg kind
withModal value_ =
    B.withAttribute (A.modal value_)


{-| Pipe form of `open` — consumes its capability (write-once).
-}
withOpen : Bool -> Builder { a | open : Available } slotCaps msg kind -> Builder { a | open : Used } slotCaps msg kind
withOpen value_ =
    B.withAttribute (A.open value_)


{-| Pipe form of `overshootLimit` — consumes its capability (write-once).
-}
withOvershootLimit : Float -> Builder { a | overshootLimit : Available } slotCaps msg kind -> Builder { a | overshootLimit : Used } slotCaps msg kind
withOvershootLimit value_ =
    B.withAttribute (A.overshootLimit value_)


{-| Pipe form of `onOpening` — consumes its capability (write-once).
-}
withOnOpening : msg -> Builder { a | onOpening : Available } slotCaps msg kind -> Builder { a | onOpening : Used } slotCaps msg kind
withOnOpening value_ =
    B.withAttribute (Ev.onOpening value_)


{-| Pipe form of `onClosing` — consumes its capability (write-once).
-}
withOnClosing : msg -> Builder { a | onClosing : Available } slotCaps msg kind -> Builder { a | onClosing : Used } slotCaps msg kind
withOnClosing value_ =
    B.withAttribute (Ev.onClosing value_)


{-| Pipe form of `onCancel` — consumes its capability (write-once).
-}
withOnCancel : msg -> Builder { a | onCancel : Available } slotCaps msg kind -> Builder { a | onCancel : Used } slotCaps msg kind
withOnCancel value_ =
    B.withAttribute (Ev.onCancel value_)


{-| Pipe form of `onOpened` — consumes its capability (write-once).
-}
withOnOpened : msg -> Builder { a | onOpened : Available } slotCaps msg kind -> Builder { a | onOpened : Used } slotCaps msg kind
withOnOpened value_ =
    B.withAttribute (Ev.onOpened value_)


{-| Pipe form of `onClosed` — consumes its capability (write-once).
-}
withOnClosed : msg -> Builder { a | onClosed : Available } slotCaps msg kind -> Builder { a | onClosed : Used } slotCaps msg kind
withOnClosed value_ =
    B.withAttribute (Ev.onClosed value_)
