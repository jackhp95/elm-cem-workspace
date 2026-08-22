module Sl.Element.Button exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , Formenctype, formenctype, Formmethod, formmethod, Formtarget, formtarget, Size, size, Target, target, Type, type_, Variant, variant
    , caret, circle, disabled, download, form, formnovalidate, href, loading, name, outline, pill, rel, title, value, defaultValue, onBlur, onFocus, onInvalid
    , child
    )

{-| The `sl-button` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs Formenctype, formenctype, Formmethod, formmethod, Formtarget, formtarget, Size, size, Target, target, Type, type_, Variant, variant
@docs caret, circle, disabled, download, form, formnovalidate, href, loading, name, outline, pill, rel, title, value, defaultValue, onBlur, onFocus, onInvalid
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Button
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-button` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Button.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Button.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Sl.Internal.Types.Button.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Button.ChildAdmittedBy childAdm


{-| The `formenctype` values valid on this component (compile-tight narrowing).
-}
type alias Formenctype =
    Sl.Internal.Types.Button.Formenctype


{-| The `formmethod` values valid on this component (compile-tight narrowing).
-}
type alias Formmethod =
    Sl.Internal.Types.Button.Formmethod


{-| The `formtarget` values valid on this component (compile-tight narrowing).
-}
type alias Formtarget =
    Sl.Internal.Types.Button.Formtarget


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    Sl.Internal.Types.Button.Size


{-| The `target` values valid on this component (compile-tight narrowing).
-}
type alias Target =
    Sl.Internal.Types.Button.Target


{-| The `type_` values valid on this component (compile-tight narrowing).
-}
type alias Type =
    Sl.Internal.Types.Button.Type


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    Sl.Internal.Types.Button.Variant


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Button.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Button.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.button


{-| Used to override the form owner's `enctype` attribute.
-}
formenctype : Value Formenctype -> Attr { c | formenctype : Supported } msg
formenctype value_ =
    Ir.attribute "formenctype" (Val.toString value_)


{-| Used to override the form owner's `method` attribute.
-}
formmethod : Value Formmethod -> Attr { c | formmethod : Supported } msg
formmethod value_ =
    Ir.attribute "formmethod" (Val.toString value_)


{-| Used to override the form owner's `target` attribute.
-}
formtarget : Value Formtarget -> Attr { c | formtarget : Supported } msg
formtarget value_ =
    Ir.attribute "formtarget" (Val.toString value_)


{-| The button's size. (default: `'medium'`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| Tells the browser where to open the link. Only used when `href` is present.
-}
target : Value Target -> Attr { c | target : Supported } msg
target value_ =
    Ir.attribute "target" (Val.toString value_)


{-| The type of button. Note that the default value is `button` instead of `submit`, which is opposite of how native
`<button>` elements behave. When the type is `submit`, the button will submit the surrounding form. (default: `'button'`)
-}
type_ : Value Type -> Attr { c | type_ : Supported } msg
type_ value_ =
    Ir.attribute "type" (Val.toString value_)


{-| The button's theme variant. (default: `'default'`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `Sl.Attributes.caret`.
-}
caret : Bool -> Attr { c | caret : Supported } msg
caret =
    A.caret


{-| See `Sl.Attributes.circle`.
-}
circle : Bool -> Attr { c | circle : Supported } msg
circle =
    A.circle


{-| See `Sl.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `Sl.Attributes.download`.
-}
download : String -> Attr { c | download : Supported } msg
download =
    A.download


{-| See `Sl.Attributes.form`.
-}
form : String -> Attr { c | form : Supported } msg
form =
    A.form


{-| See `Sl.Attributes.formnovalidate`.
-}
formnovalidate : Bool -> Attr { c | formnovalidate : Supported } msg
formnovalidate =
    A.formnovalidate


{-| See `Sl.Attributes.href`.
-}
href : String -> Attr { c | href : Supported } msg
href =
    A.href


{-| Draws the button in a loading state. (default: `false`)
-}
loading : Bool -> Attr { c | loading : Supported } msg
loading value_ =
    if value_ then
        Ir.attribute "loading" ""

    else
        Ir.none


{-| See `Sl.Attributes.name`.
-}
name : String -> Attr { c | name : Supported } msg
name =
    A.name


{-| See `Sl.Attributes.outline`.
-}
outline : Bool -> Attr { c | outline : Supported } msg
outline =
    A.outline


{-| See `Sl.Attributes.pill`.
-}
pill : Bool -> Attr { c | pill : Supported } msg
pill =
    A.pill


{-| See `Sl.Attributes.rel`.
-}
rel : String -> Attr { c | rel : Supported } msg
rel =
    A.rel


{-| See `Sl.Attributes.title`.
-}
title : String -> Attr { c | title : Supported } msg
title =
    A.title


{-| See `Sl.Attributes.value`.
-}
value : String -> Attr { c | value : Supported } msg
value =
    A.value


{-| See `Sl.Attributes.defaultValue`.
-}
defaultValue : String -> Attr { c | value : Supported } msg
defaultValue =
    A.defaultValue


{-| See `Sl.Events.onBlur`.
-}
onBlur : msg -> Attr { c | onBlur : Supported } msg
onBlur =
    Ev.onBlur


{-| See `Sl.Events.onFocus`.
-}
onFocus : msg -> Attr { c | onFocus : Supported } msg
onFocus =
    Ev.onFocus


{-| See `Sl.Events.onInvalid`.
-}
onInvalid : msg -> Attr { c | onInvalid : Supported } msg
onInvalid =
    Ev.onInvalid


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
