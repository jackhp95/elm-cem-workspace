module M3e.Build.Breadcrumb exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
    , withClass, withId, withSlot, withStyle, withWrap
    , separator
    , withSeparator, withChild
    )

{-| The builder module for `m3e-breadcrumb` — seed, pipe, and close.

This module provides everything you need to BUILD with `Breadcrumb`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.Breadcrumb.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
@docs withClass, withId, withSlot, withStyle, withWrap
@docs separator
@docs withSeparator, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Breadcrumb as Component
import M3e.Internal.Types.Breadcrumb
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.Breadcrumb.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Breadcrumb.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.Breadcrumb.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.Breadcrumb.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Breadcrumb.ChildAdmittedBy childAdm


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Breadcrumb.Content


{-| Seed the pipe-builder with required content (and action).
-}
build :
    { content : Element Component.Content (Component.ChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-breadcrumb" [] [ El.toNode required_.content ]


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `separator` slot — calls `B.toElement` internally.
-}
separator :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
separator builder =
    Component.separator (B.toElement builder)


{-| Pipe form of the `separator` slot — accepts a builder directly (no `.toElement`).
-}
withSeparator :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | separator : Available } msg kind
    -> Builder attrCaps { s | separator : Used } msg kind
withSeparator slotBuilder builder_ =
    B.withChild (El.toNode (Component.separator (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `wrap` — consumes its capability (write-once).
-}
withWrap : Bool -> Builder { a | wrap : Available } slotCaps msg kind -> Builder { a | wrap : Used } slotCaps msg kind
withWrap value_ =
    B.withAttribute (A.wrap value_)
