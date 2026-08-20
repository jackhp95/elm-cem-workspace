module Sl.Component.Breadcrumb exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , label
    )

{-| The `sl-breadcrumb` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs label

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Sl.Attributes as A
import Sl.Html as H
import Sl.Internal.Types.Breadcrumb
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-breadcrumb` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Breadcrumb.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Breadcrumb.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Breadcrumb.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Breadcrumb.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Breadcrumb.AttrCaps


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
    H.breadcrumb


{-| See `Sl.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    A.label
