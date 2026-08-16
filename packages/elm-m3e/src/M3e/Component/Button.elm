module M3e.Component.Button exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, IconSlot, SelectedSlot, SelectedIconSlot, TrailingIconSlot, ChildAdmittedBy, ActionCaps
    , Shape, shape, Size, size, Type, type_, Variant, variant
    , disabled, disabledInteractive, download, href, name, rel, target, toggle, value, defaultValue, onBeforeinput, onInput, onChange, onClick
    , icon, selected, selectedIcon, trailingIcon, child
    )

{-| The `m3e-button` component — strict per-component surface.

A button users interact with to perform an action.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, IconSlot, SelectedSlot, SelectedIconSlot, TrailingIconSlot, ChildAdmittedBy, ActionCaps
@docs Shape, shape, Size, size, Type, type_, Variant, variant
@docs disabled, disabledInteractive, download, href, name, rel, target, toggle, value, defaultValue, onBeforeinput, onInput, onChange, onClick
@docs icon, selected, selectedIcon, trailingIcon, child

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
import M3e.Internal.Types.Button
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-button` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Button.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Button.Attrs


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


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Button.ChildAdmittedBy childAdm


{-| The `shape` values valid on this component (compile-tight narrowing).
-}
type alias Shape =
    M3e.Internal.Types.Button.Shape


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    M3e.Internal.Types.Button.Size


{-| The `type_` values valid on this component (compile-tight narrowing).
-}
type alias Type =
    M3e.Internal.Types.Button.Type


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.Button.Variant


{-| The behaviours this component's required action admits (see `M3e.Action`).
-}
type alias ActionCaps =
    M3e.Internal.Types.Button.ActionCaps


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Button.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Button.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.Button.SlotCaps


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
    H.button
        (Ac.toAttrs required_.action ++ attrs)
        (actioned :: children)


{-| The shape of the button. (default: `"rounded"`)
-}
shape : Value Shape -> Attr { c | shape : Supported } msg
shape value_ =
    Ir.attribute "shape" (Val.toString value_)


{-| The size of the button. (default: `"small"`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| The type of the element. (default: `"button"`)
-}
type_ : Value Type -> Attr { c | type_ : Supported } msg
type_ value_ =
    Ir.attribute "type" (Val.toString value_)


{-| The appearance variant of the button. (default: `"text"`)
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


{-| See `M3e.Attributes.href`.
-}
href : String -> Attr { c | href : Supported } msg
href =
    A.href


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


{-| See `M3e.Attributes.toggle`.
-}
toggle : Bool -> Attr { c | toggle : Supported } msg
toggle =
    A.toggle


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


{-| Place an element into the named `icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
icon : Element IconSlot admittedBy msg -> Element free freeAdmittedBy msg
icon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "icon") (El.toNode element))


{-| Place an element into the named `selected` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
selected : Element SelectedSlot admittedBy msg -> Element free freeAdmittedBy msg
selected element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "selected") (El.toNode element))


{-| Place an element into the named `selected-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
selectedIcon : Element SelectedIconSlot admittedBy msg -> Element free freeAdmittedBy msg
selectedIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "selected-icon") (El.toNode element))


{-| Place an element into the named `trailing-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
trailingIcon : Element TrailingIconSlot admittedBy msg -> Element free freeAdmittedBy msg
trailingIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "trailing-icon") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
