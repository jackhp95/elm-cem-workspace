module Sl.Element.Range exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Tooltip, tooltip
    , disabled, form, helpText, label, max, min, name, step, title, value, defaultValue, onBlur, onChange, onFocus, onInput, onInvalid
    )

{-| The `sl-range` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Tooltip, tooltip
@docs disabled, form, helpText, label, max, min, name, step, title, value, defaultValue, onBlur, onChange, onFocus, onInput, onInvalid

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Range
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-range` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Range.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Range.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Range.ChildAdmittedBy childAdm


{-| The `tooltip` values valid on this component (compile-tight narrowing).
-}
type alias Tooltip =
    Sl.Internal.Types.Range.Tooltip


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Range.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Range.AttrCaps


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
    H.range


{-| The preferred placement of the range's tooltip. (default: `'top'`)
-}
tooltip : Value Tooltip -> Attr { c | tooltip : Supported } msg
tooltip value_ =
    Ir.attribute "tooltip" (Val.toString value_)


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


{-| See `Sl.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    A.label


{-| The maximum acceptable value of the range. (default: `100`)
-}
max : Float -> Attr { c | max : Supported } msg
max value_ =
    Ir.attribute "max" (String.fromFloat value_)


{-| The minimum acceptable value of the range. (default: `0`)
-}
min : Float -> Attr { c | min : Supported } msg
min value_ =
    Ir.attribute "min" (String.fromFloat value_)


{-| See `Sl.Attributes.name`.
-}
name : String -> Attr { c | name : Supported } msg
name =
    A.name


{-| The interval at which the range will increase and decrease. (default: `1`)
-}
step : Float -> Attr { c | step : Supported } msg
step value_ =
    Ir.attribute "step" (String.fromFloat value_)


{-| See `Sl.Attributes.title`.
-}
title : String -> Attr { c | title : Supported } msg
title =
    A.title


{-| The current value of the range, submitted as a name/value pair with form data. (default: `0`)

Sets the LIVE DOM property `value`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultValue`.

-}
value : Float -> Attr { c | value : Supported } msg
value value_ =
    Ir.property "value" (Json.Encode.float value_)


{-| Set the `value` CONTENT attribute — the element's DEFAULT/initial `value`, mirroring HTML's own `defaultValue` IDL attribute. Unlike `value` (which writes the live DOM property) this one SERIALIZES: it is what server-rendered markup and `outerHTML` show, and it is what a form reset restores to.
-}
defaultValue : Float -> Attr { c | value : Supported } msg
defaultValue value_ =
    Ir.attribute "value" (String.fromFloat value_)


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


{-| See `Sl.Events.onFocus`.
-}
onFocus : msg -> Attr { c | onFocus : Supported } msg
onFocus =
    Ev.onFocus


{-| See `Sl.Events.onInput`.
-}
onInput : msg -> Attr { c | onInput : Supported } msg
onInput =
    Ev.onInput


{-| See `Sl.Events.onInvalid`.
-}
onInvalid : msg -> Attr { c | onInvalid : Supported } msg
onInvalid =
    Ev.onInvalid
