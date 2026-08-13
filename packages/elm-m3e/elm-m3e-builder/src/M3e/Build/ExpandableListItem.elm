module M3e.Build.ExpandableListItem exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, ToggleIconSlot, ChildAdmittedBy
    , withClass, withDisabled, withId, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withSlot, withStyle
    , items, leading, overline, supportingText, toggleIcon
    , withItems, withLeading, withOverline, withSupportingText, withToggleIcon, withChild
    )

{-| The builder module for `m3e-expandable-list-item` — seed, pipe, and close.

This module provides everything you need to BUILD with `ExpandableListItem`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.ExpandableListItem.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, ToggleIconSlot, ChildAdmittedBy
@docs withClass, withDisabled, withId, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withSlot, withStyle
@docs items, leading, overline, supportingText, toggleIcon
@docs withItems, withLeading, withOverline, withSupportingText, withToggleIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.ExpandableListItem as Component
import M3e.Events as Ev
import M3e.Internal.Types.ExpandableListItem
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.ExpandableListItem.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.ExpandableListItem.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.ExpandableListItem.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.ExpandableListItem.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.ExpandableListItem.ChildAdmittedBy childAdm


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.ExpandableListItem.Content


{-| The kinds the `leading` slot admits.
-}
type alias LeadingSlot =
    M3e.Internal.Types.ExpandableListItem.LeadingSlot


{-| The kinds the `overline` slot admits.
-}
type alias OverlineSlot =
    M3e.Internal.Types.ExpandableListItem.OverlineSlot


{-| The kinds the `supporting-text` slot admits.
-}
type alias SupportingTextSlot =
    M3e.Internal.Types.ExpandableListItem.SupportingTextSlot


{-| The kinds the `toggle-icon` slot admits.
-}
type alias ToggleIconSlot =
    M3e.Internal.Types.ExpandableListItem.ToggleIconSlot


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-expandable-list-item" [] []


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `items` slot — calls `B.toElement` internally.
-}
items :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
items builder =
    Component.items (B.toElement builder)


{-| Place a builder-built element into the named `leading` slot — calls `B.toElement` internally.
-}
leading :
    B.Builder childRow childAttrCaps childSlotCaps Component.LeadingSlot msg
    -> Element free freeAdmittedBy msg
leading builder =
    Component.leading (B.toElement builder)


{-| Place a builder-built element into the named `overline` slot — calls `B.toElement` internally.
-}
overline :
    B.Builder childRow childAttrCaps childSlotCaps Component.OverlineSlot msg
    -> Element free freeAdmittedBy msg
overline builder =
    Component.overline (B.toElement builder)


{-| Place a builder-built element into the named `supporting-text` slot — calls `B.toElement` internally.
-}
supportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.SupportingTextSlot msg
    -> Element free freeAdmittedBy msg
supportingText builder =
    Component.supportingText (B.toElement builder)


{-| Place a builder-built element into the named `toggle-icon` slot — calls `B.toElement` internally.
-}
toggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ToggleIconSlot msg
    -> Element free freeAdmittedBy msg
toggleIcon builder =
    Component.toggleIcon (B.toElement builder)


{-| Pipe form of the `items` slot — accepts a builder directly (no `.toElement`).
-}
withItems :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | items : Available } msg kind
    -> Builder attrCaps { s | items : Used } msg kind
withItems slotBuilder builder_ =
    B.withChild (El.toNode (Component.items (B.toElement slotBuilder))) builder_


{-| Pipe form of the `leading` slot — accepts a builder directly (no `.toElement`).
-}
withLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.LeadingSlot msg
    -> Builder attrCaps { s | leading : Available } msg kind
    -> Builder attrCaps { s | leading : Used } msg kind
withLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.leading (B.toElement slotBuilder))) builder_


{-| Pipe form of the `overline` slot — accepts a builder directly (no `.toElement`).
-}
withOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.OverlineSlot msg
    -> Builder attrCaps { s | overline : Available } msg kind
    -> Builder attrCaps { s | overline : Used } msg kind
withOverline slotBuilder builder_ =
    B.withChild (El.toNode (Component.overline (B.toElement slotBuilder))) builder_


{-| Pipe form of the `supporting-text` slot — accepts a builder directly (no `.toElement`).
-}
withSupportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.SupportingTextSlot msg
    -> Builder attrCaps { s | supportingText : Available } msg kind
    -> Builder attrCaps { s | supportingText : Used } msg kind
withSupportingText slotBuilder builder_ =
    B.withChild (El.toNode (Component.supportingText (B.toElement slotBuilder))) builder_


{-| Pipe form of the `toggle-icon` slot — accepts a builder directly (no `.toElement`).
-}
withToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ToggleIconSlot msg
    -> Builder attrCaps { s | toggleIcon : Available } msg kind
    -> Builder attrCaps { s | toggleIcon : Used } msg kind
withToggleIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.toggleIcon (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `open` — consumes its capability (write-once).
-}
withOpen : Bool -> Builder { a | open : Available } slotCaps msg kind -> Builder { a | open : Used } slotCaps msg kind
withOpen value_ =
    B.withAttribute (A.open value_)


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
