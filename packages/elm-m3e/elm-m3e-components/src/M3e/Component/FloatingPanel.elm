module M3e.Component.FloatingPanel exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , ScrollStrategy, scrollStrategy
    , anchorOffset, fitAnchorWidth, onBeforetoggle, onToggle
    , child
    )

{-| The `m3e-floating-panel` component — strict per-component surface.

A lightweight, generic floating surface used to present content above the page.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs ScrollStrategy, scrollStrategy
@docs anchorOffset, fitAnchorWidth, onBeforetoggle, onToggle
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
import M3e.Internal.Types.FloatingPanel
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-floating-panel` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.FloatingPanel.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.FloatingPanel.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.FloatingPanel.ChildAdmittedBy childAdm


{-| The `scrollStrategy` values valid on this component (compile-tight narrowing).
-}
type alias ScrollStrategy =
    M3e.Internal.Types.FloatingPanel.ScrollStrategy


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
    H.floatingPanel


{-| The strategy that controls how the panel behaves when its trigger scrolls. (default: `"hide"`)
-}
scrollStrategy : Value ScrollStrategy -> Attr { c | scrollStrategy : Supported } msg
scrollStrategy value_ =
    Ir.attribute "scroll-strategy" (Val.toString value_)


{-| See `M3e.Attributes.anchorOffset`.
-}
anchorOffset : Float -> Attr { c | anchorOffset : Supported } msg
anchorOffset =
    A.anchorOffset


{-| See `M3e.Attributes.fitAnchorWidth`.
-}
fitAnchorWidth : Bool -> Attr { c | fitAnchorWidth : Supported } msg
fitAnchorWidth =
    A.fitAnchorWidth


{-| See `M3e.Events.onBeforetoggle`.
-}
onBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
onBeforetoggle =
    Ev.onBeforetoggle


{-| See `M3e.Events.onToggle`.
-}
onToggle : msg -> Attr { c | onToggle : Supported } msg
onToggle =
    Ev.onToggle


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
