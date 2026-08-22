module Sl.Component.Divider exposing (DividerIs, DividerAttrs, DividerBuilder, DividerAttrCaps, DividerSlotCaps, DividerChildAdmittedBy, divider, dividerVertical)

{-| The **Divider** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Divider`](Sl.Element.Divider) as `divider`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs DividerIs, DividerAttrs, DividerBuilder, DividerAttrCaps, DividerSlotCaps, DividerChildAdmittedBy, divider, dividerVertical

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.Divider as Divider_


{-| The `divider` element of this family — delegates to [`Sl.Element.Divider.component`](Sl.Element.Divider#component).
-}
divider :
    List (Attr DividerAttrs msg)
    -> List (Element childAccepts (DividerChildAdmittedBy childAdm) msg)
    -> Element (DividerIs s) admittedBy msg
divider =
    Divider_.component


{-| See [`Sl.Element.Divider.Is`](Sl.Element.Divider#Is).
-}
type alias DividerIs s =
    Divider_.Is s


{-| See [`Sl.Element.Divider.Attrs`](Sl.Element.Divider#Attrs).
-}
type alias DividerAttrs =
    Divider_.Attrs


{-| See [`Sl.Element.Divider.Builder`](Sl.Element.Divider#Builder).
-}
type alias DividerBuilder attrCaps slotCaps msg kind =
    Divider_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Divider.AttrCaps`](Sl.Element.Divider#AttrCaps).
-}
type alias DividerAttrCaps =
    Divider_.AttrCaps


{-| See [`Sl.Element.Divider.SlotCaps`](Sl.Element.Divider#SlotCaps).
-}
type alias DividerSlotCaps =
    Divider_.SlotCaps


{-| See [`Sl.Element.Divider.ChildAdmittedBy`](Sl.Element.Divider#ChildAdmittedBy).
-}
type alias DividerChildAdmittedBy childAdm =
    Divider_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Divider.vertical`](Sl.Element.Divider#vertical).
-}
dividerVertical : Bool -> Attr { c | vertical : Supported } msg
dividerVertical =
    Divider_.vertical
