module M3e.Component.PseudoCheckbox exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , checked, disabled, indeterminate, defaultChecked
    )

{-| The `m3e-pseudo-checkbox` component — strict per-component surface.

An element which looks like a checkbox.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs checked, disabled, indeterminate, defaultChecked

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.PseudoCheckbox
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-pseudo-checkbox` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.PseudoCheckbox.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.PseudoCheckbox.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.PseudoCheckbox.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.pseudoCheckbox


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


{-| See `M3e.Attributes.indeterminate`.
-}
indeterminate : Bool -> Attr { c | indeterminate : Supported } msg
indeterminate =
    A.indeterminate


{-| See `M3e.Attributes.defaultChecked`.
-}
defaultChecked : Bool -> Attr { c | checked : Supported } msg
defaultChecked =
    A.defaultChecked
