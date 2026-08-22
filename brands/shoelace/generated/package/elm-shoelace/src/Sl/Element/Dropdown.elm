module Sl.Element.Dropdown exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, TriggerSlot, ChildAdmittedBy
    , Placement, placement, Sync, sync
    , disabled, distance, hoist, open, skidding, stayOpenOnSelect, onShow, onAfterShow, onHide, onAfterHide
    , trigger, child
    )

{-| The `sl-dropdown` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, TriggerSlot, ChildAdmittedBy
@docs Placement, placement, Sync, sync
@docs disabled, distance, hoist, open, skidding, stayOpenOnSelect, onShow, onAfterShow, onHide, onAfterHide
@docs trigger, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Dropdown
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-dropdown` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Dropdown.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Dropdown.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Sl.Internal.Types.Dropdown.Content


{-| The kinds the `trigger` slot admits.
-}
type alias TriggerSlot =
    Sl.Internal.Types.Dropdown.TriggerSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Dropdown.ChildAdmittedBy childAdm


{-| The `placement` values valid on this component (compile-tight narrowing).
-}
type alias Placement =
    Sl.Internal.Types.Dropdown.Placement


{-| The `sync` values valid on this component (compile-tight narrowing).
-}
type alias Sync =
    Sl.Internal.Types.Dropdown.Sync


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Dropdown.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Dropdown.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    Sl.Internal.Types.Dropdown.SlotCaps


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.dropdown


{-| The preferred placement of the dropdown panel. Note that the actual placement may vary as needed to keep the panel
inside of the viewport. (default: `'bottom-start'`)
-}
placement : Value Placement -> Attr { c | placement : Supported } msg
placement value_ =
    Ir.attribute "placement" (Val.toString value_)


{-| Syncs the popup width or height to that of the trigger element.
-}
sync : Value Sync -> Attr { c | sync : Supported } msg
sync value_ =
    Ir.attribute "sync" (Val.toString value_)


{-| See `Sl.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `Sl.Attributes.distance`.
-}
distance : Float -> Attr { c | distance : Supported } msg
distance =
    A.distance


{-| See `Sl.Attributes.hoist`.
-}
hoist : Bool -> Attr { c | hoist : Supported } msg
hoist =
    A.hoist


{-| See `Sl.Attributes.open`.
-}
open : Bool -> Attr { c | open : Supported } msg
open =
    A.open


{-| See `Sl.Attributes.skidding`.
-}
skidding : Float -> Attr { c | skidding : Supported } msg
skidding =
    A.skidding


{-| See `Sl.Attributes.stayOpenOnSelect`.
-}
stayOpenOnSelect : Bool -> Attr { c | stayOpenOnSelect : Supported } msg
stayOpenOnSelect =
    A.stayOpenOnSelect


{-| See `Sl.Events.onShow`.
-}
onShow : msg -> Attr { c | onShow : Supported } msg
onShow =
    Ev.onShow


{-| See `Sl.Events.onAfterShow`.
-}
onAfterShow : msg -> Attr { c | onAfterShow : Supported } msg
onAfterShow =
    Ev.onAfterShow


{-| See `Sl.Events.onHide`.
-}
onHide : msg -> Attr { c | onHide : Supported } msg
onHide =
    Ev.onHide


{-| See `Sl.Events.onAfterHide`.
-}
onAfterHide : msg -> Attr { c | onAfterHide : Supported } msg
onAfterHide =
    Ev.onAfterHide


{-| Place an element into the named `trigger` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
trigger : Element TriggerSlot admittedBy msg -> Element free freeAdmittedBy msg
trigger element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "trigger") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
