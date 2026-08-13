module M3e.Build.Fab exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, CloseIconSlot, LabelSlot, ChildAdmittedBy, ActionCaps
    , withClass, withDisabled, withDisabledInteractive, withDownload, withExtended, withHref, withId, withLowered, withName, withOnClick, withRel, withSize, withSlot, withStyle, withTarget, withType, withValue, withVariant
    , closeIcon, label
    , withCloseIcon, withLabel, withChild
    )

{-| The builder module for `m3e-fab` — seed, pipe, and close.

This module provides everything you need to BUILD with `Fab`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.Fab.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, CloseIconSlot, LabelSlot, ChildAdmittedBy, ActionCaps
@docs withClass, withDisabled, withDisabledInteractive, withDownload, withExtended, withHref, withId, withLowered, withName, withOnClick, withRel, withSize, withSlot, withStyle, withTarget, withType, withValue, withVariant
@docs closeIcon, label
@docs withCloseIcon, withLabel, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import M3e.Action as Ac
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Fab as Component
import M3e.Events as Ev
import M3e.Internal.Types.Fab
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.Fab.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Fab.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.Fab.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.Fab.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Fab.ChildAdmittedBy childAdm


{-| The behaviours this component's required action admits.
-}
type alias ActionCaps =
    M3e.Internal.Types.Fab.ActionCaps


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Fab.Content


{-| The kinds the `close-icon` slot admits.
-}
type alias CloseIconSlot =
    M3e.Internal.Types.Fab.CloseIconSlot


{-| The kinds the `label` slot admits.
-}
type alias LabelSlot =
    M3e.Internal.Types.Fab.LabelSlot


{-| Seed the pipe-builder with required content (and action).
-}
build :
    { content : Element Component.Content (Component.ChildAdmittedBy childAdm) msg
    , action : Ac.Action Component.ActionCaps msg
    }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-fab" (Ac.toAttrs required_.action) [ Ac.wrapContent required_.action (El.toNode required_.content) ]


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `close-icon` slot — calls `B.toElement` internally.
-}
closeIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.CloseIconSlot msg
    -> Element free freeAdmittedBy msg
closeIcon builder =
    Component.closeIcon (B.toElement builder)


{-| Place a builder-built element into the named `label` slot — calls `B.toElement` internally.
-}
label :
    B.Builder childRow childAttrCaps childSlotCaps Component.LabelSlot msg
    -> Element free freeAdmittedBy msg
label builder =
    Component.label (B.toElement builder)


{-| Pipe form of the `close-icon` slot — accepts a builder directly (no `.toElement`).
-}
withCloseIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.CloseIconSlot msg
    -> Builder attrCaps { s | closeIcon : Available } msg kind
    -> Builder attrCaps { s | closeIcon : Used } msg kind
withCloseIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.closeIcon (B.toElement slotBuilder))) builder_


{-| Pipe form of the `label` slot — accepts a builder directly (no `.toElement`).
-}
withLabel :
    B.Builder childRow childAttrCaps childSlotCaps Component.LabelSlot msg
    -> Builder attrCaps { s | label : Available } msg kind
    -> Builder attrCaps { s | label : Used } msg kind
withLabel slotBuilder builder_ =
    B.withChild (El.toNode (Component.label (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `disabledInteractive` — consumes its capability (write-once).
-}
withDisabledInteractive : Bool -> Builder { a | disabledInteractive : Available } slotCaps msg kind -> Builder { a | disabledInteractive : Used } slotCaps msg kind
withDisabledInteractive value_ =
    B.withAttribute (A.disabledInteractive value_)


{-| Pipe form of `download` — consumes its capability (write-once).
-}
withDownload : String -> Builder { a | download : Available } slotCaps msg kind -> Builder { a | download : Used } slotCaps msg kind
withDownload value_ =
    B.withAttribute (A.download value_)


{-| Pipe form of `extended` — consumes its capability (write-once).
-}
withExtended : Bool -> Builder { a | extended : Available } slotCaps msg kind -> Builder { a | extended : Used } slotCaps msg kind
withExtended value_ =
    B.withAttribute (A.extended value_)


{-| Pipe form of `href` — consumes its capability (write-once).
-}
withHref : String -> Builder { a | href : Available } slotCaps msg kind -> Builder { a | href : Used } slotCaps msg kind
withHref value_ =
    B.withAttribute (A.href value_)


{-| Pipe form of `lowered` — consumes its capability (write-once).
-}
withLowered : Bool -> Builder { a | lowered : Available } slotCaps msg kind -> Builder { a | lowered : Used } slotCaps msg kind
withLowered value_ =
    B.withAttribute (A.lowered value_)


{-| Pipe form of `name` — consumes its capability (write-once).
-}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (Ir.attribute "name" value_)


{-| Pipe form of `rel` — consumes its capability (write-once).
-}
withRel : String -> Builder { a | rel : Available } slotCaps msg kind -> Builder { a | rel : Used } slotCaps msg kind
withRel value_ =
    B.withAttribute (A.rel value_)


{-| Pipe form of `size` — consumes its capability (write-once).
-}
withSize : Value Component.Size -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.size value_)


{-| Pipe form of `target` — consumes its capability (write-once).
-}
withTarget : String -> Builder { a | target : Available } slotCaps msg kind -> Builder { a | target : Used } slotCaps msg kind
withTarget value_ =
    B.withAttribute (A.target value_)


{-| Pipe form of `type_` — consumes its capability (write-once).
-}
withType : Value Component.Type -> Builder { a | type_ : Available } slotCaps msg kind -> Builder { a | type_ : Used } slotCaps msg kind
withType value_ =
    B.withAttribute (Component.type_ value_)


{-| Pipe form of `value` — consumes its capability (write-once).
-}
withValue : String -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (A.value value_)


{-| Pipe form of `variant` — consumes its capability (write-once).
-}
withVariant : Value Component.Variant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.variant value_)


{-| Pipe form of `onClick` — consumes its capability (write-once).
-}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
