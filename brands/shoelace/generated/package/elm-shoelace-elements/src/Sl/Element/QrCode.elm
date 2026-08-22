module Sl.Element.QrCode exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , ErrorCorrection, errorCorrection
    , background, fill, label, radius, size, value, defaultValue
    )

{-| The `sl-qr-code` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs ErrorCorrection, errorCorrection
@docs background, fill, label, radius, size, value, defaultValue

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import Sl.Attributes as A
import Sl.Html as H
import Sl.Internal.Types.QrCode
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-qr-code` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.QrCode.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.QrCode.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.QrCode.ChildAdmittedBy childAdm


{-| The `errorCorrection` values valid on this component (compile-tight narrowing).
-}
type alias ErrorCorrection =
    Sl.Internal.Types.QrCode.ErrorCorrection


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.QrCode.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.QrCode.AttrCaps


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
    H.qrCode


{-| The level of error correction to use. [Learn more](https://www.qrcode.com/en/about/error_correction.html) (default: `'H'`)
-}
errorCorrection : Value ErrorCorrection -> Attr { c | errorCorrection : Supported } msg
errorCorrection value_ =
    Ir.attribute "error-correction" (Val.toString value_)


{-| See `Sl.Attributes.background`.
-}
background : String -> Attr { c | background : Supported } msg
background =
    A.background


{-| See `Sl.Attributes.fill`.
-}
fill : String -> Attr { c | fill : Supported } msg
fill =
    A.fill


{-| See `Sl.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    A.label


{-| See `Sl.Attributes.radius`.
-}
radius : Float -> Attr { c | radius : Supported } msg
radius =
    A.radius


{-| The size of the QR code, in pixels. (default: `128`)
-}
size : Float -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (String.fromFloat value_)


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
