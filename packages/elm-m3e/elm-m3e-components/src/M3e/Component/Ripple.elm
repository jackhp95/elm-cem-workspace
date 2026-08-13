module M3e.Component.Ripple exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , centered, disabled, for, radius, unbounded
    )

{-| The `m3e-ripple` component — strict per-component surface.

Connects user input to screen reactions using ripples.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs centered, disabled, for, radius, unbounded

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.Ripple
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-ripple` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Ripple.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Ripple.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Ripple.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.ripple


{-| See `M3e.Attributes.centered`.
-}
centered : Bool -> Attr { c | centered : Supported } msg
centered =
    A.centered


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for


{-| See `M3e.Attributes.radius`.
-}
radius : Float -> Attr { c | radius : Supported } msg
radius =
    A.radius


{-| See `M3e.Attributes.unbounded`.
-}
unbounded : Bool -> Attr { c | unbounded : Supported } msg
unbounded =
    A.unbounded
