module Sl.Component.Skeleton exposing (SkeletonIs, SkeletonAttrs, SkeletonBuilder, SkeletonAttrCaps, SkeletonSlotCaps, SkeletonChildAdmittedBy, SkeletonEffect, skeleton, skeletonEffect_)

{-| The **Skeleton** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Skeleton`](Sl.Element.Skeleton) as `skeleton`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs SkeletonIs, SkeletonAttrs, SkeletonBuilder, SkeletonAttrCaps, SkeletonSlotCaps, SkeletonChildAdmittedBy, SkeletonEffect, skeleton, skeletonEffect_

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Skeleton as Skeleton_


{-| The `skeleton` element of this family — delegates to [`Sl.Element.Skeleton.component`](Sl.Element.Skeleton#component).
-}
skeleton :
    List (Attr SkeletonAttrs msg)
    -> List (Element childAccepts (SkeletonChildAdmittedBy childAdm) msg)
    -> Element (SkeletonIs s) admittedBy msg
skeleton =
    Skeleton_.component


{-| See [`Sl.Element.Skeleton.Is`](Sl.Element.Skeleton#Is).
-}
type alias SkeletonIs s =
    Skeleton_.Is s


{-| See [`Sl.Element.Skeleton.Attrs`](Sl.Element.Skeleton#Attrs).
-}
type alias SkeletonAttrs =
    Skeleton_.Attrs


{-| See [`Sl.Element.Skeleton.Builder`](Sl.Element.Skeleton#Builder).
-}
type alias SkeletonBuilder attrCaps slotCaps msg kind =
    Skeleton_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Skeleton.AttrCaps`](Sl.Element.Skeleton#AttrCaps).
-}
type alias SkeletonAttrCaps =
    Skeleton_.AttrCaps


{-| See [`Sl.Element.Skeleton.SlotCaps`](Sl.Element.Skeleton#SlotCaps).
-}
type alias SkeletonSlotCaps =
    Skeleton_.SlotCaps


{-| See [`Sl.Element.Skeleton.ChildAdmittedBy`](Sl.Element.Skeleton#ChildAdmittedBy).
-}
type alias SkeletonChildAdmittedBy childAdm =
    Skeleton_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Skeleton.Effect`](Sl.Element.Skeleton#Effect).
-}
type alias SkeletonEffect =
    Skeleton_.Effect


{-| See [`Sl.Element.Skeleton.effect_`](Sl.Element.Skeleton#effect_).
-}
skeletonEffect_ : Value SkeletonEffect -> Attr { c | effect_ : Supported } msg
skeletonEffect_ =
    Skeleton_.effect_
