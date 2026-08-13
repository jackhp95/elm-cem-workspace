module M3e.Build.BreadcrumbItem exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, ChildAdmittedBy
    , withClass, withCurrent, withDisabled, withDownload, withHref, withId, withItemLabel, withOnClick, withRel, withSlot, withStyle, withTarget
    , icon
    , withIcon, withChild
    )

{-| The builder module for `m3e-breadcrumb-item` — seed, pipe, and close.

This module provides everything you need to BUILD with `BreadcrumbItem`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.BreadcrumbItem.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, ChildAdmittedBy
@docs withClass, withCurrent, withDisabled, withDownload, withHref, withId, withItemLabel, withOnClick, withRel, withSlot, withStyle, withTarget
@docs icon
@docs withIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.BreadcrumbItem as Component
import M3e.Events as Ev
import M3e.Internal.Types.BreadcrumbItem
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.BreadcrumbItem.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.BreadcrumbItem.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.BreadcrumbItem.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.BreadcrumbItem.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.BreadcrumbItem.ChildAdmittedBy childAdm


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.BreadcrumbItem.Content


{-| The kinds the `icon` slot admits.
-}
type alias IconSlot =
    M3e.Internal.Types.BreadcrumbItem.IconSlot


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-breadcrumb-item" [] []


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


{-| Pipe form of the `icon` slot — accepts a builder directly (no `.toElement`).
-}
withIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.IconSlot msg
    -> Builder attrCaps { s | icon : Available } msg kind
    -> Builder attrCaps { s | icon : Used } msg kind
withIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.icon (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `current` — consumes its capability (write-once).
-}
withCurrent : Value Component.Current -> Builder { a | current : Available } slotCaps msg kind -> Builder { a | current : Used } slotCaps msg kind
withCurrent value_ =
    B.withAttribute (Component.current value_)


{-| Pipe form of `disabled` — consumes its capability (write-once).
-}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| Pipe form of `download` — consumes its capability (write-once).
-}
withDownload : String -> Builder { a | download : Available } slotCaps msg kind -> Builder { a | download : Used } slotCaps msg kind
withDownload value_ =
    B.withAttribute (A.download value_)


{-| Pipe form of `href` — consumes its capability (write-once).
-}
withHref : String -> Builder { a | href : Available } slotCaps msg kind -> Builder { a | href : Used } slotCaps msg kind
withHref value_ =
    B.withAttribute (A.href value_)


{-| Pipe form of `itemLabel` — consumes its capability (write-once).
-}
withItemLabel : String -> Builder { a | itemLabel : Available } slotCaps msg kind -> Builder { a | itemLabel : Used } slotCaps msg kind
withItemLabel value_ =
    B.withAttribute (A.itemLabel value_)


{-| Pipe form of `rel` — consumes its capability (write-once).
-}
withRel : String -> Builder { a | rel : Available } slotCaps msg kind -> Builder { a | rel : Used } slotCaps msg kind
withRel value_ =
    B.withAttribute (A.rel value_)


{-| Pipe form of `target` — consumes its capability (write-once).
-}
withTarget : String -> Builder { a | target : Available } slotCaps msg kind -> Builder { a | target : Used } slotCaps msg kind
withTarget value_ =
    B.withAttribute (A.target value_)


{-| Pipe form of `onClick` — consumes its capability (write-once).
-}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
