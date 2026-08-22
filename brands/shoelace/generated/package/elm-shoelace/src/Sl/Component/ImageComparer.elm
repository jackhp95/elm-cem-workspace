module Sl.Component.ImageComparer exposing (ImageComparerIs, ImageComparerAttrs, ImageComparerBuilder, ImageComparerAttrCaps, ImageComparerSlotCaps, ImageComparerChildAdmittedBy, imageComparer, imageComparerPosition, imageComparerOnChange)

{-| The **ImageComparer** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.ImageComparer`](Sl.Element.ImageComparer) as `imageComparer`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ImageComparerIs, ImageComparerAttrs, ImageComparerBuilder, ImageComparerAttrCaps, ImageComparerSlotCaps, ImageComparerChildAdmittedBy, imageComparer, imageComparerPosition, imageComparerOnChange

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.ImageComparer as ImageComparer_


{-| The `imageComparer` element of this family — delegates to [`Sl.Element.ImageComparer.component`](Sl.Element.ImageComparer#component).
-}
imageComparer :
    List (Attr ImageComparerAttrs msg)
    -> List (Element childAccepts (ImageComparerChildAdmittedBy childAdm) msg)
    -> Element (ImageComparerIs s) admittedBy msg
imageComparer =
    ImageComparer_.component


{-| See [`Sl.Element.ImageComparer.Is`](Sl.Element.ImageComparer#Is).
-}
type alias ImageComparerIs s =
    ImageComparer_.Is s


{-| See [`Sl.Element.ImageComparer.Attrs`](Sl.Element.ImageComparer#Attrs).
-}
type alias ImageComparerAttrs =
    ImageComparer_.Attrs


{-| See [`Sl.Element.ImageComparer.Builder`](Sl.Element.ImageComparer#Builder).
-}
type alias ImageComparerBuilder attrCaps slotCaps msg kind =
    ImageComparer_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.ImageComparer.AttrCaps`](Sl.Element.ImageComparer#AttrCaps).
-}
type alias ImageComparerAttrCaps =
    ImageComparer_.AttrCaps


{-| See [`Sl.Element.ImageComparer.SlotCaps`](Sl.Element.ImageComparer#SlotCaps).
-}
type alias ImageComparerSlotCaps =
    ImageComparer_.SlotCaps


{-| See [`Sl.Element.ImageComparer.ChildAdmittedBy`](Sl.Element.ImageComparer#ChildAdmittedBy).
-}
type alias ImageComparerChildAdmittedBy childAdm =
    ImageComparer_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.ImageComparer.position`](Sl.Element.ImageComparer#position).
-}
imageComparerPosition : Float -> Attr { c | position : Supported } msg
imageComparerPosition =
    ImageComparer_.position


{-| See [`Sl.Element.ImageComparer.onChange`](Sl.Element.ImageComparer#onChange).
-}
imageComparerOnChange : msg -> Attr { c | onChange : Supported } msg
imageComparerOnChange =
    ImageComparer_.onChange
