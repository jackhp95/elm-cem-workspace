module M3e.Component.Card exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Orientation, orientation, Type, type_, Variant, variant
    , actionable, disabled, disabledInteractive, download, href, inline, name, rel, target, value, defaultValue, onClick
    , actions, content, footer, header, child
    )

{-| The `m3e-card` component — strict per-component surface.

A content container for text, images (or other media), and actions in the context of a single subject.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Orientation, orientation, Type, type_, Variant, variant
@docs actionable, disabled, disabledInteractive, download, href, inline, name, rel, target, value, defaultValue, onClick
@docs actions, content, footer, header, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Card
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-card` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Card.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Card.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Card.ChildAdmittedBy childAdm


{-| The `orientation` values valid on this component (compile-tight narrowing).
-}
type alias Orientation =
    M3e.Internal.Types.Card.Orientation


{-| The `type_` values valid on this component (compile-tight narrowing).
-}
type alias Type =
    M3e.Internal.Types.Card.Type


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.Card.Variant


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Card.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Card.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.Card.SlotCaps


{-| Standard constructor: `[attributes] [children]`. The default slot is
kind-permissive (`any`): children of any kind compose, but each child's OWN
admittedBy must still admit this context — a restricted-parent element is
rejected here at compile time.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.card


{-| The orientation of the card. (default: `"vertical"`)
-}
orientation : Value Orientation -> Attr { c | orientation : Supported } msg
orientation value_ =
    Ir.attribute "orientation" (Val.toString value_)


{-| The type of the element. (default: `"button"`)
-}
type_ : Value Type -> Attr { c | type_ : Supported } msg
type_ value_ =
    Ir.attribute "type" (Val.toString value_)


{-| The appearance variant of the card. (default: `"filled"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.actionable`.
-}
actionable : Bool -> Attr { c | actionable : Supported } msg
actionable =
    A.actionable


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


{-| See `M3e.Attributes.inline`.
-}
inline : Bool -> Attr { c | inline : Supported } msg
inline =
    A.inline


{-| The name of the element, submitted as a pair with the element's `value`
as part of form data, when the element is used to submit a form.
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


{-| Place an element into the named `actions` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
actions : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
actions element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "actions") (El.toNode element))


{-| Place an element into the named `content` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
content : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
content element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "content") (El.toNode element))


{-| Place an element into the named `footer` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
footer : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
footer element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "footer") (El.toNode element))


{-| Place an element into the named `header` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
header : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
header element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "header") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
