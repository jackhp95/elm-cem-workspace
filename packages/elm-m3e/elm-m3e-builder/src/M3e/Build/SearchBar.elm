module M3e.Build.SearchBar exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ClearIconSlot, LeadingSlot, TrailingSlot, ChildAdmittedBy
    , withClass, withClearLabel, withClearable, withId, withOnClear, withSlot, withStyle
    , clearIcon, input, leading, trailing
    , withClearIcon, withInput, withLeading, withTrailing
    )

{-| The builder module for `m3e-search-bar` — seed, pipe, and close.

This module provides everything you need to BUILD with `SearchBar`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.SearchBar.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ClearIconSlot, LeadingSlot, TrailingSlot, ChildAdmittedBy
@docs withClass, withClearLabel, withClearable, withId, withOnClear, withSlot, withStyle
@docs clearIcon, input, leading, trailing
@docs withClearIcon, withInput, withLeading, withTrailing

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.SearchBar as Component
import M3e.Events as Ev
import M3e.Internal.Types.SearchBar
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.SearchBar.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.SearchBar.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.SearchBar.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.SearchBar.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.SearchBar.ChildAdmittedBy childAdm


{-| The kinds the `clear-icon` slot admits.
-}
type alias ClearIconSlot =
    M3e.Internal.Types.SearchBar.ClearIconSlot


{-| The kinds the `leading` slot admits.
-}
type alias LeadingSlot =
    M3e.Internal.Types.SearchBar.LeadingSlot


{-| The kinds the `trailing` slot admits.
-}
type alias TrailingSlot =
    M3e.Internal.Types.SearchBar.TrailingSlot


{-| Seed the pipe-builder with required content (and action).
-}
build :
    { input : Element childAccepts (Component.ChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-search-bar" [] [ El.toNode (Component.input required_.input) ]


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `clear-icon` slot — calls `B.toElement` internally.
-}
clearIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ClearIconSlot msg
    -> Element free freeAdmittedBy msg
clearIcon builder =
    Component.clearIcon (B.toElement builder)


{-| Place a builder-built element into the named `input` slot — calls `B.toElement` internally.
-}
input :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
input builder =
    Component.input (B.toElement builder)


{-| Place a builder-built element into the named `leading` slot — calls `B.toElement` internally.
-}
leading :
    B.Builder childRow childAttrCaps childSlotCaps Component.LeadingSlot msg
    -> Element free freeAdmittedBy msg
leading builder =
    Component.leading (B.toElement builder)


{-| Place a builder-built element into the named `trailing` slot — calls `B.toElement` internally.
-}
trailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.TrailingSlot msg
    -> Element free freeAdmittedBy msg
trailing builder =
    Component.trailing (B.toElement builder)


{-| Pipe form of the `clear-icon` slot — accepts a builder directly (no `.toElement`).
-}
withClearIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ClearIconSlot msg
    -> Builder attrCaps { s | clearIcon : Available } msg kind
    -> Builder attrCaps { s | clearIcon : Used } msg kind
withClearIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.clearIcon (B.toElement slotBuilder))) builder_


{-| Pipe form of the `input` slot — accepts a builder directly (no `.toElement`).
-}
withInput :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | input : Available } msg kind
    -> Builder attrCaps { s | input : Used } msg kind
withInput slotBuilder builder_ =
    B.withChild (El.toNode (Component.input (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `clearLabel` — consumes its capability (write-once).
-}
withClearLabel : String -> Builder { a | clearLabel : Available } slotCaps msg kind -> Builder { a | clearLabel : Used } slotCaps msg kind
withClearLabel value_ =
    B.withAttribute (A.clearLabel value_)


{-| Pipe form of `clearable` — consumes its capability (write-once).
-}
withClearable : Bool -> Builder { a | clearable : Available } slotCaps msg kind -> Builder { a | clearable : Used } slotCaps msg kind
withClearable value_ =
    B.withAttribute (A.clearable value_)


{-| Pipe form of `onClear` — consumes its capability (write-once).
-}
withOnClear : msg -> Builder { a | onClear : Available } slotCaps msg kind -> Builder { a | onClear : Used } slotCaps msg kind
withOnClear value_ =
    B.withAttribute (Ev.onClear value_)
