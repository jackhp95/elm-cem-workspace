module M3e.Component.Optgroup exposing (OptgroupIs, OptgroupAttrs, OptgroupBuilder, OptgroupAttrCaps, OptgroupSlotCaps, OptgroupContent, OptgroupLabelSlot, OptgroupChildAdmittedBy, optgroup, optgroupLabel, optgroupChild)

{-| The **Optgroup** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Optgroup`](M3e.Element.Optgroup) as `optgroup`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs OptgroupIs, OptgroupAttrs, OptgroupBuilder, OptgroupAttrCaps, OptgroupSlotCaps, OptgroupContent, OptgroupLabelSlot, OptgroupChildAdmittedBy, optgroup, optgroupLabel, optgroupChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import M3e.Element.Optgroup as Optgroup_


{-| The `optgroup` element of this family — delegates to [`M3e.Element.Optgroup.component`](M3e.Element.Optgroup#component).
-}
optgroup :
    List (Attr OptgroupAttrs msg)
    -> List (Element OptgroupContent (OptgroupChildAdmittedBy childAdm) msg)
    -> Element (OptgroupIs s) admittedBy msg
optgroup =
    Optgroup_.component


{-| See [`M3e.Element.Optgroup.Is`](M3e.Element.Optgroup#Is).
-}
type alias OptgroupIs s =
    Optgroup_.Is s


{-| See [`M3e.Element.Optgroup.Attrs`](M3e.Element.Optgroup#Attrs).
-}
type alias OptgroupAttrs =
    Optgroup_.Attrs


{-| See [`M3e.Element.Optgroup.Builder`](M3e.Element.Optgroup#Builder).
-}
type alias OptgroupBuilder attrCaps slotCaps msg kind =
    Optgroup_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Optgroup.AttrCaps`](M3e.Element.Optgroup#AttrCaps).
-}
type alias OptgroupAttrCaps =
    Optgroup_.AttrCaps


{-| See [`M3e.Element.Optgroup.SlotCaps`](M3e.Element.Optgroup#SlotCaps).
-}
type alias OptgroupSlotCaps =
    Optgroup_.SlotCaps


{-| See [`M3e.Element.Optgroup.Content`](M3e.Element.Optgroup#Content).
-}
type alias OptgroupContent =
    Optgroup_.Content


{-| See [`M3e.Element.Optgroup.LabelSlot`](M3e.Element.Optgroup#LabelSlot).
-}
type alias OptgroupLabelSlot =
    Optgroup_.LabelSlot


{-| See [`M3e.Element.Optgroup.ChildAdmittedBy`](M3e.Element.Optgroup#ChildAdmittedBy).
-}
type alias OptgroupChildAdmittedBy childAdm =
    Optgroup_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Optgroup.label`](M3e.Element.Optgroup#label).
-}
optgroupLabel : Element OptgroupLabelSlot admittedBy msg -> Element free freeAdmittedBy msg
optgroupLabel =
    Optgroup_.label


{-| See [`M3e.Element.Optgroup.child`](M3e.Element.Optgroup#child).
-}
optgroupChild : Element OptgroupContent admittedBy msg -> Element free freeAdmittedBy msg
optgroupChild =
    Optgroup_.child
