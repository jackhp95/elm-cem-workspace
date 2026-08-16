module M3e.Component.NavRail exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , Mode, mode
    , onBeforeinput, onInput, onChange
    , child
    )

{-| The `m3e-nav-rail` component — strict per-component surface.

A vertical bar, typically used on larger devices, that allows a user to switch between views.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs Mode, mode
@docs onBeforeinput, onInput, onChange
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
import M3e.Internal.Types.NavRail
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-nav-rail` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.NavRail.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.NavRail.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.NavRail.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.NavRail.ChildAdmittedBy childAdm


{-| The `mode` values valid on this component (compile-tight narrowing).
-}
type alias Mode =
    M3e.Internal.Types.NavRail.Mode


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.NavRail.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.NavRail.AttrCaps


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
    H.navRail


{-| The mode in which items in the rail are presented. (default: `"compact"`)
-}
mode : Value Mode -> Attr { c | mode : Supported } msg
mode value_ =
    Ir.attribute "mode" (Val.toString value_)


{-| See `M3e.Events.onBeforeinput`.
-}
onBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
onBeforeinput =
    Ev.onBeforeinput


{-| See `M3e.Events.onInput`.
-}
onInput : msg -> Attr { c | onInput : Supported } msg
onInput =
    Ev.onInput


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
