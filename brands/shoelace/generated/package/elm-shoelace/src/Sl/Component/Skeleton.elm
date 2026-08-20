module Sl.Component.Skeleton exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Effect, effect_
    )

{-| The `sl-skeleton` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Effect, effect_

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Html as H
import Sl.Internal.Types.Skeleton
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-skeleton` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Skeleton.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Skeleton.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Skeleton.ChildAdmittedBy childAdm


{-| The `effect_` values valid on this component (compile-tight narrowing).
-}
type alias Effect =
    Sl.Internal.Types.Skeleton.Effect


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Skeleton.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Skeleton.AttrCaps


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
    H.skeleton


{-| Determines which effect the skeleton will use. (default: `'none'`)
-}
effect_ : Value Effect -> Attr { c | effect_ : Supported } msg
effect_ value_ =
    Ir.attribute "effect" (Val.toString value_)
