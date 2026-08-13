module M3e.Component.LinearProgressIndicator exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , Mode, mode, Variant, variant
    , bufferValue, max, value, defaultValue
    )

{-| The `m3e-linear-progress-indicator` component — strict per-component surface.

A horizontal bar for indicating progress and activity.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs Mode, mode, Variant, variant
@docs bufferValue, max, value, defaultValue

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.LinearProgressIndicator
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-linear-progress-indicator` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.LinearProgressIndicator.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.LinearProgressIndicator.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.LinearProgressIndicator.ChildAdmittedBy childAdm


{-| The `mode` values valid on this component (compile-tight narrowing).
-}
type alias Mode =
    M3e.Internal.Types.LinearProgressIndicator.Mode


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.LinearProgressIndicator.Variant


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.linearProgressIndicator


{-| The mode of the progress bar. (default: `"determinate"`)
-}
mode : Value Mode -> Attr { c | mode : Supported } msg
mode value_ =
    Ir.attribute "mode" (Val.toString value_)


{-| The appearance of the indicator. (default: `"flat"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.bufferValue`.
-}
bufferValue : Float -> Attr { c | bufferValue : Supported } msg
bufferValue =
    A.bufferValue


{-| See `M3e.Attributes.max`.
-}
max : Float -> Attr { c | max : Supported } msg
max =
    A.max


{-| A fractional value, between 0 and `max`, indicating progress. (default: `0`)

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
