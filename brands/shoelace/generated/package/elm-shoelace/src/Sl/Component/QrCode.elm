module Sl.Component.QrCode exposing (QrCodeIs, QrCodeAttrs, QrCodeBuilder, QrCodeAttrCaps, QrCodeSlotCaps, QrCodeChildAdmittedBy, QrCodeErrorCorrection, qrCode, qrCodeErrorCorrection, qrCodeBackground, qrCodeFill, qrCodeLabel, qrCodeRadius, qrCodeSize, qrCodeValue, qrCodeDefaultValue)

{-| The **QrCode** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.QrCode`](Sl.Element.QrCode) as `qrCode`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs QrCodeIs, QrCodeAttrs, QrCodeBuilder, QrCodeAttrCaps, QrCodeSlotCaps, QrCodeChildAdmittedBy, QrCodeErrorCorrection, qrCode, qrCodeErrorCorrection, qrCodeBackground, qrCodeFill, qrCodeLabel, qrCodeRadius, qrCodeSize, qrCodeValue, qrCodeDefaultValue

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.QrCode as QrCode_


{-| The `qrCode` element of this family — delegates to [`Sl.Element.QrCode.component`](Sl.Element.QrCode#component).
-}
qrCode :
    List (Attr QrCodeAttrs msg)
    -> List (Element childAccepts (QrCodeChildAdmittedBy childAdm) msg)
    -> Element (QrCodeIs s) admittedBy msg
qrCode =
    QrCode_.component


{-| See [`Sl.Element.QrCode.Is`](Sl.Element.QrCode#Is).
-}
type alias QrCodeIs s =
    QrCode_.Is s


{-| See [`Sl.Element.QrCode.Attrs`](Sl.Element.QrCode#Attrs).
-}
type alias QrCodeAttrs =
    QrCode_.Attrs


{-| See [`Sl.Element.QrCode.Builder`](Sl.Element.QrCode#Builder).
-}
type alias QrCodeBuilder attrCaps slotCaps msg kind =
    QrCode_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.QrCode.AttrCaps`](Sl.Element.QrCode#AttrCaps).
-}
type alias QrCodeAttrCaps =
    QrCode_.AttrCaps


{-| See [`Sl.Element.QrCode.SlotCaps`](Sl.Element.QrCode#SlotCaps).
-}
type alias QrCodeSlotCaps =
    QrCode_.SlotCaps


{-| See [`Sl.Element.QrCode.ChildAdmittedBy`](Sl.Element.QrCode#ChildAdmittedBy).
-}
type alias QrCodeChildAdmittedBy childAdm =
    QrCode_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.QrCode.ErrorCorrection`](Sl.Element.QrCode#ErrorCorrection).
-}
type alias QrCodeErrorCorrection =
    QrCode_.ErrorCorrection


{-| See [`Sl.Element.QrCode.errorCorrection`](Sl.Element.QrCode#errorCorrection).
-}
qrCodeErrorCorrection : Value QrCodeErrorCorrection -> Attr { c | errorCorrection : Supported } msg
qrCodeErrorCorrection =
    QrCode_.errorCorrection


{-| See [`Sl.Element.QrCode.background`](Sl.Element.QrCode#background).
-}
qrCodeBackground : String -> Attr { c | background : Supported } msg
qrCodeBackground =
    QrCode_.background


{-| See [`Sl.Element.QrCode.fill`](Sl.Element.QrCode#fill).
-}
qrCodeFill : String -> Attr { c | fill : Supported } msg
qrCodeFill =
    QrCode_.fill


{-| See [`Sl.Element.QrCode.label`](Sl.Element.QrCode#label).
-}
qrCodeLabel : String -> Attr { c | label : Supported } msg
qrCodeLabel =
    QrCode_.label


{-| See [`Sl.Element.QrCode.radius`](Sl.Element.QrCode#radius).
-}
qrCodeRadius : Float -> Attr { c | radius : Supported } msg
qrCodeRadius =
    QrCode_.radius


{-| See [`Sl.Element.QrCode.size`](Sl.Element.QrCode#size).
-}
qrCodeSize : Float -> Attr { c | size : Supported } msg
qrCodeSize =
    QrCode_.size


{-| See [`Sl.Element.QrCode.value`](Sl.Element.QrCode#value).
-}
qrCodeValue : String -> Attr { c | value : Supported } msg
qrCodeValue =
    QrCode_.value


{-| See [`Sl.Element.QrCode.defaultValue`](Sl.Element.QrCode#defaultValue).
-}
qrCodeDefaultValue : String -> Attr { c | value : Supported } msg
qrCodeDefaultValue =
    QrCode_.defaultValue
