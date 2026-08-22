module Sl.Component.ButtonGroup exposing (ButtonGroupIs, ButtonGroupAttrs, ButtonGroupBuilder, ButtonGroupAttrCaps, ButtonGroupSlotCaps, ButtonGroupChildAdmittedBy, buttonGroup, buttonGroupLabel)

{-| The **ButtonGroup** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.ButtonGroup`](Sl.Element.ButtonGroup) as `buttonGroup`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ButtonGroupIs, ButtonGroupAttrs, ButtonGroupBuilder, ButtonGroupAttrCaps, ButtonGroupSlotCaps, ButtonGroupChildAdmittedBy, buttonGroup, buttonGroupLabel

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.ButtonGroup as ButtonGroup_


{-| The `buttonGroup` element of this family — delegates to [`Sl.Element.ButtonGroup.component`](Sl.Element.ButtonGroup#component).
-}
buttonGroup :
    List (Attr ButtonGroupAttrs msg)
    -> List (Element childAccepts (ButtonGroupChildAdmittedBy childAdm) msg)
    -> Element (ButtonGroupIs s) admittedBy msg
buttonGroup =
    ButtonGroup_.component


{-| See [`Sl.Element.ButtonGroup.Is`](Sl.Element.ButtonGroup#Is).
-}
type alias ButtonGroupIs s =
    ButtonGroup_.Is s


{-| See [`Sl.Element.ButtonGroup.Attrs`](Sl.Element.ButtonGroup#Attrs).
-}
type alias ButtonGroupAttrs =
    ButtonGroup_.Attrs


{-| See [`Sl.Element.ButtonGroup.Builder`](Sl.Element.ButtonGroup#Builder).
-}
type alias ButtonGroupBuilder attrCaps slotCaps msg kind =
    ButtonGroup_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.ButtonGroup.AttrCaps`](Sl.Element.ButtonGroup#AttrCaps).
-}
type alias ButtonGroupAttrCaps =
    ButtonGroup_.AttrCaps


{-| See [`Sl.Element.ButtonGroup.SlotCaps`](Sl.Element.ButtonGroup#SlotCaps).
-}
type alias ButtonGroupSlotCaps =
    ButtonGroup_.SlotCaps


{-| See [`Sl.Element.ButtonGroup.ChildAdmittedBy`](Sl.Element.ButtonGroup#ChildAdmittedBy).
-}
type alias ButtonGroupChildAdmittedBy childAdm =
    ButtonGroup_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.ButtonGroup.label`](Sl.Element.ButtonGroup#label).
-}
buttonGroupLabel : String -> Attr { c | label : Supported } msg
buttonGroupLabel =
    ButtonGroup_.label
