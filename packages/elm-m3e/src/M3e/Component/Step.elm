module M3e.Component.Step exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, DoneIconSlot, EditIconSlot, ErrorSlot, ErrorIconSlot, HintSlot, IconSlot, ChildAdmittedBy
    , completed, disabled, editable, for, invalid, optional, selected, defaultSelected, onBeforeinput, onInput, onChange, onClick
    , doneIcon, editIcon, error, errorIcon, hint, icon, child
    )

{-| The `m3e-step` component — strict per-component surface.

A step in a wizard-like workflow.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, DoneIconSlot, EditIconSlot, ErrorSlot, ErrorIconSlot, HintSlot, IconSlot, ChildAdmittedBy
@docs completed, disabled, editable, for, invalid, optional, selected, defaultSelected, onBeforeinput, onInput, onChange, onClick
@docs doneIcon, editIcon, error, errorIcon, hint, icon, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Step
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-step` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Step.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Step.Attrs


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


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Step.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Step.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Step.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.Step.SlotCaps


{-| Required-content (and action) constructor — omissions are unwritable.
-}
component :
    { content : Element Content (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component required_ attrs children =
    H.step attrs (required_.content :: children)


{-| See `M3e.Attributes.completed`.
-}
completed : Bool -> Attr { c | completed : Supported } msg
completed =
    A.completed


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.editable`.
-}
editable : Bool -> Attr { c | editable : Supported } msg
editable =
    A.editable


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for


{-| See `M3e.Attributes.invalid`.
-}
invalid : Bool -> Attr { c | invalid : Supported } msg
invalid =
    A.invalid


{-| See `M3e.Attributes.optional`.
-}
optional : Bool -> Attr { c | optional : Supported } msg
optional =
    A.optional


{-| See `M3e.Attributes.selected`.
-}
selected : Bool -> Attr { c | selected : Supported } msg
selected =
    A.selected


{-| See `M3e.Attributes.defaultSelected`.
-}
defaultSelected : Bool -> Attr { c | selected : Supported } msg
defaultSelected =
    A.defaultSelected


{-| See `M3e.Events.onBeforeinput`.
-}
onBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
onBeforeinput =
    Ev.onBeforeinput


{-| See `M3e.Events.onInput`.
-}
onInput : msg -> Attr { c | onInput : Supported } msg
onInput =
    Ev.onInput


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| See `M3e.Events.onClick`.
-}
onClick : msg -> Attr { c | onClick : Supported } msg
onClick =
    Ev.onClick


{-| Place an element into the named `done-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
doneIcon : Element DoneIconSlot admittedBy msg -> Element free freeAdmittedBy msg
doneIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "done-icon") (El.toNode element))


{-| Place an element into the named `edit-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
editIcon : Element EditIconSlot admittedBy msg -> Element free freeAdmittedBy msg
editIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "edit-icon") (El.toNode element))


{-| Place an element into the named `error` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
error : Element ErrorSlot admittedBy msg -> Element free freeAdmittedBy msg
error element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "error") (El.toNode element))


{-| Place an element into the named `error-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
errorIcon : Element ErrorIconSlot admittedBy msg -> Element free freeAdmittedBy msg
errorIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "error-icon") (El.toNode element))


{-| Place an element into the named `hint` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
hint : Element HintSlot admittedBy msg -> Element free freeAdmittedBy msg
hint element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "hint") (El.toNode element))


{-| Place an element into the named `icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
icon : Element IconSlot admittedBy msg -> Element free freeAdmittedBy msg
icon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "icon") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
