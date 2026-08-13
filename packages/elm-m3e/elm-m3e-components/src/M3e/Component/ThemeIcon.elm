module M3e.Component.ThemeIcon exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , Scheme, scheme, Variant, variant
    , color
    )

{-| The `m3e-theme-icon` component — strict per-component surface.

An icon that visually presents a preview of a theme.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs Scheme, scheme, Variant, variant
@docs color

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.ThemeIcon
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-theme-icon` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.ThemeIcon.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.ThemeIcon.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.ThemeIcon.ChildAdmittedBy childAdm


{-| The `scheme` values valid on this component (compile-tight narrowing).
-}
type alias Scheme =
    M3e.Internal.Types.ThemeIcon.Scheme


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.ThemeIcon.Variant


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.themeIcon


{-| The color scheme of the theme. (default: `"auto"`)
-}
scheme : Value Scheme -> Attr { c | scheme : Supported } msg
scheme value_ =
    Ir.attribute "scheme" (Val.toString value_)


{-| The color variant of the theme. (default: `"neutral"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.color`.
-}
color : String -> Attr { c | color : Supported } msg
color =
    A.color
