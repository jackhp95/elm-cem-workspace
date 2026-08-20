module Sl.Component.Divider exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , vertical
    )

{-| The `sl-divider` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs vertical

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Sl.Attributes as A
import Sl.Html as H
import Sl.Internal.Types.Divider
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-divider` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Divider.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Divider.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Divider.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Divider.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Divider.AttrCaps


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
    H.divider


{-| See `Sl.Attributes.vertical`.
-}
vertical : Bool -> Attr { c | vertical : Supported } msg
vertical =
    A.vertical
