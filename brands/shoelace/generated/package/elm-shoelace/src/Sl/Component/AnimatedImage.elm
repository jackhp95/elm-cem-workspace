module Sl.Component.AnimatedImage exposing (AnimatedImageIs, AnimatedImageAttrs, AnimatedImageBuilder, AnimatedImageAttrCaps, AnimatedImageSlotCaps, AnimatedImageChildAdmittedBy, animatedImage, animatedImageAlt, animatedImagePlay, animatedImageSrc, animatedImageOnLoad, animatedImageOnError)

{-| The **AnimatedImage** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.AnimatedImage`](Sl.Element.AnimatedImage) as `animatedImage`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs AnimatedImageIs, AnimatedImageAttrs, AnimatedImageBuilder, AnimatedImageAttrCaps, AnimatedImageSlotCaps, AnimatedImageChildAdmittedBy, animatedImage, animatedImageAlt, animatedImagePlay, animatedImageSrc, animatedImageOnLoad, animatedImageOnError

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.AnimatedImage as AnimatedImage_


{-| The `animatedImage` element of this family — delegates to [`Sl.Element.AnimatedImage.component`](Sl.Element.AnimatedImage#component).
-}
animatedImage :
    List (Attr AnimatedImageAttrs msg)
    -> List (Element childAccepts (AnimatedImageChildAdmittedBy childAdm) msg)
    -> Element (AnimatedImageIs s) admittedBy msg
animatedImage =
    AnimatedImage_.component


{-| See [`Sl.Element.AnimatedImage.Is`](Sl.Element.AnimatedImage#Is).
-}
type alias AnimatedImageIs s =
    AnimatedImage_.Is s


{-| See [`Sl.Element.AnimatedImage.Attrs`](Sl.Element.AnimatedImage#Attrs).
-}
type alias AnimatedImageAttrs =
    AnimatedImage_.Attrs


{-| See [`Sl.Element.AnimatedImage.Builder`](Sl.Element.AnimatedImage#Builder).
-}
type alias AnimatedImageBuilder attrCaps slotCaps msg kind =
    AnimatedImage_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.AnimatedImage.AttrCaps`](Sl.Element.AnimatedImage#AttrCaps).
-}
type alias AnimatedImageAttrCaps =
    AnimatedImage_.AttrCaps


{-| See [`Sl.Element.AnimatedImage.SlotCaps`](Sl.Element.AnimatedImage#SlotCaps).
-}
type alias AnimatedImageSlotCaps =
    AnimatedImage_.SlotCaps


{-| See [`Sl.Element.AnimatedImage.ChildAdmittedBy`](Sl.Element.AnimatedImage#ChildAdmittedBy).
-}
type alias AnimatedImageChildAdmittedBy childAdm =
    AnimatedImage_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.AnimatedImage.alt`](Sl.Element.AnimatedImage#alt).
-}
animatedImageAlt : String -> Attr { c | alt : Supported } msg
animatedImageAlt =
    AnimatedImage_.alt


{-| See [`Sl.Element.AnimatedImage.play`](Sl.Element.AnimatedImage#play).
-}
animatedImagePlay : Bool -> Attr { c | play : Supported } msg
animatedImagePlay =
    AnimatedImage_.play


{-| See [`Sl.Element.AnimatedImage.src`](Sl.Element.AnimatedImage#src).
-}
animatedImageSrc : String -> Attr { c | src : Supported } msg
animatedImageSrc =
    AnimatedImage_.src


{-| See [`Sl.Element.AnimatedImage.onLoad`](Sl.Element.AnimatedImage#onLoad).
-}
animatedImageOnLoad : msg -> Attr { c | onLoad : Supported } msg
animatedImageOnLoad =
    AnimatedImage_.onLoad


{-| See [`Sl.Element.AnimatedImage.onError`](Sl.Element.AnimatedImage#onError).
-}
animatedImageOnError : msg -> Attr { c | onError : Supported } msg
animatedImageOnError =
    AnimatedImage_.onError
