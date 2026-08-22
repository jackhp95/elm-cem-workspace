module Sl.Component.MenuLabel exposing (MenuLabelIs, MenuLabelAttrs, MenuLabelBuilder, MenuLabelAttrCaps, MenuLabelSlotCaps, MenuLabelChildAdmittedBy, menuLabel)

{-| The **MenuLabel** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.MenuLabel`](Sl.Element.MenuLabel) as `menuLabel`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs MenuLabelIs, MenuLabelAttrs, MenuLabelBuilder, MenuLabelAttrCaps, MenuLabelSlotCaps, MenuLabelChildAdmittedBy, menuLabel

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import Sl.Element.MenuLabel as MenuLabel_


{-| The `menuLabel` element of this family — delegates to [`Sl.Element.MenuLabel.component`](Sl.Element.MenuLabel#component).
-}
menuLabel :
    List (Attr MenuLabelAttrs msg)
    -> List (Element childAccepts (MenuLabelChildAdmittedBy childAdm) msg)
    -> Element (MenuLabelIs s) admittedBy msg
menuLabel =
    MenuLabel_.component


{-| See [`Sl.Element.MenuLabel.Is`](Sl.Element.MenuLabel#Is).
-}
type alias MenuLabelIs s =
    MenuLabel_.Is s


{-| See [`Sl.Element.MenuLabel.Attrs`](Sl.Element.MenuLabel#Attrs).
-}
type alias MenuLabelAttrs =
    MenuLabel_.Attrs


{-| See [`Sl.Element.MenuLabel.Builder`](Sl.Element.MenuLabel#Builder).
-}
type alias MenuLabelBuilder attrCaps slotCaps msg kind =
    MenuLabel_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.MenuLabel.AttrCaps`](Sl.Element.MenuLabel#AttrCaps).
-}
type alias MenuLabelAttrCaps =
    MenuLabel_.AttrCaps


{-| See [`Sl.Element.MenuLabel.SlotCaps`](Sl.Element.MenuLabel#SlotCaps).
-}
type alias MenuLabelSlotCaps =
    MenuLabel_.SlotCaps


{-| See [`Sl.Element.MenuLabel.ChildAdmittedBy`](Sl.Element.MenuLabel#ChildAdmittedBy).
-}
type alias MenuLabelChildAdmittedBy childAdm =
    MenuLabel_.ChildAdmittedBy childAdm
