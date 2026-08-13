module M3e.Component.DrawerContainer exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , EndMode, endMode, StartMode, startMode
    , endDivider, startDivider, onChange
    , end, start, child
    )

{-| The `m3e-drawer-container` component — strict per-component surface.

A container for one or two sliding drawers.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs EndMode, endMode, StartMode, startMode
@docs endDivider, startDivider, onChange
@docs end, start, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.DrawerContainer
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-drawer-container` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.DrawerContainer.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.DrawerContainer.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.DrawerContainer.ChildAdmittedBy childAdm


{-| The `endMode` values valid on this component (compile-tight narrowing).
-}
type alias EndMode =
    M3e.Internal.Types.DrawerContainer.EndMode


{-| The `startMode` values valid on this component (compile-tight narrowing).
-}
type alias StartMode =
    M3e.Internal.Types.DrawerContainer.StartMode


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
    H.drawerContainer


{-| The behavior mode of the end drawer. (default: `"side"`)
-}
endMode : Value EndMode -> Attr { c | endMode : Supported } msg
endMode value_ =
    Ir.attribute "end-mode" (Val.toString value_)


{-| The behavior mode of the start drawer. (default: `"side"`)
-}
startMode : Value StartMode -> Attr { c | startMode : Supported } msg
startMode value_ =
    Ir.attribute "start-mode" (Val.toString value_)


{-| See `M3e.Attributes.endDivider`.
-}
endDivider : Bool -> Attr { c | endDivider : Supported } msg
endDivider =
    A.endDivider


{-| See `M3e.Attributes.startDivider`.
-}
startDivider : Bool -> Attr { c | startDivider : Supported } msg
startDivider =
    A.startDivider


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| Place an element into the named `end` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
end : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
end element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "end") (El.toNode element))


{-| Place an element into the named `start` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
start : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
start element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "start") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
