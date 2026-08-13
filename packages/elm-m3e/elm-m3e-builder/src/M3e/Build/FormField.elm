module M3e.Build.FormField exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withFloatLabel, withHideRequiredMarker, withHideSubscript, withId, withSlot, withStyle, withVariant
    , error, hint, label, prefix, prefixText, suffix, suffixText
    , withError, withHint, withLabel, withPrefix, withPrefixText, withSuffix, withSuffixText, withChild
    )

{-| The builder module for `m3e-form-field` — seed, pipe, and close.

This module provides everything you need to BUILD with `FormField`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.FormField.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withFloatLabel, withHideRequiredMarker, withHideSubscript, withId, withSlot, withStyle, withVariant
@docs error, hint, label, prefix, prefixText, suffix, suffixText
@docs withError, withHint, withLabel, withPrefix, withPrefixText, withSuffix, withSuffixText, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.FormField as Component
import M3e.Internal.Types.FormField
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.FormField.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.FormField.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.FormField.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.FormField.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.FormField.ChildAdmittedBy childAdm


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-form-field" [] []


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `error` slot — calls `B.toElement` internally.
-}
error :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
error builder =
    Component.error (B.toElement builder)


{-| Place a builder-built element into the named `hint` slot — calls `B.toElement` internally.
-}
hint :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
hint builder =
    Component.hint (B.toElement builder)


{-| Place a builder-built element into the named `label` slot — calls `B.toElement` internally.
-}
label :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
label builder =
    Component.label (B.toElement builder)


{-| Place a builder-built element into the named `prefix` slot — calls `B.toElement` internally.
-}
prefix :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
prefix builder =
    Component.prefix (B.toElement builder)


{-| Place a builder-built element into the named `prefix-text` slot — calls `B.toElement` internally.
-}
prefixText :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
prefixText builder =
    Component.prefixText (B.toElement builder)


{-| Place a builder-built element into the named `suffix` slot — calls `B.toElement` internally.
-}
suffix :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
suffix builder =
    Component.suffix (B.toElement builder)


{-| Place a builder-built element into the named `suffix-text` slot — calls `B.toElement` internally.
-}
suffixText :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
suffixText builder =
    Component.suffixText (B.toElement builder)


{-| Pipe form of the `error` slot — accepts a builder directly (no `.toElement`).
-}
withError :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | error : Available } msg kind
    -> Builder attrCaps { s | error : Used } msg kind
withError slotBuilder builder_ =
    B.withChild (El.toNode (Component.error (B.toElement slotBuilder))) builder_


{-| Pipe form of the `hint` slot — accepts a builder directly (no `.toElement`).
-}
withHint :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | hint : Available } msg kind
    -> Builder attrCaps { s | hint : Used } msg kind
withHint slotBuilder builder_ =
    B.withChild (El.toNode (Component.hint (B.toElement slotBuilder))) builder_


{-| Pipe form of the `label` slot — accepts a builder directly (no `.toElement`).
-}
withLabel :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | label : Available } msg kind
    -> Builder attrCaps { s | label : Used } msg kind
withLabel slotBuilder builder_ =
    B.withChild (El.toNode (Component.label (B.toElement slotBuilder))) builder_


{-| Pipe form of the `prefix` slot — accepts a builder directly (no `.toElement`).
-}
withPrefix :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | prefix : Available } msg kind
    -> Builder attrCaps { s | prefix : Used } msg kind
withPrefix slotBuilder builder_ =
    B.withChild (El.toNode (Component.prefix (B.toElement slotBuilder))) builder_


{-| Pipe form of the `prefix-text` slot — accepts a builder directly (no `.toElement`).
-}
withPrefixText :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | prefixText : Available } msg kind
    -> Builder attrCaps { s | prefixText : Used } msg kind
withPrefixText slotBuilder builder_ =
    B.withChild (El.toNode (Component.prefixText (B.toElement slotBuilder))) builder_


{-| Pipe form of the `suffix` slot — accepts a builder directly (no `.toElement`).
-}
withSuffix :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | suffix : Available } msg kind
    -> Builder attrCaps { s | suffix : Used } msg kind
withSuffix slotBuilder builder_ =
    B.withChild (El.toNode (Component.suffix (B.toElement slotBuilder))) builder_


{-| Pipe form of the `suffix-text` slot — accepts a builder directly (no `.toElement`).
-}
withSuffixText :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | suffixText : Available } msg kind
    -> Builder attrCaps { s | suffixText : Used } msg kind
withSuffixText slotBuilder builder_ =
    B.withChild (El.toNode (Component.suffixText (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `floatLabel` — consumes its capability (write-once).
-}
withFloatLabel : Value Component.FloatLabel -> Builder { a | floatLabel : Available } slotCaps msg kind -> Builder { a | floatLabel : Used } slotCaps msg kind
withFloatLabel value_ =
    B.withAttribute (Component.floatLabel value_)


{-| Pipe form of `hideRequiredMarker` — consumes its capability (write-once).
-}
withHideRequiredMarker : Bool -> Builder { a | hideRequiredMarker : Available } slotCaps msg kind -> Builder { a | hideRequiredMarker : Used } slotCaps msg kind
withHideRequiredMarker value_ =
    B.withAttribute (A.hideRequiredMarker value_)


{-| Pipe form of `hideSubscript` — consumes its capability (write-once).
-}
withHideSubscript : Value Component.HideSubscript -> Builder { a | hideSubscript : Available } slotCaps msg kind -> Builder { a | hideSubscript : Used } slotCaps msg kind
withHideSubscript value_ =
    B.withAttribute (Component.hideSubscript value_)


{-| Pipe form of `variant` — consumes its capability (write-once).
-}
withVariant : Value Component.Variant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.variant value_)
