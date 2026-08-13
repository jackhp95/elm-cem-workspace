module M3e.Build.Toc exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, OverlineSlot, TitleSlot, ChildAdmittedBy
    , withClass, withFor, withId, withMaxDepth, withSlot, withStyle
    , overline, title
    , withOverline, withTitle, withChild
    )

{-| The builder module for `m3e-toc` — seed, pipe, and close.

This module provides everything you need to BUILD with `Toc`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.Toc.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, OverlineSlot, TitleSlot, ChildAdmittedBy
@docs withClass, withFor, withId, withMaxDepth, withSlot, withStyle
@docs overline, title
@docs withOverline, withTitle, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Toc as Component
import M3e.Internal.Types.Toc
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.Toc.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Toc.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.Toc.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.Toc.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Toc.ChildAdmittedBy childAdm


{-| The kinds the `overline` slot admits.
-}
type alias OverlineSlot =
    M3e.Internal.Types.Toc.OverlineSlot


{-| The kinds the `title` slot admits.
-}
type alias TitleSlot =
    M3e.Internal.Types.Toc.TitleSlot


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-toc" [] []


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `overline` slot — calls `B.toElement` internally.
-}
overline :
    B.Builder childRow childAttrCaps childSlotCaps Component.OverlineSlot msg
    -> Element free freeAdmittedBy msg
overline builder =
    Component.overline (B.toElement builder)


{-| Place a builder-built element into the named `title` slot — calls `B.toElement` internally.
-}
title :
    B.Builder childRow childAttrCaps childSlotCaps Component.TitleSlot msg
    -> Element free freeAdmittedBy msg
title builder =
    Component.title (B.toElement builder)


{-| Pipe form of the `overline` slot — accepts a builder directly (no `.toElement`).
-}
withOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.OverlineSlot msg
    -> Builder attrCaps { s | overline : Available } msg kind
    -> Builder attrCaps { s | overline : Used } msg kind
withOverline slotBuilder builder_ =
    B.withChild (El.toNode (Component.overline (B.toElement slotBuilder))) builder_


{-| Pipe form of the `title` slot — accepts a builder directly (no `.toElement`).
-}
withTitle :
    B.Builder childRow childAttrCaps childSlotCaps Component.TitleSlot msg
    -> Builder attrCaps { s | title : Available } msg kind
    -> Builder attrCaps { s | title : Used } msg kind
withTitle slotBuilder builder_ =
    B.withChild (El.toNode (Component.title (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `maxDepth` — consumes its capability (write-once).
-}
withMaxDepth : Float -> Builder { a | maxDepth : Available } slotCaps msg kind -> Builder { a | maxDepth : Used } slotCaps msg kind
withMaxDepth value_ =
    B.withAttribute (A.maxDepth value_)
