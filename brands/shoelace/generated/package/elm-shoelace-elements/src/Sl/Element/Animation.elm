module Sl.Element.Animation exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , delay, direction, duration, easing, endDelay, fill, iterationStart, iterations, name, play, playbackRate, onCancel, onFinish, onStart
    )

{-| The `sl-animation` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs delay, direction, duration, easing, endDelay, fill, iterationStart, iterations, name, play, playbackRate, onCancel, onFinish, onStart

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Animation
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-animation` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Animation.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Animation.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Animation.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Animation.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Animation.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.animation


{-| See `Sl.Attributes.delay`.
-}
delay : Float -> Attr { c | delay : Supported } msg
delay =
    A.delay


{-| See `Sl.Attributes.direction`.
-}
direction : String -> Attr { c | direction : Supported } msg
direction =
    A.direction


{-| See `Sl.Attributes.duration`.
-}
duration : Float -> Attr { c | duration : Supported } msg
duration =
    A.duration


{-| See `Sl.Attributes.easing`.
-}
easing : String -> Attr { c | easing : Supported } msg
easing =
    A.easing


{-| See `Sl.Attributes.endDelay`.
-}
endDelay : Float -> Attr { c | endDelay : Supported } msg
endDelay =
    A.endDelay


{-| See `Sl.Attributes.fill`.
-}
fill : String -> Attr { c | fill : Supported } msg
fill =
    A.fill


{-| See `Sl.Attributes.iterationStart`.
-}
iterationStart : Float -> Attr { c | iterationStart : Supported } msg
iterationStart =
    A.iterationStart


{-| See `Sl.Attributes.iterations`.
-}
iterations : String -> Attr { c | iterations : Supported } msg
iterations =
    A.iterations


{-| See `Sl.Attributes.name`.
-}
name : String -> Attr { c | name : Supported } msg
name =
    A.name


{-| See `Sl.Attributes.play`.
-}
play : Bool -> Attr { c | play : Supported } msg
play =
    A.play


{-| See `Sl.Attributes.playbackRate`.
-}
playbackRate : Float -> Attr { c | playbackRate : Supported } msg
playbackRate =
    A.playbackRate


{-| See `Sl.Events.onCancel`.
-}
onCancel : msg -> Attr { c | onCancel : Supported } msg
onCancel =
    Ev.onCancel


{-| See `Sl.Events.onFinish`.
-}
onFinish : msg -> Attr { c | onFinish : Supported } msg
onFinish =
    Ev.onFinish


{-| See `Sl.Events.onStart`.
-}
onStart : msg -> Attr { c | onStart : Supported } msg
onStart =
    Ev.onStart
