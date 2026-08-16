module M3e.Component.FabMenu exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , Variant, variant
    , onBeforetoggle, onToggle
    , child
    )

{-| The `m3e-fab-menu` component — strict per-component surface.

A menu, opened from a floating action button (FAB), used to display multiple related actions.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs Variant, variant
@docs onBeforetoggle, onToggle
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
import M3e.Internal.Types.FabMenu
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-fab-menu` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.FabMenu.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.FabMenu.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.FabMenu.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.FabMenu.ChildAdmittedBy childAdm


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.FabMenu.Variant


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.FabMenu.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.FabMenu.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.fabMenu


{-| The appearance variant of the menu. (default: `"primary"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


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
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
