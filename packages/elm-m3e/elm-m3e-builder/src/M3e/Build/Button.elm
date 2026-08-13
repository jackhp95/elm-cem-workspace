module M3e.Build.Button exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, SelectedSlot, SelectedIconSlot, TrailingIconSlot, ChildAdmittedBy, ActionCaps
    , withClass, withDisabled, withDisabledInteractive, withDownload, withHref, withId, withName, withOnBeforeinput, withOnChange, withOnClick, withOnInput, withRel, withSelected, withShape, withSize, withSlot, withStyle, withTarget, withToggle, withType, withValue, withVariant
    , icon, selected, selectedIcon, trailingIcon
    , withIcon, withSelectedSlot, withSelectedIcon, withTrailingIcon, withChild
    )

{-| The builder module for `m3e-button` — seed, pipe, and close.

This module provides everything you need to BUILD with `Button`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.Button.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, SelectedSlot, SelectedIconSlot, TrailingIconSlot, ChildAdmittedBy, ActionCaps
@docs withClass, withDisabled, withDisabledInteractive, withDownload, withHref, withId, withName, withOnBeforeinput, withOnChange, withOnClick, withOnInput, withRel, withSelected, withShape, withSize, withSlot, withStyle, withTarget, withToggle, withType, withValue, withVariant
@docs icon, selected, selectedIcon, trailingIcon
@docs withIcon, withSelectedSlot, withSelectedIcon, withTrailingIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import M3e.Action as Ac
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Button as Component
import M3e.Events as Ev
import M3e.Internal.Types.Button
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.Button.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Button.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.Button.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.Button.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Button.ChildAdmittedBy childAdm


{-| The behaviours this component's required action admits.
-}
type alias ActionCaps =
    M3e.Internal.Types.Button.ActionCaps


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Button.Content


{-| The kinds the `icon` slot admits.
-}
type alias IconSlot =
    M3e.Internal.Types.Button.IconSlot


{-| The kinds the `selected` slot admits.
-}
type alias SelectedSlot =
    M3e.Internal.Types.Button.SelectedSlot


{-| The kinds the `selected-icon` slot admits.
-}
type alias SelectedIconSlot =
    M3e.Internal.Types.Button.SelectedIconSlot


{-| The kinds the `trailing-icon` slot admits.
-}
type alias TrailingIconSlot =
    M3e.Internal.Types.Button.TrailingIconSlot


{-| Seed the pipe-builder with required content (and action).
-}
build :
    { content : Element Component.Content (Component.ChildAdmittedBy childAdm) msg
    , action : Ac.Action Component.ActionCaps msg
    }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-button" (Ac.toAttrs required_.action) [ Ac.wrapContent required_.action (El.toNode required_.content) ]


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


{-| Place a builder-built element into the named `selected` slot — calls `B.toElement` internally.
-}
selected :
    B.Builder childRow childAttrCaps childSlotCaps Component.SelectedSlot msg
    -> Element free freeAdmittedBy msg
selected builder =
    Component.selected (B.toElement builder)


{-| Place a builder-built element into the named `selected-icon` slot — calls `B.toElement` internally.
-}
selectedIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SelectedIconSlot msg
    -> Element free freeAdmittedBy msg
selectedIcon builder =
    Component.selectedIcon (B.toElement builder)


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


{-| Pipe form of the `selected` slot — accepts a builder directly (no `.toElement`).
-}
withSelectedSlot :
    B.Builder childRow childAttrCaps childSlotCaps Component.SelectedSlot msg
    -> Builder attrCaps { s | selected : Available } msg kind
    -> Builder attrCaps { s | selected : Used } msg kind
withSelectedSlot slotBuilder builder_ =
    B.withChild (El.toNode (Component.selected (B.toElement slotBuilder))) builder_


{-| Pipe form of the `selected-icon` slot — accepts a builder directly (no `.toElement`).
-}
withSelectedIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SelectedIconSlot msg
    -> Builder attrCaps { s | selectedIcon : Available } msg kind
    -> Builder attrCaps { s | selectedIcon : Used } msg kind
withSelectedIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.selectedIcon (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `href` — consumes its capability (write-once).
-}
withHref : String -> Builder { a | href : Available } slotCaps msg kind -> Builder { a | href : Used } slotCaps msg kind
withHref value_ =
    B.withAttribute (A.href value_)


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


{-| Pipe form of `selected` — consumes its capability (write-once).
-}
withSelected : Bool -> Builder { a | selected : Available } slotCaps msg kind -> Builder { a | selected : Used } slotCaps msg kind
withSelected value_ =
    B.withAttribute (A.selected value_)


{-| Pipe form of `shape` — consumes its capability (write-once).
-}
withShape : Value Component.Shape -> Builder { a | shape : Available } slotCaps msg kind -> Builder { a | shape : Used } slotCaps msg kind
withShape value_ =
    B.withAttribute (Component.shape value_)


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


{-| Pipe form of `toggle` — consumes its capability (write-once).
-}
withToggle : Bool -> Builder { a | toggle : Available } slotCaps msg kind -> Builder { a | toggle : Used } slotCaps msg kind
withToggle value_ =
    B.withAttribute (A.toggle value_)


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


{-| Pipe form of `onBeforeinput` — consumes its capability (write-once).
-}
withOnBeforeinput : msg -> Builder { a | onBeforeinput : Available } slotCaps msg kind -> Builder { a | onBeforeinput : Used } slotCaps msg kind
withOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| Pipe form of `onInput` — consumes its capability (write-once).
-}
withOnInput : msg -> Builder { a | onInput : Available } slotCaps msg kind -> Builder { a | onInput : Used } slotCaps msg kind
withOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| Pipe form of `onChange` — consumes its capability (write-once).
-}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| Pipe form of `onClick` — consumes its capability (write-once).
-}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
