module M3e.Component.NavRailToggle exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , for
    )

{-| The `m3e-nav-rail-toggle` component — strict per-component surface.

An element, nested within a clickable element, used to toggle the expanded state of a navigation rail.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs for

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.NavRailToggle
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-nav-rail-toggle` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.NavRailToggle.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.NavRailToggle.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.NavRailToggle.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.navRailToggle


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for
