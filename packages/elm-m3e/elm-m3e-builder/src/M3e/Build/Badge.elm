module M3e.Build.Badge exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
    , withClass, withFor, withId, withPosition, withSize, withSlot, withStyle
    , withChild
    )

{-| The builder module for `m3e-badge` — seed, pipe, and close.

This module provides everything you need to BUILD with `Badge`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.Badge.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
@docs withClass, withFor, withId, withPosition, withSize, withSlot, withStyle
@docs withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Badge as Component
import M3e.Internal.Types.Badge
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.Badge.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Badge.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.Badge.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    {}


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Badge.ChildAdmittedBy childAdm


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Badge.Content


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-badge" [] []


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


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


{-| Pipe form of `for` — consumes its capability (write-once).
-}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| Pipe form of `position` — consumes its capability (write-once).
-}
withPosition : Value Component.Position -> Builder { a | position : Available } slotCaps msg kind -> Builder { a | position : Used } slotCaps msg kind
withPosition value_ =
    B.withAttribute (Component.position value_)


{-| Pipe form of `size` — consumes its capability (write-once).
-}
withSize : Value Component.Size -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.size value_)
