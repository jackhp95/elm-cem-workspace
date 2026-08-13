module M3e.Component.InputChip exposing
    ( view, el
    , Is, Attrs, Content, AvatarSlot, IconSlot, RemoveIconSlot, ChildAdmittedBy
    , Variant, variant
    , disabled, disabledInteractive, removable, removeLabel, value, defaultValue, onRemove, onClick
    , avatar, icon, removeIcon, child
    )

{-| The `m3e-input-chip` component — strict per-component surface.

A chip which represents a discrete piece of information entered by a user.

@docs view, el
@docs Is, Attrs, Content, AvatarSlot, IconSlot, RemoveIconSlot, ChildAdmittedBy
@docs Variant, variant
@docs disabled, disabledInteractive, removable, removeLabel, value, defaultValue, onRemove, onClick
@docs avatar, icon, removeIcon, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.InputChip
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-input-chip` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.InputChip.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.InputChip.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.InputChip.Content


{-| The kinds the `avatar` slot admits.
-}
type alias AvatarSlot =
    M3e.Internal.Types.InputChip.AvatarSlot


{-| The kinds the `icon` slot admits.
-}
type alias IconSlot =
    M3e.Internal.Types.InputChip.IconSlot


{-| The kinds the `remove-icon` slot admits.
-}
type alias RemoveIconSlot =
    M3e.Internal.Types.InputChip.RemoveIconSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.InputChip.ChildAdmittedBy childAdm


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.InputChip.Variant


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.inputChip


{-| Required-content (and action) constructor — omissions are unwritable.
-}
el :
    { content : Element Content (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
el required_ attrs children =
    view attrs (required_.content :: children)


{-| The appearance variant of the chip. (default: `"outlined"`)
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


{-| See `M3e.Attributes.removable`.
-}
removable : Bool -> Attr { c | removable : Supported } msg
removable =
    A.removable


{-| See `M3e.Attributes.removeLabel`.
-}
removeLabel : String -> Attr { c | removeLabel : Supported } msg
removeLabel =
    A.removeLabel


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


{-| See `M3e.Events.onRemove`.
-}
onRemove : msg -> Attr { c | onRemove : Supported } msg
onRemove =
    Ev.onRemove


{-| See `M3e.Events.onClick`.
-}
onClick : msg -> Attr { c | onClick : Supported } msg
onClick =
    Ev.onClick


{-| Place an element into the named `avatar` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
avatar : Element AvatarSlot admittedBy msg -> Element free freeAdmittedBy msg
avatar element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "avatar") (El.toNode element))


{-| Place an element into the named `icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
icon : Element IconSlot admittedBy msg -> Element free freeAdmittedBy msg
icon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "icon") (El.toNode element))


{-| Place an element into the named `remove-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
removeIcon : Element RemoveIconSlot admittedBy msg -> Element free freeAdmittedBy msg
removeIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "remove-icon") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
