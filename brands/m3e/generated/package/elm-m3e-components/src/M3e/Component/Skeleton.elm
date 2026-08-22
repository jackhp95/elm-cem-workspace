module M3e.Component.Skeleton exposing (SkeletonIs, SkeletonAttrs, SkeletonBuilder, SkeletonAttrCaps, SkeletonSlotCaps, SkeletonChildAdmittedBy, SkeletonAnimation, SkeletonShape, skeleton, skeletonAnimation, skeletonShape, skeletonLoaded, skeletonChild)

{-| The **Skeleton** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Skeleton`](M3e.Element.Skeleton) as `skeleton`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SkeletonIs, SkeletonAttrs, SkeletonBuilder, SkeletonAttrCaps, SkeletonSlotCaps, SkeletonChildAdmittedBy, SkeletonAnimation, SkeletonShape, skeleton, skeletonAnimation, skeletonShape, skeletonLoaded, skeletonChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Skeleton as Skeleton_


{-| The `skeleton` element of this family — delegates to [`M3e.Element.Skeleton.component`](M3e.Element.Skeleton#component).
-}
skeleton :
    List (Attr SkeletonAttrs msg)
    -> List (Element childAccepts (SkeletonChildAdmittedBy childAdm) msg)
    -> Element (SkeletonIs s) admittedBy msg
skeleton =
    Skeleton_.component


{-| See [`M3e.Element.Skeleton.Is`](M3e.Element.Skeleton#Is).
-}
type alias SkeletonIs s =
    Skeleton_.Is s


{-| See [`M3e.Element.Skeleton.Attrs`](M3e.Element.Skeleton#Attrs).
-}
type alias SkeletonAttrs =
    Skeleton_.Attrs


{-| See [`M3e.Element.Skeleton.Builder`](M3e.Element.Skeleton#Builder).
-}
type alias SkeletonBuilder attrCaps slotCaps msg kind =
    Skeleton_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Skeleton.AttrCaps`](M3e.Element.Skeleton#AttrCaps).
-}
type alias SkeletonAttrCaps =
    Skeleton_.AttrCaps


{-| See [`M3e.Element.Skeleton.SlotCaps`](M3e.Element.Skeleton#SlotCaps).
-}
type alias SkeletonSlotCaps =
    Skeleton_.SlotCaps


{-| See [`M3e.Element.Skeleton.ChildAdmittedBy`](M3e.Element.Skeleton#ChildAdmittedBy).
-}
type alias SkeletonChildAdmittedBy childAdm =
    Skeleton_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Skeleton.Animation`](M3e.Element.Skeleton#Animation).
-}
type alias SkeletonAnimation =
    Skeleton_.Animation


{-| See [`M3e.Element.Skeleton.animation`](M3e.Element.Skeleton#animation).
-}
skeletonAnimation : Value SkeletonAnimation -> Attr { c | animation : Supported } msg
skeletonAnimation =
    Skeleton_.animation


{-| See [`M3e.Element.Skeleton.Shape`](M3e.Element.Skeleton#Shape).
-}
type alias SkeletonShape =
    Skeleton_.Shape


{-| See [`M3e.Element.Skeleton.shape`](M3e.Element.Skeleton#shape).
-}
skeletonShape : Value SkeletonShape -> Attr { c | shape : Supported } msg
skeletonShape =
    Skeleton_.shape


{-| See [`M3e.Element.Skeleton.loaded`](M3e.Element.Skeleton#loaded).
-}
skeletonLoaded : Bool -> Attr { c | loaded : Supported } msg
skeletonLoaded =
    Skeleton_.loaded


{-| See [`M3e.Element.Skeleton.child`](M3e.Element.Skeleton#child).
-}
skeletonChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
skeletonChild =
    Skeleton_.child
