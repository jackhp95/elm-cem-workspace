module M3e.Component.AssistChip exposing
    ( view, el
    , Is, Attrs, Content, IconSlot, ChildAdmittedBy
    , Type, type_, Variant, variant
    , disabled, disabledInteractive, download, href, name, rel, target, value, defaultValue, onClick
    , icon, child
    )

{-| The `m3e-assist-chip` component — strict per-component surface.

A chip users interact with to perform a smart or automated action that can span multiple applications.

@docs view, el
@docs Is, Attrs, Content, IconSlot, ChildAdmittedBy
@docs Type, type_, Variant, variant
@docs disabled, disabledInteractive, download, href, name, rel, target, value, defaultValue, onClick
@docs icon, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.AssistChip
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-assist-chip` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.AssistChip.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.AssistChip.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.AssistChip.Content


{-| The kinds the `icon` slot admits.
-}
type alias IconSlot =
    M3e.Internal.Types.AssistChip.IconSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.AssistChip.ChildAdmittedBy childAdm


{-| The `type_` values valid on this component (compile-tight narrowing).
-}
type alias Type =
    M3e.Internal.Types.AssistChip.Type


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.AssistChip.Variant


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.assistChip


{-| Required-content (and action) constructor — omissions are unwritable.
-}
el :
    { content : Element Content (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
el required_ attrs children =
    view attrs (required_.content :: children)


{-| The type of the element. (default: `"button"`)
-}
type_ : Value Type -> Attr { c | type_ : Supported } msg
type_ value_ =
    Ir.attribute "type" (Val.toString value_)


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
