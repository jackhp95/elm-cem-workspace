module M3e.Component.OptionPanel exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, LoadingSlot, ChildAdmittedBy
    , ScrollStrategy, scrollStrategy, State, state
    , anchorOffset, fitAnchorWidth, onBeforetoggle, onToggle
    , loading, noData, child
    )

{-| The `m3e-option-panel` component — strict per-component surface.

Presents a list of options on a temporary surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, LoadingSlot, ChildAdmittedBy
@docs ScrollStrategy, scrollStrategy, State, state
@docs anchorOffset, fitAnchorWidth, onBeforetoggle, onToggle
@docs loading, noData, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.OptionPanel
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-option-panel` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.OptionPanel.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.OptionPanel.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.OptionPanel.Content


{-| The kinds the `loading` slot admits.
-}
type alias LoadingSlot =
    M3e.Internal.Types.OptionPanel.LoadingSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.OptionPanel.ChildAdmittedBy childAdm


{-| The `scrollStrategy` values valid on this component (compile-tight narrowing).
-}
type alias ScrollStrategy =
    M3e.Internal.Types.OptionPanel.ScrollStrategy


{-| The `state` values valid on this component (compile-tight narrowing).
-}
type alias State =
    M3e.Internal.Types.OptionPanel.State


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.OptionPanel.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.OptionPanel.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.OptionPanel.SlotCaps


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.optionPanel


{-| The strategy that controls how the panel behaves when its trigger scrolls. (default: `"hide"`)
-}
scrollStrategy : Value ScrollStrategy -> Attr { c | scrollStrategy : Supported } msg
scrollStrategy value_ =
    Ir.attribute "scroll-strategy" (Val.toString value_)


{-| The state for which to present content. (default: `"content"`)
-}
state : Value State -> Attr { c | state : Supported } msg
state value_ =
    Ir.attribute "state" (Val.toString value_)


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


{-| Place an element into the named `loading` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
loading : Element LoadingSlot admittedBy msg -> Element free freeAdmittedBy msg
loading element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "loading") (El.toNode element))


{-| Place an element into the named `no-data` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
noData : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
noData element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "no-data") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
