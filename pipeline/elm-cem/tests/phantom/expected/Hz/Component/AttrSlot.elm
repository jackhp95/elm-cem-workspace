module Hz.Component.AttrSlot exposing (AttrSlotIs, AttrSlotAttrs, AttrSlotBuilder, AttrSlotAttrCaps, AttrSlotSlotCaps, AttrSlotHintSlot, AttrSlotLabelSlot, AttrSlotChildAdmittedBy, attrSlot, attrSlotWithHint, attrSlotWithLabel, attrSlotHint, attrSlotLabel)

{-| The **AttrSlot** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Hz.Element.AttrSlot`](Hz.Element.AttrSlot) as `attrSlot`.

Prefer whichever import reads best — the flat `Hz.Element.*` modules and
this family module are the same elements, same types.

@docs AttrSlotIs, AttrSlotAttrs, AttrSlotBuilder, AttrSlotAttrCaps, AttrSlotSlotCaps, AttrSlotHintSlot, AttrSlotLabelSlot, AttrSlotChildAdmittedBy, attrSlot, attrSlotWithHint, attrSlotWithLabel, attrSlotHint, attrSlotLabel

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Hz.Element.AttrSlot as AttrSlot_


{-| The `attrSlot` element of this family — delegates to [`Hz.Element.AttrSlot.component`](Hz.Element.AttrSlot#component).
-}
attrSlot :
    List (Attr AttrSlotAttrs msg)
    -> List (Element childAccepts (AttrSlotChildAdmittedBy childAdm) msg)
    -> Element (AttrSlotIs s) admittedBy msg
attrSlot =
    AttrSlot_.component


{-| See [`Hz.Element.AttrSlot.Is`](Hz.Element.AttrSlot#Is).
-}
type alias AttrSlotIs s =
    AttrSlot_.Is s


{-| See [`Hz.Element.AttrSlot.Attrs`](Hz.Element.AttrSlot#Attrs).
-}
type alias AttrSlotAttrs =
    AttrSlot_.Attrs


{-| See [`Hz.Element.AttrSlot.Builder`](Hz.Element.AttrSlot#Builder).
-}
type alias AttrSlotBuilder attrCaps slotCaps msg kind =
    AttrSlot_.Builder attrCaps slotCaps msg kind


{-| See [`Hz.Element.AttrSlot.AttrCaps`](Hz.Element.AttrSlot#AttrCaps).
-}
type alias AttrSlotAttrCaps =
    AttrSlot_.AttrCaps


{-| See [`Hz.Element.AttrSlot.SlotCaps`](Hz.Element.AttrSlot#SlotCaps).
-}
type alias AttrSlotSlotCaps =
    AttrSlot_.SlotCaps


{-| See [`Hz.Element.AttrSlot.HintSlot`](Hz.Element.AttrSlot#HintSlot).
-}
type alias AttrSlotHintSlot =
    AttrSlot_.HintSlot


{-| See [`Hz.Element.AttrSlot.LabelSlot`](Hz.Element.AttrSlot#LabelSlot).
-}
type alias AttrSlotLabelSlot =
    AttrSlot_.LabelSlot


{-| See [`Hz.Element.AttrSlot.ChildAdmittedBy`](Hz.Element.AttrSlot#ChildAdmittedBy).
-}
type alias AttrSlotChildAdmittedBy childAdm =
    AttrSlot_.ChildAdmittedBy childAdm


{-| See [`Hz.Element.AttrSlot.withHint`](Hz.Element.AttrSlot#withHint).
-}
attrSlotWithHint : Bool -> Attr { c | withHint : Supported } msg
attrSlotWithHint =
    AttrSlot_.withHint


{-| See [`Hz.Element.AttrSlot.withLabel`](Hz.Element.AttrSlot#withLabel).
-}
attrSlotWithLabel : Bool -> Attr { c | withLabel : Supported } msg
attrSlotWithLabel =
    AttrSlot_.withLabel


{-| See [`Hz.Element.AttrSlot.hint`](Hz.Element.AttrSlot#hint).
-}
attrSlotHint : Element AttrSlotHintSlot admittedBy msg -> Element free freeAdmittedBy msg
attrSlotHint =
    AttrSlot_.hint


{-| See [`Hz.Element.AttrSlot.label`](Hz.Element.AttrSlot#label).
-}
attrSlotLabel : Element AttrSlotLabelSlot admittedBy msg -> Element free freeAdmittedBy msg
attrSlotLabel =
    AttrSlot_.label
