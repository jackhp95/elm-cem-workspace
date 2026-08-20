module Sl.Component.BreadcrumbItem exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Target, target
    , href, rel
    )

{-| The `sl-breadcrumb-item` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Target, target
@docs href, rel

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Html as H
import Sl.Internal.Types.BreadcrumbItem
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-breadcrumb-item` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.BreadcrumbItem.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.BreadcrumbItem.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.BreadcrumbItem.ChildAdmittedBy childAdm


{-| The `target` values valid on this component (compile-tight narrowing).
-}
type alias Target =
    Sl.Internal.Types.BreadcrumbItem.Target


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.BreadcrumbItem.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.BreadcrumbItem.AttrCaps


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
    H.breadcrumbItem


{-| Tells the browser where to open the link. Only used when `href` is set.
-}
target : Value Target -> Attr { c | target : Supported } msg
target value_ =
    Ir.attribute "target" (Val.toString value_)


{-| See `Sl.Attributes.href`.
-}
href : String -> Attr { c | href : Supported } msg
href =
    A.href


{-| See `Sl.Attributes.rel`.
-}
rel : String -> Attr { c | rel : Supported } msg
rel =
    A.rel
