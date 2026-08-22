module Sl.Component.FormatBytes exposing (FormatBytesIs, FormatBytesAttrs, FormatBytesBuilder, FormatBytesAttrCaps, FormatBytesSlotCaps, FormatBytesChildAdmittedBy, FormatBytesDisplay, FormatBytesUnit, formatBytes, formatBytesDisplay, formatBytesUnit, formatBytesValue, formatBytesDefaultValue)

{-| The **FormatBytes** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.FormatBytes`](Sl.Element.FormatBytes) as `formatBytes`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs FormatBytesIs, FormatBytesAttrs, FormatBytesBuilder, FormatBytesAttrCaps, FormatBytesSlotCaps, FormatBytesChildAdmittedBy, FormatBytesDisplay, FormatBytesUnit, formatBytes, formatBytesDisplay, formatBytesUnit, formatBytesValue, formatBytesDefaultValue

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.FormatBytes as FormatBytes_


{-| The `formatBytes` element of this family — delegates to [`Sl.Element.FormatBytes.component`](Sl.Element.FormatBytes#component).
-}
formatBytes :
    List (Attr FormatBytesAttrs msg)
    -> List (Element childAccepts (FormatBytesChildAdmittedBy childAdm) msg)
    -> Element (FormatBytesIs s) admittedBy msg
formatBytes =
    FormatBytes_.component


{-| See [`Sl.Element.FormatBytes.Is`](Sl.Element.FormatBytes#Is).
-}
type alias FormatBytesIs s =
    FormatBytes_.Is s


{-| See [`Sl.Element.FormatBytes.Attrs`](Sl.Element.FormatBytes#Attrs).
-}
type alias FormatBytesAttrs =
    FormatBytes_.Attrs


{-| See [`Sl.Element.FormatBytes.Builder`](Sl.Element.FormatBytes#Builder).
-}
type alias FormatBytesBuilder attrCaps slotCaps msg kind =
    FormatBytes_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.FormatBytes.AttrCaps`](Sl.Element.FormatBytes#AttrCaps).
-}
type alias FormatBytesAttrCaps =
    FormatBytes_.AttrCaps


{-| See [`Sl.Element.FormatBytes.SlotCaps`](Sl.Element.FormatBytes#SlotCaps).
-}
type alias FormatBytesSlotCaps =
    FormatBytes_.SlotCaps


{-| See [`Sl.Element.FormatBytes.ChildAdmittedBy`](Sl.Element.FormatBytes#ChildAdmittedBy).
-}
type alias FormatBytesChildAdmittedBy childAdm =
    FormatBytes_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.FormatBytes.Display`](Sl.Element.FormatBytes#Display).
-}
type alias FormatBytesDisplay =
    FormatBytes_.Display


{-| See [`Sl.Element.FormatBytes.display`](Sl.Element.FormatBytes#display).
-}
formatBytesDisplay : Value FormatBytesDisplay -> Attr { c | display : Supported } msg
formatBytesDisplay =
    FormatBytes_.display


{-| See [`Sl.Element.FormatBytes.Unit`](Sl.Element.FormatBytes#Unit).
-}
type alias FormatBytesUnit =
    FormatBytes_.Unit


{-| See [`Sl.Element.FormatBytes.unit`](Sl.Element.FormatBytes#unit).
-}
formatBytesUnit : Value FormatBytesUnit -> Attr { c | unit : Supported } msg
formatBytesUnit =
    FormatBytes_.unit


{-| See [`Sl.Element.FormatBytes.value`](Sl.Element.FormatBytes#value).
-}
formatBytesValue : Float -> Attr { c | value : Supported } msg
formatBytesValue =
    FormatBytes_.value


{-| See [`Sl.Element.FormatBytes.defaultValue`](Sl.Element.FormatBytes#defaultValue).
-}
formatBytesDefaultValue : Float -> Attr { c | value : Supported } msg
formatBytesDefaultValue =
    FormatBytes_.defaultValue
