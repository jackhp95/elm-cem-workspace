module M3e.Component.Checkbox exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , checked, disabled, indeterminate, name, required, validationmessages, value, defaultChecked, defaultValue, onBeforeinput, onInput, onChange, onInvalid, onClick
    )

{-| The `m3e-checkbox` component — strict per-component surface.

A checkbox that allows a user to select one or more options from a limited number of choices.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs checked, disabled, indeterminate, name, required, validationmessages, value, defaultChecked, defaultValue, onBeforeinput, onInput, onChange, onInvalid, onClick

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Json.Encode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Checkbox
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-checkbox` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Checkbox.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Checkbox.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Checkbox.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Checkbox.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Checkbox.AttrCaps


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
    H.checkbox


{-| See `M3e.Attributes.checked`.
-}
checked : Bool -> Attr { c | checked : Supported } msg
checked =
    A.checked


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.indeterminate`.
-}
indeterminate : Bool -> Attr { c | indeterminate : Supported } msg
indeterminate =
    A.indeterminate


{-| The name that identifies the element when submitting the associated form.
-}
name : String -> Attr { c | name : Supported } msg
name value_ =
    Ir.attribute "name" value_


{-| See `M3e.Attributes.required`.
-}
required : Bool -> Attr { c | required : Supported } msg
required =
    A.required


{-| See `M3e.Attributes.validationmessages`.
-}
validationmessages : String -> Attr { c | validationmessages : Supported } msg
validationmessages =
    A.validationmessages


{-| See `M3e.Attributes.value`.
-}
value : String -> Attr { c | value : Supported } msg
value =
    A.value


{-| See `M3e.Attributes.defaultChecked`.
-}
defaultChecked : Bool -> Attr { c | checked : Supported } msg
defaultChecked =
    A.defaultChecked


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


{-| See `M3e.Events.onInvalid`.
-}
onInvalid : msg -> Attr { c | onInvalid : Supported } msg
onInvalid =
    Ev.onInvalid


{-| See `M3e.Events.onClick`.
-}
onClick : msg -> Attr { c | onClick : Supported } msg
onClick =
    Ev.onClick
