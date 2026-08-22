module Sl.Component.Animation exposing (AnimationIs, AnimationAttrs, AnimationBuilder, AnimationAttrCaps, AnimationSlotCaps, AnimationChildAdmittedBy, animation, animationDelay, animationDirection, animationDuration, animationEasing, animationEndDelay, animationFill, animationIterationStart, animationIterations, animationName, animationPlay, animationPlaybackRate, animationOnCancel, animationOnFinish, animationOnStart, animationChild)

{-| The **Animation** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Animation`](Sl.Element.Animation) as `animation`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs AnimationIs, AnimationAttrs, AnimationBuilder, AnimationAttrCaps, AnimationSlotCaps, AnimationChildAdmittedBy, animation, animationDelay, animationDirection, animationDuration, animationEasing, animationEndDelay, animationFill, animationIterationStart, animationIterations, animationName, animationPlay, animationPlaybackRate, animationOnCancel, animationOnFinish, animationOnStart, animationChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.Animation as Animation_


{-| The `animation` element of this family — delegates to [`Sl.Element.Animation.component`](Sl.Element.Animation#component).
-}
animation :
    List (Attr AnimationAttrs msg)
    -> List (Element childAccepts (AnimationChildAdmittedBy childAdm) msg)
    -> Element (AnimationIs s) admittedBy msg
animation =
    Animation_.component


{-| See [`Sl.Element.Animation.Is`](Sl.Element.Animation#Is).
-}
type alias AnimationIs s =
    Animation_.Is s


{-| See [`Sl.Element.Animation.Attrs`](Sl.Element.Animation#Attrs).
-}
type alias AnimationAttrs =
    Animation_.Attrs


{-| See [`Sl.Element.Animation.Builder`](Sl.Element.Animation#Builder).
-}
type alias AnimationBuilder attrCaps slotCaps msg kind =
    Animation_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Animation.AttrCaps`](Sl.Element.Animation#AttrCaps).
-}
type alias AnimationAttrCaps =
    Animation_.AttrCaps


{-| See [`Sl.Element.Animation.SlotCaps`](Sl.Element.Animation#SlotCaps).
-}
type alias AnimationSlotCaps =
    Animation_.SlotCaps


{-| See [`Sl.Element.Animation.ChildAdmittedBy`](Sl.Element.Animation#ChildAdmittedBy).
-}
type alias AnimationChildAdmittedBy childAdm =
    Animation_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Animation.delay`](Sl.Element.Animation#delay).
-}
animationDelay : Float -> Attr { c | delay : Supported } msg
animationDelay =
    Animation_.delay


{-| See [`Sl.Element.Animation.direction`](Sl.Element.Animation#direction).
-}
animationDirection : String -> Attr { c | direction : Supported } msg
animationDirection =
    Animation_.direction


{-| See [`Sl.Element.Animation.duration`](Sl.Element.Animation#duration).
-}
animationDuration : Float -> Attr { c | duration : Supported } msg
animationDuration =
    Animation_.duration


{-| See [`Sl.Element.Animation.easing`](Sl.Element.Animation#easing).
-}
animationEasing : String -> Attr { c | easing : Supported } msg
animationEasing =
    Animation_.easing


{-| See [`Sl.Element.Animation.endDelay`](Sl.Element.Animation#endDelay).
-}
animationEndDelay : Float -> Attr { c | endDelay : Supported } msg
animationEndDelay =
    Animation_.endDelay


{-| See [`Sl.Element.Animation.fill`](Sl.Element.Animation#fill).
-}
animationFill : String -> Attr { c | fill : Supported } msg
animationFill =
    Animation_.fill


{-| See [`Sl.Element.Animation.iterationStart`](Sl.Element.Animation#iterationStart).
-}
animationIterationStart : Float -> Attr { c | iterationStart : Supported } msg
animationIterationStart =
    Animation_.iterationStart


{-| See [`Sl.Element.Animation.iterations`](Sl.Element.Animation#iterations).
-}
animationIterations : String -> Attr { c | iterations : Supported } msg
animationIterations =
    Animation_.iterations


{-| See [`Sl.Element.Animation.name`](Sl.Element.Animation#name).
-}
animationName : String -> Attr { c | name : Supported } msg
animationName =
    Animation_.name


{-| See [`Sl.Element.Animation.play`](Sl.Element.Animation#play).
-}
animationPlay : Bool -> Attr { c | play : Supported } msg
animationPlay =
    Animation_.play


{-| See [`Sl.Element.Animation.playbackRate`](Sl.Element.Animation#playbackRate).
-}
animationPlaybackRate : Float -> Attr { c | playbackRate : Supported } msg
animationPlaybackRate =
    Animation_.playbackRate


{-| See [`Sl.Element.Animation.onCancel`](Sl.Element.Animation#onCancel).
-}
animationOnCancel : msg -> Attr { c | onCancel : Supported } msg
animationOnCancel =
    Animation_.onCancel


{-| See [`Sl.Element.Animation.onFinish`](Sl.Element.Animation#onFinish).
-}
animationOnFinish : msg -> Attr { c | onFinish : Supported } msg
animationOnFinish =
    Animation_.onFinish


{-| See [`Sl.Element.Animation.onStart`](Sl.Element.Animation#onStart).
-}
animationOnStart : msg -> Attr { c | onStart : Supported } msg
animationOnStart =
    Animation_.onStart


{-| See [`Sl.Element.Animation.child`](Sl.Element.Animation#child).
-}
animationChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
animationChild =
    Animation_.child
