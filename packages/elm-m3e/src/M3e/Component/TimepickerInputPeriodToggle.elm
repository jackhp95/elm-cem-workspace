module M3e.Component.TimepickerInputPeriodToggle exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Period, period
    , orientation, onChange
    )

{-| The `m3e-timepicker-input-period-toggle` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Period, period
@docs orientation, onChange

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.TimepickerInputPeriodToggle
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-timepicker-input-period-toggle` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.TimepickerInputPeriodToggle.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.TimepickerInputPeriodToggle.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.TimepickerInputPeriodToggle.ChildAdmittedBy childAdm


{-| The `period` values valid on this component (compile-tight narrowing).
-}
type alias Period =
    M3e.Internal.Types.TimepickerInputPeriodToggle.Period


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.TimepickerInputPeriodToggle.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.TimepickerInputPeriodToggle.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.timepickerInputPeriodToggle


{-| The 12-hour time period. (default: `"am"`)
-}
period : Value Period -> Attr { c | period : Supported } msg
period value_ =
    Ir.attribute "period" (Val.toString value_)


{-| The orientation of the toggle. (default: `"vertical"`)
-}
orientation : String -> Attr { c | orientation : Supported } msg
orientation value_ =
    Ir.attribute "orientation" value_


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange
