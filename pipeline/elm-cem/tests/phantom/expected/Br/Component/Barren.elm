module Br.Component.Barren exposing (BarrenIs, BarrenAttrs, BarrenBuilder, BarrenAttrCaps, BarrenSlotCaps, BarrenContent, BarrenChildAdmittedBy, barren, barrenCount, barrenLabel, barrenChild)

{-| The **Barren** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Br.Element.Barren`](Br.Element.Barren) as `barren`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs BarrenIs, BarrenAttrs, BarrenBuilder, BarrenAttrCaps, BarrenSlotCaps, BarrenContent, BarrenChildAdmittedBy, barren, barrenCount, barrenLabel, barrenChild

-}

import Br.Element.Barren as Barren_
import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)


{-| The `barren` element of this family — delegates to [`Br.Element.Barren.component`](Br.Element.Barren#component).
-}
barren :
    List (Attr BarrenAttrs msg)
    -> List (Element BarrenContent (BarrenChildAdmittedBy childAdm) msg)
    -> Element (BarrenIs s) admittedBy msg
barren =
    Barren_.component


{-| See [`Br.Element.Barren.Is`](Br.Element.Barren#Is).
-}
type alias BarrenIs s =
    Barren_.Is s


{-| See [`Br.Element.Barren.Attrs`](Br.Element.Barren#Attrs).
-}
type alias BarrenAttrs =
    Barren_.Attrs


{-| See [`Br.Element.Barren.Builder`](Br.Element.Barren#Builder).
-}
type alias BarrenBuilder attrCaps slotCaps msg kind =
    Barren_.Builder attrCaps slotCaps msg kind


{-| See [`Br.Element.Barren.AttrCaps`](Br.Element.Barren#AttrCaps).
-}
type alias BarrenAttrCaps =
    Barren_.AttrCaps


{-| See [`Br.Element.Barren.SlotCaps`](Br.Element.Barren#SlotCaps).
-}
type alias BarrenSlotCaps =
    Barren_.SlotCaps


{-| See [`Br.Element.Barren.Content`](Br.Element.Barren#Content).
-}
type alias BarrenContent =
    Barren_.Content


{-| See [`Br.Element.Barren.ChildAdmittedBy`](Br.Element.Barren#ChildAdmittedBy).
-}
type alias BarrenChildAdmittedBy childAdm =
    Barren_.ChildAdmittedBy childAdm


{-| See [`Br.Element.Barren.count`](Br.Element.Barren#count).
-}
barrenCount : Float -> Attr { c | count : Supported } msg
barrenCount =
    Barren_.count


{-| See [`Br.Element.Barren.label`](Br.Element.Barren#label).
-}
barrenLabel : String -> Attr { c | label : Supported } msg
barrenLabel =
    Barren_.label


{-| See [`Br.Element.Barren.child`](Br.Element.Barren#child).
-}
barrenChild : Element BarrenContent admittedBy msg -> Element free freeAdmittedBy msg
barrenChild =
    Barren_.child
