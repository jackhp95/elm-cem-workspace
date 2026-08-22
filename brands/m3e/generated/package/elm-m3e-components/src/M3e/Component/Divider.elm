module M3e.Component.Divider exposing (DividerIs, DividerAttrs, DividerBuilder, DividerAttrCaps, DividerSlotCaps, DividerChildAdmittedBy, divider, dividerInset, dividerInsetEnd, dividerInsetStart, dividerVertical)

{-| The **Divider** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Divider`](M3e.Element.Divider) as `divider`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs DividerIs, DividerAttrs, DividerBuilder, DividerAttrCaps, DividerSlotCaps, DividerChildAdmittedBy, divider, dividerInset, dividerInsetEnd, dividerInsetStart, dividerVertical

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.Divider as Divider_


{-| The `divider` element of this family — delegates to [`M3e.Element.Divider.component`](M3e.Element.Divider#component).
-}
divider :
    List (Attr DividerAttrs msg)
    -> List (Element childAccepts (DividerChildAdmittedBy childAdm) msg)
    -> Element (DividerIs s) admittedBy msg
divider =
    Divider_.component


{-| See [`M3e.Element.Divider.Is`](M3e.Element.Divider#Is).
-}
type alias DividerIs s =
    Divider_.Is s


{-| See [`M3e.Element.Divider.Attrs`](M3e.Element.Divider#Attrs).
-}
type alias DividerAttrs =
    Divider_.Attrs


{-| See [`M3e.Element.Divider.Builder`](M3e.Element.Divider#Builder).
-}
type alias DividerBuilder attrCaps slotCaps msg kind =
    Divider_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Divider.AttrCaps`](M3e.Element.Divider#AttrCaps).
-}
type alias DividerAttrCaps =
    Divider_.AttrCaps


{-| See [`M3e.Element.Divider.SlotCaps`](M3e.Element.Divider#SlotCaps).
-}
type alias DividerSlotCaps =
    Divider_.SlotCaps


{-| See [`M3e.Element.Divider.ChildAdmittedBy`](M3e.Element.Divider#ChildAdmittedBy).
-}
type alias DividerChildAdmittedBy childAdm =
    Divider_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Divider.inset`](M3e.Element.Divider#inset).
-}
dividerInset : Bool -> Attr { c | inset : Supported } msg
dividerInset =
    Divider_.inset


{-| See [`M3e.Element.Divider.insetEnd`](M3e.Element.Divider#insetEnd).
-}
dividerInsetEnd : Bool -> Attr { c | insetEnd : Supported } msg
dividerInsetEnd =
    Divider_.insetEnd


{-| See [`M3e.Element.Divider.insetStart`](M3e.Element.Divider#insetStart).
-}
dividerInsetStart : Bool -> Attr { c | insetStart : Supported } msg
dividerInsetStart =
    Divider_.insetStart


{-| See [`M3e.Element.Divider.vertical`](M3e.Element.Divider#vertical).
-}
dividerVertical : Bool -> Attr { c | vertical : Supported } msg
dividerVertical =
    Divider_.vertical
