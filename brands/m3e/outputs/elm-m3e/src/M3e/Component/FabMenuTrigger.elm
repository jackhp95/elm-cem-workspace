module M3e.Component.FabMenuTrigger exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , for
    )

{-| The `m3e-fab-menu-trigger` component — strict per-component surface.

An element, nested within a clickable element, used to open a floating action button (FAB) menu.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs for

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.FabMenuTrigger
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-fab-menu-trigger` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.FabMenuTrigger.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.FabMenuTrigger.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.FabMenuTrigger.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.FabMenuTrigger.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.FabMenuTrigger.AttrCaps


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
    H.fabMenuTrigger


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for
