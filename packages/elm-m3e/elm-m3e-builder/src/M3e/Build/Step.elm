module M3e.Build.Step exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, DoneIconSlot, EditIconSlot, ErrorSlot, ErrorIconSlot, HintSlot, IconSlot, ChildAdmittedBy
    , withClass, withCompleted, withDisabled, withEditable, withFor, withId, withInvalid, withOnBeforeinput, withOnChange, withOnClick, withOnInput, withOptional, withSelected, withSlot, withStyle
    , doneIcon, editIcon, error, errorIcon, hint, icon
    , withDoneIcon, withEditIcon, withError, withErrorIcon, withHint, withIcon, withChild
    )

{-| The builder module for `m3e-step` — seed, pipe, and close.

This module provides everything you need to BUILD with `Step`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.Step.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, DoneIconSlot, EditIconSlot, ErrorSlot, ErrorIconSlot, HintSlot, IconSlot, ChildAdmittedBy
@docs withClass, withCompleted, withDisabled, withEditable, withFor, withId, withInvalid, withOnBeforeinput, withOnChange, withOnClick, withOnInput, withOptional, withSelected, withSlot, withStyle
@docs doneIcon, editIcon, error, errorIcon, hint, icon
@docs withDoneIcon, withEditIcon, withError, withErrorIcon, withHint, withIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Step as Component
import M3e.Events as Ev
import M3e.Internal.Types.Step
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.Step.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Step.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.Step.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.Step.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Step.ChildAdmittedBy childAdm


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Step.Content


{-| The kinds the `done-icon` slot admits.
-}
type alias DoneIconSlot =
    M3e.Internal.Types.Step.DoneIconSlot


{-| The kinds the `edit-icon` slot admits.
-}
type alias EditIconSlot =
    M3e.Internal.Types.Step.EditIconSlot


{-| The kinds the `error` slot admits.
-}
type alias ErrorSlot =
    M3e.Internal.Types.Step.ErrorSlot


{-| The kinds the `error-icon` slot admits.
-}
type alias ErrorIconSlot =
    M3e.Internal.Types.Step.ErrorIconSlot


{-| The kinds the `hint` slot admits.
-}
type alias HintSlot =
    M3e.Internal.Types.Step.HintSlot


{-| The kinds the `icon` slot admits.
-}
type alias IconSlot =
    M3e.Internal.Types.Step.IconSlot


{-| Seed the pipe-builder with required content (and action).
-}
build :
    { content : Element Component.Content (Component.ChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-step" [] [ El.toNode required_.content ]


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `done-icon` slot — calls `B.toElement` internally.
-}
doneIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.DoneIconSlot msg
    -> Element free freeAdmittedBy msg
doneIcon builder =
    Component.doneIcon (B.toElement builder)


{-| Place a builder-built element into the named `edit-icon` slot — calls `B.toElement` internally.
-}
editIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.EditIconSlot msg
    -> Element free freeAdmittedBy msg
editIcon builder =
    Component.editIcon (B.toElement builder)


{-| Place a builder-built element into the named `error` slot — calls `B.toElement` internally.
-}
error :
    B.Builder childRow childAttrCaps childSlotCaps Component.ErrorSlot msg
    -> Element free freeAdmittedBy msg
error builder =
    Component.error (B.toElement builder)


{-| Place a builder-built element into the named `error-icon` slot — calls `B.toElement` internally.
-}
errorIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ErrorIconSlot msg
    -> Element free freeAdmittedBy msg
errorIcon builder =
    Component.errorIcon (B.toElement builder)


{-| Place a builder-built element into the named `hint` slot — calls `B.toElement` internally.
-}
hint :
    B.Builder childRow childAttrCaps childSlotCaps Component.HintSlot msg
    -> Element free freeAdmittedBy msg
hint builder =
    Component.hint (B.toElement builder)


{-| Place a builder-built element into the named `icon` slot — calls `B.toElement` internally.
-}
icon :
    B.Builder childRow childAttrCaps childSlotCaps Component.IconSlot msg
    -> Element free freeAdmittedBy msg
icon builder =
    Component.icon (B.toElement builder)


{-| Pipe form of the `done-icon` slot — accepts a builder directly (no `.toElement`).
-}
withDoneIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.DoneIconSlot msg
    -> Builder attrCaps { s | doneIcon : Available } msg kind
    -> Builder attrCaps { s | doneIcon : Used } msg kind
withDoneIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.doneIcon (B.toElement slotBuilder))) builder_


{-| Pipe form of the `edit-icon` slot — accepts a builder directly (no `.toElement`).
-}
withEditIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.EditIconSlot msg
    -> Builder attrCaps { s | editIcon : Available } msg kind
    -> Builder attrCaps { s | editIcon : Used } msg kind
withEditIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.editIcon (B.toElement slotBuilder))) builder_


{-| Pipe form of the `error` slot — accepts a builder directly (no `.toElement`).
-}
withError :
    B.Builder childRow childAttrCaps childSlotCaps Component.ErrorSlot msg
    -> Builder attrCaps { s | error : Available } msg kind
    -> Builder attrCaps { s | error : Used } msg kind
withError slotBuilder builder_ =
    B.withChild (El.toNode (Component.error (B.toElement slotBuilder))) builder_


{-| Pipe form of the `error-icon` slot — accepts a builder directly (no `.toElement`).
-}
withErrorIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ErrorIconSlot msg
    -> Builder attrCaps { s | errorIcon : Available } msg kind
    -> Builder attrCaps { s | errorIcon : Used } msg kind
withErrorIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.errorIcon (B.toElement slotBuilder))) builder_


{-| Pipe form of the `hint` slot — accepts a builder directly (no `.toElement`).
-}
withHint :
    B.Builder childRow childAttrCaps childSlotCaps Component.HintSlot msg
    -> Builder attrCaps { s | hint : Available } msg kind
    -> Builder attrCaps { s | hint : Used } msg kind
withHint slotBuilder builder_ =
    B.withChild (El.toNode (Component.hint (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `completed` — consumes its capability (write-once).
-}
withCompleted : Bool -> Builder { a | completed : Available } slotCaps msg kind -> Builder { a | completed : Used } slotCaps msg kind
withCompleted value_ =
    B.withAttribute (A.completed value_)


{-| Pipe form of `disabled` — consumes its capability (write-once).
-}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| Pipe form of `editable` — consumes its capability (write-once).
-}
withEditable : Bool -> Builder { a | editable : Available } slotCaps msg kind -> Builder { a | editable : Used } slotCaps msg kind
withEditable value_ =
    B.withAttribute (A.editable value_)


{-| Pipe form of `for` — consumes its capability (write-once).
-}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| Pipe form of `invalid` — consumes its capability (write-once).
-}
withInvalid : Bool -> Builder { a | invalid : Available } slotCaps msg kind -> Builder { a | invalid : Used } slotCaps msg kind
withInvalid value_ =
    B.withAttribute (A.invalid value_)


{-| Pipe form of `optional` — consumes its capability (write-once).
-}
withOptional : Bool -> Builder { a | optional : Available } slotCaps msg kind -> Builder { a | optional : Used } slotCaps msg kind
withOptional value_ =
    B.withAttribute (A.optional value_)


{-| Pipe form of `selected` — consumes its capability (write-once).
-}
withSelected : Bool -> Builder { a | selected : Available } slotCaps msg kind -> Builder { a | selected : Used } slotCaps msg kind
withSelected value_ =
    B.withAttribute (A.selected value_)


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
