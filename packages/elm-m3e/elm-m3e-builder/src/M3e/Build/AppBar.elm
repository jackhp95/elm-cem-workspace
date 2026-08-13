module M3e.Build.AppBar exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, LeadingSlot, SubtitleSlot, TitleSlot, TrailingSlot, ChildAdmittedBy
    , withCentered, withClass, withFor, withId, withSize, withSlot, withStyle
    , leading, leadingIcon, subtitle, title, trailing, trailingIcon
    , withLeadingIcon, withSubtitle, withTitle, withTrailingIcon, withLeading, withTrailing
    )

{-| The builder module for `m3e-app-bar` — seed, pipe, and close.

This module provides everything you need to BUILD with `AppBar`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.AppBar.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, LeadingSlot, SubtitleSlot, TitleSlot, TrailingSlot, ChildAdmittedBy
@docs withCentered, withClass, withFor, withId, withSize, withSlot, withStyle
@docs leading, leadingIcon, subtitle, title, trailing, trailingIcon
@docs withLeadingIcon, withSubtitle, withTitle, withTrailingIcon, withLeading, withTrailing

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.AppBar as Component
import M3e.Internal.Types.AppBar
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.AppBar.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.AppBar.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.AppBar.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.AppBar.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.AppBar.ChildAdmittedBy childAdm


{-| The kinds the `leading` slot admits.
-}
type alias LeadingSlot =
    M3e.Internal.Types.AppBar.LeadingSlot


{-| The kinds the `subtitle` slot admits.
-}
type alias SubtitleSlot =
    M3e.Internal.Types.AppBar.SubtitleSlot


{-| The kinds the `title` slot admits.
-}
type alias TitleSlot =
    M3e.Internal.Types.AppBar.TitleSlot


{-| The kinds the `trailing` slot admits.
-}
type alias TrailingSlot =
    M3e.Internal.Types.AppBar.TrailingSlot


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-app-bar" [] []


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `leading` slot — calls `B.toElement` internally.
-}
leading :
    B.Builder childRow childAttrCaps childSlotCaps Component.LeadingSlot msg
    -> Element free freeAdmittedBy msg
leading builder =
    Component.leading (B.toElement builder)


{-| Place a builder-built element into the named `leading-icon` slot — calls `B.toElement` internally.
-}
leadingIcon :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
leadingIcon builder =
    Component.leadingIcon (B.toElement builder)


{-| Place a builder-built element into the named `subtitle` slot — calls `B.toElement` internally.
-}
subtitle :
    B.Builder childRow childAttrCaps childSlotCaps Component.SubtitleSlot msg
    -> Element free freeAdmittedBy msg
subtitle builder =
    Component.subtitle (B.toElement builder)


{-| Place a builder-built element into the named `title` slot — calls `B.toElement` internally.
-}
title :
    B.Builder childRow childAttrCaps childSlotCaps Component.TitleSlot msg
    -> Element free freeAdmittedBy msg
title builder =
    Component.title (B.toElement builder)


{-| Place a builder-built element into the named `trailing` slot — calls `B.toElement` internally.
-}
trailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.TrailingSlot msg
    -> Element free freeAdmittedBy msg
trailing builder =
    Component.trailing (B.toElement builder)


{-| Place a builder-built element into the named `trailing-icon` slot — calls `B.toElement` internally.
-}
trailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
trailingIcon builder =
    Component.trailingIcon (B.toElement builder)


{-| Pipe form of the `leading-icon` slot — accepts a builder directly (no `.toElement`).
-}
withLeadingIcon :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | leadingIcon : Available } msg kind
    -> Builder attrCaps { s | leadingIcon : Used } msg kind
withLeadingIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.leadingIcon (B.toElement slotBuilder))) builder_


{-| Pipe form of the `subtitle` slot — accepts a builder directly (no `.toElement`).
-}
withSubtitle :
    B.Builder childRow childAttrCaps childSlotCaps Component.SubtitleSlot msg
    -> Builder attrCaps { s | subtitle : Available } msg kind
    -> Builder attrCaps { s | subtitle : Used } msg kind
withSubtitle slotBuilder builder_ =
    B.withChild (El.toNode (Component.subtitle (B.toElement slotBuilder))) builder_


{-| Pipe form of the `title` slot — accepts a builder directly (no `.toElement`).
-}
withTitle :
    B.Builder childRow childAttrCaps childSlotCaps Component.TitleSlot msg
    -> Builder attrCaps { s | title : Available } msg kind
    -> Builder attrCaps { s | title : Used } msg kind
withTitle slotBuilder builder_ =
    B.withChild (El.toNode (Component.title (B.toElement slotBuilder))) builder_


{-| Pipe form of the `trailing-icon` slot — accepts a builder directly (no `.toElement`).
-}
withTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | trailingIcon : Available } msg kind
    -> Builder attrCaps { s | trailingIcon : Used } msg kind
withTrailingIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.trailingIcon (B.toElement slotBuilder))) builder_


{-| Pipe form of the `leading` slot (repeatable) — accepts a builder directly.
-}
withLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.LeadingSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.leading (B.toElement slotBuilder))) builder_


{-| Pipe form of the `trailing` slot (repeatable) — accepts a builder directly.
-}
withTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.TrailingSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withTrailing slotBuilder builder_ =
    B.withChild (El.toNode (Component.trailing (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `centered` — consumes its capability (write-once).
-}
withCentered : Bool -> Builder { a | centered : Available } slotCaps msg kind -> Builder { a | centered : Used } slotCaps msg kind
withCentered value_ =
    B.withAttribute (A.centered value_)


{-| Pipe form of `for` — consumes its capability (write-once).
-}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| Pipe form of `size` — consumes its capability (write-once).
-}
withSize : Value Component.Size -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.size value_)
