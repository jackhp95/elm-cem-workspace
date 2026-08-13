module M3e.Build.MenuItemRadio exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, TrailingIconSlot, ChildAdmittedBy
    , withChecked, withClass, withDisabled, withId, withOnClick, withSlot, withStyle
    , icon, trailingIcon
    , withIcon, withTrailingIcon, withChild
    )

{-| The builder module for `m3e-menu-item-radio` — seed, pipe, and close.

This module provides everything you need to BUILD with `MenuItemRadio`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.MenuItemRadio.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, TrailingIconSlot, ChildAdmittedBy
@docs withChecked, withClass, withDisabled, withId, withOnClick, withSlot, withStyle
@docs icon, trailingIcon
@docs withIcon, withTrailingIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.MenuItemRadio as Component
import M3e.Events as Ev
import M3e.Internal.Types.MenuItemRadio
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.MenuItemRadio.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.MenuItemRadio.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.MenuItemRadio.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.MenuItemRadio.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.MenuItemRadio.ChildAdmittedBy childAdm


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.MenuItemRadio.Content


{-| The kinds the `icon` slot admits.
-}
type alias IconSlot =
    M3e.Internal.Types.MenuItemRadio.IconSlot


{-| The kinds the `trailing-icon` slot admits.
-}
type alias TrailingIconSlot =
    M3e.Internal.Types.MenuItemRadio.TrailingIconSlot


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-menu-item-radio" [] []


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `icon` slot — calls `B.toElement` internally.
-}
icon :
    B.Builder childRow childAttrCaps childSlotCaps Component.IconSlot msg
    -> Element free freeAdmittedBy msg
icon builder =
    Component.icon (B.toElement builder)


{-| Place a builder-built element into the named `trailing-icon` slot — calls `B.toElement` internally.
-}
trailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.TrailingIconSlot msg
    -> Element free freeAdmittedBy msg
trailingIcon builder =
    Component.trailingIcon (B.toElement builder)


{-| Pipe form of the `icon` slot — accepts a builder directly (no `.toElement`).
-}
withIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.IconSlot msg
    -> Builder attrCaps { s | icon : Available } msg kind
    -> Builder attrCaps { s | icon : Used } msg kind
withIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.icon (B.toElement slotBuilder))) builder_


{-| Pipe form of the `trailing-icon` slot — accepts a builder directly (no `.toElement`).
-}
withTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.TrailingIconSlot msg
    -> Builder attrCaps { s | trailingIcon : Available } msg kind
    -> Builder attrCaps { s | trailingIcon : Used } msg kind
withTrailingIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.trailingIcon (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `checked` — consumes its capability (write-once).
-}
withChecked : Bool -> Builder { a | checked : Available } slotCaps msg kind -> Builder { a | checked : Used } slotCaps msg kind
withChecked value_ =
    B.withAttribute (A.checked value_)


{-| Pipe form of `disabled` — consumes its capability (write-once).
-}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| Pipe form of `onClick` — consumes its capability (write-once).
-}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
