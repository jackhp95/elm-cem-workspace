module M3e.Component.FocusRing exposing (FocusRingIs, FocusRingAttrs, FocusRingBuilder, FocusRingAttrCaps, FocusRingSlotCaps, FocusRingChildAdmittedBy, focusRing, focusRingDisabled, focusRingFor, focusRingInward)

{-| The **FocusRing** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.FocusRing`](M3e.Element.FocusRing) as `focusRing`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs FocusRingIs, FocusRingAttrs, FocusRingBuilder, FocusRingAttrCaps, FocusRingSlotCaps, FocusRingChildAdmittedBy, focusRing, focusRingDisabled, focusRingFor, focusRingInward

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.FocusRing as FocusRing_


{-| The `focusRing` element of this family — delegates to [`M3e.Element.FocusRing.component`](M3e.Element.FocusRing#component).
-}
focusRing :
    List (Attr FocusRingAttrs msg)
    -> List (Element childAccepts (FocusRingChildAdmittedBy childAdm) msg)
    -> Element (FocusRingIs s) admittedBy msg
focusRing =
    FocusRing_.component


{-| See [`M3e.Element.FocusRing.Is`](M3e.Element.FocusRing#Is).
-}
type alias FocusRingIs s =
    FocusRing_.Is s


{-| See [`M3e.Element.FocusRing.Attrs`](M3e.Element.FocusRing#Attrs).
-}
type alias FocusRingAttrs =
    FocusRing_.Attrs


{-| See [`M3e.Element.FocusRing.Builder`](M3e.Element.FocusRing#Builder).
-}
type alias FocusRingBuilder attrCaps slotCaps msg kind =
    FocusRing_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.FocusRing.AttrCaps`](M3e.Element.FocusRing#AttrCaps).
-}
type alias FocusRingAttrCaps =
    FocusRing_.AttrCaps


{-| See [`M3e.Element.FocusRing.SlotCaps`](M3e.Element.FocusRing#SlotCaps).
-}
type alias FocusRingSlotCaps =
    FocusRing_.SlotCaps


{-| See [`M3e.Element.FocusRing.ChildAdmittedBy`](M3e.Element.FocusRing#ChildAdmittedBy).
-}
type alias FocusRingChildAdmittedBy childAdm =
    FocusRing_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.FocusRing.disabled`](M3e.Element.FocusRing#disabled).
-}
focusRingDisabled : Bool -> Attr { c | disabled : Supported } msg
focusRingDisabled =
    FocusRing_.disabled


{-| See [`M3e.Element.FocusRing.for`](M3e.Element.FocusRing#for).
-}
focusRingFor : String -> Attr { c | for : Supported } msg
focusRingFor =
    FocusRing_.for


{-| See [`M3e.Element.FocusRing.inward`](M3e.Element.FocusRing#inward).
-}
focusRingInward : Bool -> Attr { c | inward : Supported } msg
focusRingInward =
    FocusRing_.inward
