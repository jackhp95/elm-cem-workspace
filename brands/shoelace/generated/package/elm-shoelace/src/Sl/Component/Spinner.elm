module Sl.Component.Spinner exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    )

{-| The `sl-spinner` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Sl.Attributes as A
import Sl.Html as H
import Sl.Internal.Types.Spinner
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-spinner` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Spinner.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Spinner.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Spinner.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Spinner.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Spinner.AttrCaps


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
    H.spinner
