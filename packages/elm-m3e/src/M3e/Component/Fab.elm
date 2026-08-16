module M3e.Component.Fab exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, CloseIconSlot, LabelSlot, ChildAdmittedBy, ActionCaps
    , Size, size, Type, type_, Variant, variant
    , disabled, disabledInteractive, download, extended, href, lowered, name, rel, target, value, defaultValue, onClick
    , closeIcon, label, child
    )

{-| The `m3e-fab` component — strict per-component surface.

A floating action button (FAB) used to present important actions.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, CloseIconSlot, LabelSlot, ChildAdmittedBy, ActionCaps
@docs Size, size, Type, type_, Variant, variant
@docs disabled, disabledInteractive, download, extended, href, lowered, name, rel, target, value, defaultValue, onClick
@docs closeIcon, label, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import M3e.Action as Ac
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Fab
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-fab` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Fab.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Fab.Attrs


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


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Fab.ChildAdmittedBy childAdm


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    M3e.Internal.Types.Fab.Size


{-| The `type_` values valid on this component (compile-tight narrowing).
-}
type alias Type =
    M3e.Internal.Types.Fab.Type


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.Fab.Variant


{-| The behaviours this component's required action admits (see `M3e.Action`).
-}
type alias ActionCaps =
    M3e.Internal.Types.Fab.ActionCaps


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Fab.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Fab.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.Fab.SlotCaps


{-| Required-content (and action) constructor — omissions are unwritable.
-}
component :
    { content : Element Content (ChildAdmittedBy childAdm) msg
    , action : Ac.Action ActionCaps msg
    }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component required_ attrs children =
    let
        actioned =
            Ir.fromNode (Ac.wrapContent required_.action (El.toNode required_.content))
    in
    H.fab
        (Ac.toAttrs required_.action ++ attrs)
        (actioned :: children)


{-| The size of the button. (default: `"medium"`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| The type of the element. (default: `"button"`)
-}
type_ : Value Type -> Attr { c | type_ : Supported } msg
type_ value_ =
    Ir.attribute "type" (Val.toString value_)


{-| The appearance variant of the button. (default: `"primary-container"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.disabledInteractive`.
-}
disabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
disabledInteractive =
    A.disabledInteractive


{-| See `M3e.Attributes.download`.
-}
download : String -> Attr { c | download : Supported } msg
download =
    A.download


{-| See `M3e.Attributes.extended`.
-}
extended : Bool -> Attr { c | extended : Supported } msg
extended =
    A.extended


{-| See `M3e.Attributes.href`.
-}
href : String -> Attr { c | href : Supported } msg
href =
    A.href


{-| See `M3e.Attributes.lowered`.
-}
lowered : Bool -> Attr { c | lowered : Supported } msg
lowered =
    A.lowered


{-| The name of the element, submitted as a pair with the element's `value` as part of form data, when the element is used to submit a form.
-}
name : String -> Attr { c | name : Supported } msg
name value_ =
    Ir.attribute "name" value_


{-| See `M3e.Attributes.rel`.
-}
rel : String -> Attr { c | rel : Supported } msg
rel =
    A.rel


{-| See `M3e.Attributes.target`.
-}
target : String -> Attr { c | target : Supported } msg
target =
    A.target


{-| See `M3e.Attributes.value`.
-}
value : String -> Attr { c | value : Supported } msg
value =
    A.value


{-| See `M3e.Attributes.defaultValue`.
-}
defaultValue : String -> Attr { c | value : Supported } msg
defaultValue =
    A.defaultValue


{-| See `M3e.Events.onClick`.
-}
onClick : msg -> Attr { c | onClick : Supported } msg
onClick =
    Ev.onClick


{-| Place an element into the named `close-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
closeIcon : Element CloseIconSlot admittedBy msg -> Element free freeAdmittedBy msg
closeIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "close-icon") (El.toNode element))


{-| Place an element into the named `label` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
label : Element LabelSlot admittedBy msg -> Element free freeAdmittedBy msg
label element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "label") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
