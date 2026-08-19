module M3e.Component.TimepickerDial exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Format, format, Period, period, ViewAttr, viewAttr
    , hour, maxTime, minTime, minute, second, showSeconds, onInput, onChange, onViewChange
    )

{-| The `m3e-timepicker-dial` component — strict per-component surface.

A clock‑face surface for selecting hours and minutes using a movable hand.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Format, format, Period, period, ViewAttr, viewAttr
@docs hour, maxTime, minTime, minute, second, showSeconds, onInput, onChange, onViewChange

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.TimepickerDial
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-timepicker-dial` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.TimepickerDial.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.TimepickerDial.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.TimepickerDial.ChildAdmittedBy childAdm


{-| The `format` values valid on this component (compile-tight narrowing).
-}
type alias Format =
    M3e.Internal.Types.TimepickerDial.Format


{-| The `period` values valid on this component (compile-tight narrowing).
-}
type alias Period =
    M3e.Internal.Types.TimepickerDial.Period


{-| The `viewAttr` values valid on this component (compile-tight narrowing).
-}
type alias ViewAttr =
    M3e.Internal.Types.TimepickerDial.ViewAttr


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.TimepickerDial.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.TimepickerDial.AttrCaps


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
    H.timepickerDial


{-| Whether to use a 12‑hour or 24‑hour clock. (default: `"12"`)
-}
format : Value Format -> Attr { c | format : Supported } msg
format value_ =
    Ir.attribute "format" (Val.toString value_)


{-| The 12-hour time period. (default: `"am"`)
-}
period : Value Period -> Attr { c | period : Supported } msg
period value_ =
    Ir.attribute "period" (Val.toString value_)


{-| The view used to input time. (default: `"hour"`)
-}
viewAttr : Value ViewAttr -> Attr { c | viewAttr : Supported } msg
viewAttr value_ =
    Ir.attribute "view" (Val.toString value_)


{-| See `M3e.Attributes.hour`.
-}
hour : Float -> Attr { c | hour : Supported } msg
hour =
    A.hour


{-| See `M3e.Attributes.maxTime`.
-}
maxTime : String -> Attr { c | maxTime : Supported } msg
maxTime =
    A.maxTime


{-| See `M3e.Attributes.minTime`.
-}
minTime : String -> Attr { c | minTime : Supported } msg
minTime =
    A.minTime


{-| See `M3e.Attributes.minute`.
-}
minute : Float -> Attr { c | minute : Supported } msg
minute =
    A.minute


{-| See `M3e.Attributes.second`.
-}
second : Float -> Attr { c | second : Supported } msg
second =
    A.second


{-| See `M3e.Attributes.showSeconds`.
-}
showSeconds : Bool -> Attr { c | showSeconds : Supported } msg
showSeconds =
    A.showSeconds


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


{-| See `M3e.Events.onViewChange`.
-}
onViewChange : msg -> Attr { c | onViewChange : Supported } msg
onViewChange =
    Ev.onViewChange
