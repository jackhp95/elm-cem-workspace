module Mini.Component.Toolbar exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , child
    )

{-| The `mini-toolbar` component — strict per-component surface.

Groups action elements (a set-reference consumer).

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
import Mini.Attributes as A
import Mini.Html as H
import Mini.Internal.Types.Toolbar
import Mini.Kind exposing (Actions, Available, Brand, Ctx, Used)
import Mini.Values


{-| The kind row `mini-toolbar` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Mini.Internal.Types.Toolbar.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Mini.Internal.Types.Toolbar.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Mini.Internal.Types.Toolbar.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`. The default slot admits
the `actions` kind set — see `Mini.Kind.Actions`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Actions (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.toolbar


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Actions admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
