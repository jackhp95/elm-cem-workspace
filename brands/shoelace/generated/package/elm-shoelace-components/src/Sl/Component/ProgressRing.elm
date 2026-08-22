module Sl.Component.ProgressRing exposing (ProgressRingIs, ProgressRingAttrs, ProgressRingBuilder, ProgressRingAttrCaps, ProgressRingSlotCaps, ProgressRingContent, ProgressRingChildAdmittedBy, progressRing, progressRingLabel, progressRingValue, progressRingDefaultValue, progressRingChild)

{-| The **ProgressRing** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.ProgressRing`](Sl.Element.ProgressRing) as `progressRing`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs ProgressRingIs, ProgressRingAttrs, ProgressRingBuilder, ProgressRingAttrCaps, ProgressRingSlotCaps, ProgressRingContent, ProgressRingChildAdmittedBy, progressRing, progressRingLabel, progressRingValue, progressRingDefaultValue, progressRingChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.ProgressRing as ProgressRing_


{-| The `progressRing` element of this family — delegates to [`Sl.Element.ProgressRing.component`](Sl.Element.ProgressRing#component).
-}
progressRing :
    List (Attr ProgressRingAttrs msg)
    -> List (Element ProgressRingContent (ProgressRingChildAdmittedBy childAdm) msg)
    -> Element (ProgressRingIs s) admittedBy msg
progressRing =
    ProgressRing_.component


{-| See [`Sl.Element.ProgressRing.Is`](Sl.Element.ProgressRing#Is).
-}
type alias ProgressRingIs s =
    ProgressRing_.Is s


{-| See [`Sl.Element.ProgressRing.Attrs`](Sl.Element.ProgressRing#Attrs).
-}
type alias ProgressRingAttrs =
    ProgressRing_.Attrs


{-| See [`Sl.Element.ProgressRing.Builder`](Sl.Element.ProgressRing#Builder).
-}
type alias ProgressRingBuilder attrCaps slotCaps msg kind =
    ProgressRing_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.ProgressRing.AttrCaps`](Sl.Element.ProgressRing#AttrCaps).
-}
type alias ProgressRingAttrCaps =
    ProgressRing_.AttrCaps


{-| See [`Sl.Element.ProgressRing.SlotCaps`](Sl.Element.ProgressRing#SlotCaps).
-}
type alias ProgressRingSlotCaps =
    ProgressRing_.SlotCaps


{-| See [`Sl.Element.ProgressRing.Content`](Sl.Element.ProgressRing#Content).
-}
type alias ProgressRingContent =
    ProgressRing_.Content


{-| See [`Sl.Element.ProgressRing.ChildAdmittedBy`](Sl.Element.ProgressRing#ChildAdmittedBy).
-}
type alias ProgressRingChildAdmittedBy childAdm =
    ProgressRing_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.ProgressRing.label`](Sl.Element.ProgressRing#label).
-}
progressRingLabel : String -> Attr { c | label : Supported } msg
progressRingLabel =
    ProgressRing_.label


{-| See [`Sl.Element.ProgressRing.value`](Sl.Element.ProgressRing#value).
-}
progressRingValue : Float -> Attr { c | value : Supported } msg
progressRingValue =
    ProgressRing_.value


{-| See [`Sl.Element.ProgressRing.defaultValue`](Sl.Element.ProgressRing#defaultValue).
-}
progressRingDefaultValue : Float -> Attr { c | value : Supported } msg
progressRingDefaultValue =
    ProgressRing_.defaultValue


{-| See [`Sl.Element.ProgressRing.child`](Sl.Element.ProgressRing#child).
-}
progressRingChild : Element ProgressRingContent admittedBy msg -> Element free freeAdmittedBy msg
progressRingChild =
    ProgressRing_.child
