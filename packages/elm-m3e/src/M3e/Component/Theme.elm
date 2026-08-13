module M3e.Component.Theme exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , Contrast, contrast, Motion, motion, Scheme, scheme, Variant, variant
    , color, density, strongFocus, onChange
    , child
    )

{-| The `m3e-theme` component — strict per-component surface.

A non-visual element responsible for application-level theming.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs Contrast, contrast, Motion, motion, Scheme, scheme, Variant, variant
@docs color, density, strongFocus, onChange
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Theme
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-theme` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Theme.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Theme.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Theme.ChildAdmittedBy childAdm


{-| The `contrast` values valid on this component (compile-tight narrowing).
-}
type alias Contrast =
    M3e.Internal.Types.Theme.Contrast


{-| The `motion` values valid on this component (compile-tight narrowing).
-}
type alias Motion =
    M3e.Internal.Types.Theme.Motion


{-| The `scheme` values valid on this component (compile-tight narrowing).
-}
type alias Scheme =
    M3e.Internal.Types.Theme.Scheme


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.Theme.Variant


{-| Standard constructor: `[attributes] [children]`. The default slot is
kind-permissive (`any`): children of any kind compose, but each child's OWN
admittedBy must still admit this context — a restricted-parent element is
rejected here at compile time.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.theme


{-| The contrast level of the theme. (default: `"standard"`)
-}
contrast : Value Contrast -> Attr { c | contrast : Supported } msg
contrast value_ =
    Ir.attribute "contrast" (Val.toString value_)


{-| The motion scheme. (default: `"standard"`)
-}
motion : Value Motion -> Attr { c | motion : Supported } msg
motion value_ =
    Ir.attribute "motion" (Val.toString value_)


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


{-| See `M3e.Attributes.density`.
-}
density : Float -> Attr { c | density : Supported } msg
density =
    A.density


{-| See `M3e.Attributes.strongFocus`.
-}
strongFocus : Bool -> Attr { c | strongFocus : Supported } msg
strongFocus =
    A.strongFocus


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
