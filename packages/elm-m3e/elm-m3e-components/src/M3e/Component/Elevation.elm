module M3e.Component.Elevation exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , disabled, for, level
    )

{-| The `m3e-elevation` component — strict per-component surface.

Visually depicts elevation using a shadow.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs disabled, for, level

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.Elevation
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-elevation` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Elevation.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Elevation.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Elevation.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.elevation


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


{-| See `M3e.Attributes.level`.
-}
level : Int -> Attr { c | level : Supported } msg
level =
    A.level
