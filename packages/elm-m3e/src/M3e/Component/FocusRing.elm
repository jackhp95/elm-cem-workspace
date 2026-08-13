module M3e.Component.FocusRing exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , disabled, for, inward
    )

{-| The `m3e-focus-ring` component — strict per-component surface.

A focus ring used to depict a strong focus indicator.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs disabled, for, inward

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.FocusRing
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-focus-ring` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.FocusRing.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.FocusRing.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.FocusRing.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.focusRing


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


{-| See `M3e.Attributes.inward`.
-}
inward : Bool -> Attr { c | inward : Supported } msg
inward =
    A.inward
