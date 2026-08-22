module Hz.Component2.ErrorOnly exposing (ErrorOnlyIs, ErrorOnlyAttrs, ErrorOnlyBuilder, ErrorOnlyAttrCaps, ErrorOnlySlotCaps, ErrorOnlyChildAdmittedBy, errorOnly, errorOnlyOnHzError)

{-| The **ErrorOnly** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Hz.Element.ErrorOnly`](Hz.Element.ErrorOnly) as `errorOnly`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ErrorOnlyIs, ErrorOnlyAttrs, ErrorOnlyBuilder, ErrorOnlyAttrCaps, ErrorOnlySlotCaps, ErrorOnlyChildAdmittedBy, errorOnly, errorOnlyOnHzError

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Hz.Element.ErrorOnly as ErrorOnly_


{-| The `errorOnly` element of this family — delegates to [`Hz.Element.ErrorOnly.component`](Hz.Element.ErrorOnly#component).
-}
errorOnly :
    List (Attr ErrorOnlyAttrs msg)
    -> List (Element childAccepts (ErrorOnlyChildAdmittedBy childAdm) msg)
    -> Element (ErrorOnlyIs s) admittedBy msg
errorOnly =
    ErrorOnly_.component


{-| See [`Hz.Element.ErrorOnly.Is`](Hz.Element.ErrorOnly#Is).
-}
type alias ErrorOnlyIs s =
    ErrorOnly_.Is s


{-| See [`Hz.Element.ErrorOnly.Attrs`](Hz.Element.ErrorOnly#Attrs).
-}
type alias ErrorOnlyAttrs =
    ErrorOnly_.Attrs


{-| See [`Hz.Element.ErrorOnly.Builder`](Hz.Element.ErrorOnly#Builder).
-}
type alias ErrorOnlyBuilder attrCaps slotCaps msg kind =
    ErrorOnly_.Builder attrCaps slotCaps msg kind


{-| See [`Hz.Element.ErrorOnly.AttrCaps`](Hz.Element.ErrorOnly#AttrCaps).
-}
type alias ErrorOnlyAttrCaps =
    ErrorOnly_.AttrCaps


{-| See [`Hz.Element.ErrorOnly.SlotCaps`](Hz.Element.ErrorOnly#SlotCaps).
-}
type alias ErrorOnlySlotCaps =
    ErrorOnly_.SlotCaps


{-| See [`Hz.Element.ErrorOnly.ChildAdmittedBy`](Hz.Element.ErrorOnly#ChildAdmittedBy).
-}
type alias ErrorOnlyChildAdmittedBy childAdm =
    ErrorOnly_.ChildAdmittedBy childAdm


{-| See [`Hz.Element.ErrorOnly.onHzError`](Hz.Element.ErrorOnly#onHzError).
-}
errorOnlyOnHzError : msg -> Attr { c | onHzError : Supported } msg
errorOnlyOnHzError =
    ErrorOnly_.onHzError
