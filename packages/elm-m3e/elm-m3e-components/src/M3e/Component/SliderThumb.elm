module M3e.Component.SliderThumb exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , disabled, name, value, defaultValue, onValueChange, onBeforeinput, onInput, onChange, onClick
    )

{-| The `m3e-slider-thumb` component — strict per-component surface.

A thumb used to select a value in a slider.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs disabled, name, value, defaultValue, onValueChange, onBeforeinput, onInput, onChange, onClick

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Json.Encode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.SliderThumb
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-slider-thumb` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.SliderThumb.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.SliderThumb.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.SliderThumb.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.sliderThumb


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| The name that identifies the element when submitting the associated form.
-}
name : String -> Attr { c | name : Supported } msg
name value_ =
    Ir.attribute "name" value_


{-| The value of the thumb. (default: `null`)

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


{-| See `M3e.Events.onValueChange`.
-}
onValueChange : msg -> Attr { c | onValueChange : Supported } msg
onValueChange =
    Ev.onValueChange


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
