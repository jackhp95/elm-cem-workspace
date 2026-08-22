module Sl.Element.Alert exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Countdown, countdown, Variant, variant
    , closable, duration, open, onShow, onAfterShow, onHide, onAfterHide
    , child
    )

{-| The `sl-alert` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Countdown, countdown, Variant, variant
@docs closable, duration, open, onShow, onAfterShow, onHide, onAfterHide
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
import Sl.Internal.Types.Alert
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-alert` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Alert.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Alert.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Alert.ChildAdmittedBy childAdm


{-| The `countdown` values valid on this component (compile-tight narrowing).
-}
type alias Countdown =
    Sl.Internal.Types.Alert.Countdown


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    Sl.Internal.Types.Alert.Variant


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Alert.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Alert.AttrCaps


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
    H.alert


{-| Enables a countdown that indicates the remaining time the alert will be displayed.
Typically used to indicate the remaining time before a whole app refresh.
-}
countdown : Value Countdown -> Attr { c | countdown : Supported } msg
countdown value_ =
    Ir.attribute "countdown" (Val.toString value_)


{-| The alert's theme variant. (default: `'primary'`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `Sl.Attributes.closable`.
-}
closable : Bool -> Attr { c | closable : Supported } msg
closable =
    A.closable


{-| See `Sl.Attributes.duration`.
-}
duration : Float -> Attr { c | duration : Supported } msg
duration =
    A.duration


{-| See `Sl.Attributes.open`.
-}
open : Bool -> Attr { c | open : Supported } msg
open =
    A.open


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
