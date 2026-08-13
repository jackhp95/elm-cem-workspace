module M3e.Component.ScrollContainer exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , Dividers, dividers
    , thin
    , child
    )

{-| The `m3e-scroll-container` component — strict per-component surface.

A vertically oriented content container which presents dividers above and below content when scrolled.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs Dividers, dividers
@docs thin
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.ScrollContainer
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-scroll-container` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.ScrollContainer.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.ScrollContainer.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.ScrollContainer.ChildAdmittedBy childAdm


{-| The `dividers` values valid on this component (compile-tight narrowing).
-}
type alias Dividers =
    M3e.Internal.Types.ScrollContainer.Dividers


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
    H.scrollContainer


{-| The dividers used to separate scrollable content. (default: `"above-below"`)
-}
dividers : Value Dividers -> Attr { c | dividers : Supported } msg
dividers value_ =
    Ir.attribute "dividers" (Val.toString value_)


{-| See `M3e.Attributes.thin`.
-}
thin : Bool -> Attr { c | thin : Supported } msg
thin =
    A.thin


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
