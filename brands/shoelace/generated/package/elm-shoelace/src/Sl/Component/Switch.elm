module Sl.Component.Switch exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Size, size
    , checked, disabled, form, helpText, name, required, title, value, defaultChecked, defaultValue, onBlur, onChange, onInput, onFocus, onInvalid
    )

{-| The `sl-switch` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Size, size
@docs checked, disabled, form, helpText, name, required, title, value, defaultChecked, defaultValue, onBlur, onChange, onInput, onFocus, onInvalid

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Switch
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-switch` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Switch.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Switch.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Switch.ChildAdmittedBy childAdm


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    Sl.Internal.Types.Switch.Size


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Switch.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Switch.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.switch


{-| The switch's size. (default: `'medium'`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| See `Sl.Attributes.checked`.
-}
checked : Bool -> Attr { c | checked : Supported } msg
checked =
    A.checked


{-| See `Sl.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `Sl.Attributes.form`.
-}
form : String -> Attr { c | form : Supported } msg
form =
    A.form


{-| See `Sl.Attributes.helpText`.
-}
helpText : String -> Attr { c | helpText : Supported } msg
helpText =
    A.helpText


{-| See `Sl.Attributes.name`.
-}
name : String -> Attr { c | name : Supported } msg
name =
    A.name


{-| See `Sl.Attributes.required`.
-}
required : Bool -> Attr { c | required : Supported } msg
required =
    A.required


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


{-| See `Sl.Attributes.defaultChecked`.
-}
defaultChecked : Bool -> Attr { c | checked : Supported } msg
defaultChecked =
    A.defaultChecked


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


{-| See `Sl.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| See `Sl.Events.onInput`.
-}
onInput : msg -> Attr { c | onInput : Supported } msg
onInput =
    Ev.onInput


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
