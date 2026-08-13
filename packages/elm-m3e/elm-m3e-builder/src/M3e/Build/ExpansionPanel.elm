module M3e.Build.ExpansionPanel exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ToggleIconSlot, ChildAdmittedBy
    , withClass, withDisabled, withHideToggle, withId, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withSlot, withStyle, withToggleDirection, withTogglePosition
    , actions, header, toggleIcon
    , withHeader, withToggleIcon, withActions, withChild
    )

{-| The builder module for `m3e-expansion-panel` — seed, pipe, and close.

This module provides everything you need to BUILD with `ExpansionPanel`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.ExpansionPanel.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ToggleIconSlot, ChildAdmittedBy
@docs withClass, withDisabled, withHideToggle, withId, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withSlot, withStyle, withToggleDirection, withTogglePosition
@docs actions, header, toggleIcon
@docs withHeader, withToggleIcon, withActions, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.ExpansionPanel as Component
import M3e.Events as Ev
import M3e.Internal.Types.ExpansionPanel
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.ExpansionPanel.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.ExpansionPanel.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.ExpansionPanel.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.ExpansionPanel.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.ExpansionPanel.ChildAdmittedBy childAdm


{-| The kinds the `toggle-icon` slot admits.
-}
type alias ToggleIconSlot =
    M3e.Internal.Types.ExpansionPanel.ToggleIconSlot


{-| Seed the pipe-builder with required content (and action).
-}
build :
    { header : Element childAccepts (Component.ChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-expansion-panel" [] [ El.toNode (Component.header required_.header) ]


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `actions` slot — calls `B.toElement` internally.
-}
actions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
actions builder =
    Component.actions (B.toElement builder)


{-| Place a builder-built element into the named `header` slot — calls `B.toElement` internally.
-}
header :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
header builder =
    Component.header (B.toElement builder)


{-| Place a builder-built element into the named `toggle-icon` slot — calls `B.toElement` internally.
-}
toggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ToggleIconSlot msg
    -> Element free freeAdmittedBy msg
toggleIcon builder =
    Component.toggleIcon (B.toElement builder)


{-| Pipe form of the `header` slot — accepts a builder directly (no `.toElement`).
-}
withHeader :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | header : Available } msg kind
    -> Builder attrCaps { s | header : Used } msg kind
withHeader slotBuilder builder_ =
    B.withChild (El.toNode (Component.header (B.toElement slotBuilder))) builder_


{-| Pipe form of the `toggle-icon` slot — accepts a builder directly (no `.toElement`).
-}
withToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ToggleIconSlot msg
    -> Builder attrCaps { s | toggleIcon : Available } msg kind
    -> Builder attrCaps { s | toggleIcon : Used } msg kind
withToggleIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.toggleIcon (B.toElement slotBuilder))) builder_


{-| Pipe form of the `actions` slot (repeatable) — accepts a builder directly.
-}
withActions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withActions slotBuilder builder_ =
    B.withChild (El.toNode (Component.actions (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `hideToggle` — consumes its capability (write-once).
-}
withHideToggle : Bool -> Builder { a | hideToggle : Available } slotCaps msg kind -> Builder { a | hideToggle : Used } slotCaps msg kind
withHideToggle value_ =
    B.withAttribute (A.hideToggle value_)


{-| Pipe form of `open` — consumes its capability (write-once).
-}
withOpen : Bool -> Builder { a | open : Available } slotCaps msg kind -> Builder { a | open : Used } slotCaps msg kind
withOpen value_ =
    B.withAttribute (A.open value_)


{-| Pipe form of `toggleDirection` — consumes its capability (write-once).
-}
withToggleDirection : Value Component.ToggleDirection -> Builder { a | toggleDirection : Available } slotCaps msg kind -> Builder { a | toggleDirection : Used } slotCaps msg kind
withToggleDirection value_ =
    B.withAttribute (Component.toggleDirection value_)


{-| Pipe form of `togglePosition` — consumes its capability (write-once).
-}
withTogglePosition : Value Component.TogglePosition -> Builder { a | togglePosition : Available } slotCaps msg kind -> Builder { a | togglePosition : Used } slotCaps msg kind
withTogglePosition value_ =
    B.withAttribute (Component.togglePosition value_)


{-| Pipe form of `onOpening` — consumes its capability (write-once).
-}
withOnOpening : msg -> Builder { a | onOpening : Available } slotCaps msg kind -> Builder { a | onOpening : Used } slotCaps msg kind
withOnOpening value_ =
    B.withAttribute (Ev.onOpening value_)


{-| Pipe form of `onOpened` — consumes its capability (write-once).
-}
withOnOpened : msg -> Builder { a | onOpened : Available } slotCaps msg kind -> Builder { a | onOpened : Used } slotCaps msg kind
withOnOpened value_ =
    B.withAttribute (Ev.onOpened value_)


{-| Pipe form of `onClosing` — consumes its capability (write-once).
-}
withOnClosing : msg -> Builder { a | onClosing : Available } slotCaps msg kind -> Builder { a | onClosing : Used } slotCaps msg kind
withOnClosing value_ =
    B.withAttribute (Ev.onClosing value_)


{-| Pipe form of `onClosed` — consumes its capability (write-once).
-}
withOnClosed : msg -> Builder { a | onClosed : Available } slotCaps msg kind -> Builder { a | onClosed : Used } slotCaps msg kind
withOnClosed value_ =
    B.withAttribute (Ev.onClosed value_)
