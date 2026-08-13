module M3e.Build.SplitButton exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, LeadingButtonSlot, TrailingButtonSlot, ChildAdmittedBy
    , withClass, withId, withSize, withSlot, withStyle, withVariant
    , leadingButton, trailingButton
    , withLeadingButton, withTrailingButton
    )

{-| The builder module for `m3e-split-button` — seed, pipe, and close.

This module provides everything you need to BUILD with `SplitButton`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.SplitButton.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, LeadingButtonSlot, TrailingButtonSlot, ChildAdmittedBy
@docs withClass, withId, withSize, withSlot, withStyle, withVariant
@docs leadingButton, trailingButton
@docs withLeadingButton, withTrailingButton

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.SplitButton as Component
import M3e.Internal.Types.SplitButton
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.SplitButton.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.SplitButton.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.SplitButton.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.SplitButton.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.SplitButton.ChildAdmittedBy childAdm


{-| The kinds the `leading-button` slot admits.
-}
type alias LeadingButtonSlot =
    M3e.Internal.Types.SplitButton.LeadingButtonSlot


{-| The kinds the `trailing-button` slot admits.
-}
type alias TrailingButtonSlot =
    M3e.Internal.Types.SplitButton.TrailingButtonSlot


{-| Seed the pipe-builder with required content (and action).
-}
build :
    { leadingButton : Element Component.LeadingButtonSlot (Component.ChildAdmittedBy childAdm) msg
    , trailingButton : Element Component.TrailingButtonSlot (Component.ChildAdmittedBy childAdm) msg
    }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-split-button" [] [ El.toNode (Component.leadingButton required_.leadingButton), El.toNode (Component.trailingButton required_.trailingButton) ]


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `leading-button` slot — calls `B.toElement` internally.
-}
leadingButton :
    B.Builder childRow childAttrCaps childSlotCaps Component.LeadingButtonSlot msg
    -> Element free freeAdmittedBy msg
leadingButton builder =
    Component.leadingButton (B.toElement builder)


{-| Place a builder-built element into the named `trailing-button` slot — calls `B.toElement` internally.
-}
trailingButton :
    B.Builder childRow childAttrCaps childSlotCaps Component.TrailingButtonSlot msg
    -> Element free freeAdmittedBy msg
trailingButton builder =
    Component.trailingButton (B.toElement builder)


{-| Pipe form of the `leading-button` slot — accepts a builder directly (no `.toElement`).
-}
withLeadingButton :
    B.Builder childRow childAttrCaps childSlotCaps Component.LeadingButtonSlot msg
    -> Builder attrCaps { s | leadingButton : Available } msg kind
    -> Builder attrCaps { s | leadingButton : Used } msg kind
withLeadingButton slotBuilder builder_ =
    B.withChild (El.toNode (Component.leadingButton (B.toElement slotBuilder))) builder_


{-| Pipe form of the `trailing-button` slot — accepts a builder directly (no `.toElement`).
-}
withTrailingButton :
    B.Builder childRow childAttrCaps childSlotCaps Component.TrailingButtonSlot msg
    -> Builder attrCaps { s | trailingButton : Available } msg kind
    -> Builder attrCaps { s | trailingButton : Used } msg kind
withTrailingButton slotBuilder builder_ =
    B.withChild (El.toNode (Component.trailingButton (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `size` — consumes its capability (write-once).
-}
withSize : Value Component.Size -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.size value_)


{-| Pipe form of `variant` — consumes its capability (write-once).
-}
withVariant : Value Component.Variant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.variant value_)
