module M3e.Component.LoadingIndicator exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , Variant, variant
    )

{-| The `m3e-loading-indicator` component — strict per-component surface.

Shows indeterminate progress for a short wait time.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs Variant, variant

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.LoadingIndicator
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-loading-indicator` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.LoadingIndicator.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.LoadingIndicator.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.LoadingIndicator.ChildAdmittedBy childAdm


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.LoadingIndicator.Variant


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.loadingIndicator


{-| The appearance variant of the indicator. (default: `"uncontained"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)
