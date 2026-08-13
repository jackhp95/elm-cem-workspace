module M3e.Build.Divider exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withId, withInset, withInsetEnd, withInsetStart, withSlot, withStyle, withVertical
    )

{-| The builder module for `m3e-divider` — seed, pipe, and close.

This module provides everything you need to BUILD with `Divider`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.Divider.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withId, withInset, withInsetEnd, withInsetStart, withSlot, withStyle, withVertical

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Divider as Component
import M3e.Internal.Types.Divider
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.Divider.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Divider.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.Divider.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    {}


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Divider.ChildAdmittedBy childAdm


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-divider" [] []


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


{-| Pipe form of `inset` — consumes its capability (write-once).
-}
withInset : Bool -> Builder { a | inset : Available } slotCaps msg kind -> Builder { a | inset : Used } slotCaps msg kind
withInset value_ =
    B.withAttribute (A.inset value_)


{-| Pipe form of `insetEnd` — consumes its capability (write-once).
-}
withInsetEnd : Bool -> Builder { a | insetEnd : Available } slotCaps msg kind -> Builder { a | insetEnd : Used } slotCaps msg kind
withInsetEnd value_ =
    B.withAttribute (A.insetEnd value_)


{-| Pipe form of `insetStart` — consumes its capability (write-once).
-}
withInsetStart : Bool -> Builder { a | insetStart : Available } slotCaps msg kind -> Builder { a | insetStart : Used } slotCaps msg kind
withInsetStart value_ =
    B.withAttribute (A.insetStart value_)


{-| Pipe form of `vertical` — consumes its capability (write-once).
-}
withVertical : Bool -> Builder { a | vertical : Available } slotCaps msg kind -> Builder { a | vertical : Used } slotCaps msg kind
withVertical value_ =
    B.withAttribute (A.vertical value_)
