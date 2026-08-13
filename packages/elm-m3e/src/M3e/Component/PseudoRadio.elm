module M3e.Component.PseudoRadio exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , checked, disabled, defaultChecked
    )

{-| The `m3e-pseudo-radio` component — strict per-component surface.

An element which looks like a radio button.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs checked, disabled, defaultChecked

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.PseudoRadio
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-pseudo-radio` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.PseudoRadio.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.PseudoRadio.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.PseudoRadio.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.pseudoRadio


{-| See `M3e.Attributes.checked`.
-}
checked : Bool -> Attr { c | checked : Supported } msg
checked =
    A.checked


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.defaultChecked`.
-}
defaultChecked : Bool -> Attr { c | checked : Supported } msg
defaultChecked =
    A.defaultChecked
