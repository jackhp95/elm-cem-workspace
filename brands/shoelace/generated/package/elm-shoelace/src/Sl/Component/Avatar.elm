module Sl.Component.Avatar exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Loading, loading, Shape, shape
    , image, initials, label, onError
    )

{-| The `sl-avatar` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Loading, loading, Shape, shape
@docs image, initials, label, onError

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Avatar
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-avatar` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Avatar.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Avatar.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Avatar.ChildAdmittedBy childAdm


{-| The `loading` values valid on this component (compile-tight narrowing).
-}
type alias Loading =
    Sl.Internal.Types.Avatar.Loading


{-| The `shape` values valid on this component (compile-tight narrowing).
-}
type alias Shape =
    Sl.Internal.Types.Avatar.Shape


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Avatar.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Avatar.AttrCaps


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
    H.avatar


{-| Indicates how the browser should load the image. (default: `'eager'`)
-}
loading : Value Loading -> Attr { c | loading : Supported } msg
loading value_ =
    Ir.attribute "loading" (Val.toString value_)


{-| The shape of the avatar. (default: `'circle'`)
-}
shape : Value Shape -> Attr { c | shape : Supported } msg
shape value_ =
    Ir.attribute "shape" (Val.toString value_)


{-| See `Sl.Attributes.image`.
-}
image : String -> Attr { c | image : Supported } msg
image =
    A.image


{-| See `Sl.Attributes.initials`.
-}
initials : String -> Attr { c | initials : Supported } msg
initials =
    A.initials


{-| See `Sl.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    A.label


{-| See `Sl.Events.onError`.
-}
onError : msg -> Attr { c | onError : Supported } msg
onError =
    Ev.onError
