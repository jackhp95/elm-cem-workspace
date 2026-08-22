module Sl.Component.VisuallyHidden exposing (VisuallyHiddenIs, VisuallyHiddenAttrs, VisuallyHiddenBuilder, VisuallyHiddenAttrCaps, VisuallyHiddenSlotCaps, VisuallyHiddenChildAdmittedBy, visuallyHidden)

{-| The **VisuallyHidden** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.VisuallyHidden`](Sl.Element.VisuallyHidden) as `visuallyHidden`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs VisuallyHiddenIs, VisuallyHiddenAttrs, VisuallyHiddenBuilder, VisuallyHiddenAttrCaps, VisuallyHiddenSlotCaps, VisuallyHiddenChildAdmittedBy, visuallyHidden

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import Sl.Element.VisuallyHidden as VisuallyHidden_


{-| The `visuallyHidden` element of this family — delegates to [`Sl.Element.VisuallyHidden.component`](Sl.Element.VisuallyHidden#component).
-}
visuallyHidden :
    List (Attr VisuallyHiddenAttrs msg)
    -> List (Element childAccepts (VisuallyHiddenChildAdmittedBy childAdm) msg)
    -> Element (VisuallyHiddenIs s) admittedBy msg
visuallyHidden =
    VisuallyHidden_.component


{-| See [`Sl.Element.VisuallyHidden.Is`](Sl.Element.VisuallyHidden#Is).
-}
type alias VisuallyHiddenIs s =
    VisuallyHidden_.Is s


{-| See [`Sl.Element.VisuallyHidden.Attrs`](Sl.Element.VisuallyHidden#Attrs).
-}
type alias VisuallyHiddenAttrs =
    VisuallyHidden_.Attrs


{-| See [`Sl.Element.VisuallyHidden.Builder`](Sl.Element.VisuallyHidden#Builder).
-}
type alias VisuallyHiddenBuilder attrCaps slotCaps msg kind =
    VisuallyHidden_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.VisuallyHidden.AttrCaps`](Sl.Element.VisuallyHidden#AttrCaps).
-}
type alias VisuallyHiddenAttrCaps =
    VisuallyHidden_.AttrCaps


{-| See [`Sl.Element.VisuallyHidden.SlotCaps`](Sl.Element.VisuallyHidden#SlotCaps).
-}
type alias VisuallyHiddenSlotCaps =
    VisuallyHidden_.SlotCaps


{-| See [`Sl.Element.VisuallyHidden.ChildAdmittedBy`](Sl.Element.VisuallyHidden#ChildAdmittedBy).
-}
type alias VisuallyHiddenChildAdmittedBy childAdm =
    VisuallyHidden_.ChildAdmittedBy childAdm
