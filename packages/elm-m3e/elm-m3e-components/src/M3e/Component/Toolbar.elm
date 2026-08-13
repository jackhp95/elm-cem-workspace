module M3e.Component.Toolbar exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , Shape, shape, Variant, variant
    , elevated, vertical
    , child
    )

{-| The `m3e-toolbar` component — strict per-component surface.

Presents frequently used actions relevant to the current page.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs Shape, shape, Variant, variant
@docs elevated, vertical
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.Toolbar
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-toolbar` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Toolbar.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Toolbar.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Toolbar.ChildAdmittedBy childAdm


{-| The `shape` values valid on this component (compile-tight narrowing).
-}
type alias Shape =
    M3e.Internal.Types.Toolbar.Shape


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.Toolbar.Variant


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
    H.toolbar


{-| The shape of the toolbar. (default: `"square"`)
-}
shape : Value Shape -> Attr { c | shape : Supported } msg
shape value_ =
    Ir.attribute "shape" (Val.toString value_)


{-| The appearance variant of the toolbar. (default: `"standard"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.elevated`.
-}
elevated : Bool -> Attr { c | elevated : Supported } msg
elevated =
    A.elevated


{-| See `M3e.Attributes.vertical`.
-}
vertical : Bool -> Attr { c | vertical : Supported } msg
vertical =
    A.vertical


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
