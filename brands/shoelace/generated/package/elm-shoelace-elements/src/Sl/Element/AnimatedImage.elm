module Sl.Element.AnimatedImage exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , alt, play, src, onLoad, onError
    )

{-| The `sl-animated-image` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs alt, play, src, onLoad, onError

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.AnimatedImage
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-animated-image` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.AnimatedImage.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.AnimatedImage.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.AnimatedImage.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.AnimatedImage.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.AnimatedImage.AttrCaps


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
    H.animatedImage


{-| See `Sl.Attributes.alt`.
-}
alt : String -> Attr { c | alt : Supported } msg
alt =
    A.alt


{-| See `Sl.Attributes.play`.
-}
play : Bool -> Attr { c | play : Supported } msg
play =
    A.play


{-| See `Sl.Attributes.src`.
-}
src : String -> Attr { c | src : Supported } msg
src =
    A.src


{-| See `Sl.Events.onLoad`.
-}
onLoad : msg -> Attr { c | onLoad : Supported } msg
onLoad =
    Ev.onLoad


{-| See `Sl.Events.onError`.
-}
onError : msg -> Attr { c | onError : Supported } msg
onError =
    Ev.onError
