module Sl.Element.Tooltip exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Placement, placement
    , content, disabled, distance, hoist, open, skidding, trigger, onShow, onAfterShow, onHide, onAfterHide
    , child
    )

{-| The `sl-tooltip` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Placement, placement
@docs content, disabled, distance, hoist, open, skidding, trigger, onShow, onAfterShow, onHide, onAfterHide
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Tooltip
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-tooltip` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Tooltip.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Tooltip.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Tooltip.ChildAdmittedBy childAdm


{-| The `placement` values valid on this component (compile-tight narrowing).
-}
type alias Placement =
    Sl.Internal.Types.Tooltip.Placement


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Tooltip.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Tooltip.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`. The default slot is
kind-permissive (`any`): children of any kind compose, but each child's OWN
admittedBy must still admit this context — a restricted-parent element is
rejected here at compile time.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.tooltip


{-| The preferred placement of the tooltip. Note that the actual placement may vary as needed to keep the tooltip
inside of the viewport. (default: `'top'`)
-}
placement : Value Placement -> Attr { c | placement : Supported } msg
placement value_ =
    Ir.attribute "placement" (Val.toString value_)


{-| See `Sl.Attributes.content`.
-}
content : String -> Attr { c | content : Supported } msg
content =
    A.content


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


{-| See `Sl.Attributes.trigger`.
-}
trigger : String -> Attr { c | trigger : Supported } msg
trigger =
    A.trigger


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


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
