module M3e.Component.TimepickerInput exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , Format, format, Period, period, ViewAttr, viewAttr
    , for, hideLabels, hour, hourLabel, maxTime, minTime, minute, minuteLabel, orientation, periodToggleLabel, second, secondLabel, showSeconds, onViewChange, onChange
    )

{-| The `m3e-timepicker-input` component — strict per-component surface.

A keyboard‑based time surface for choosing hours and minutes.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs Format, format, Period, period, ViewAttr, viewAttr
@docs for, hideLabels, hour, hourLabel, maxTime, minTime, minute, minuteLabel, orientation, periodToggleLabel, second, secondLabel, showSeconds, onViewChange, onChange

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
import M3e.Internal.Types.TimepickerInput
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-timepicker-input` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.TimepickerInput.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.TimepickerInput.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.TimepickerInput.ChildAdmittedBy childAdm


{-| The `format` values valid on this component (compile-tight narrowing).
-}
type alias Format =
    M3e.Internal.Types.TimepickerInput.Format


{-| The `period` values valid on this component (compile-tight narrowing).
-}
type alias Period =
    M3e.Internal.Types.TimepickerInput.Period


{-| The `viewAttr` values valid on this component (compile-tight narrowing).
-}
type alias ViewAttr =
    M3e.Internal.Types.TimepickerInput.ViewAttr


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.timepickerInput


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


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for


{-| See `M3e.Attributes.hideLabels`.
-}
hideLabels : Bool -> Attr { c | hideLabels : Supported } msg
hideLabels =
    A.hideLabels


{-| See `M3e.Attributes.hour`.
-}
hour : Float -> Attr { c | hour : Supported } msg
hour =
    A.hour


{-| See `M3e.Attributes.hourLabel`.
-}
hourLabel : String -> Attr { c | hourLabel : Supported } msg
hourLabel =
    A.hourLabel


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


{-| See `M3e.Attributes.minuteLabel`.
-}
minuteLabel : String -> Attr { c | minuteLabel : Supported } msg
minuteLabel =
    A.minuteLabel


{-| The orientation of the input. (default: `"horizontal"`)
-}
orientation : String -> Attr { c | orientation : Supported } msg
orientation value_ =
    Ir.attribute "orientation" value_


{-| See `M3e.Attributes.periodToggleLabel`.
-}
periodToggleLabel : String -> Attr { c | periodToggleLabel : Supported } msg
periodToggleLabel =
    A.periodToggleLabel


{-| See `M3e.Attributes.second`.
-}
second : Float -> Attr { c | second : Supported } msg
second =
    A.second


{-| See `M3e.Attributes.secondLabel`.
-}
secondLabel : String -> Attr { c | secondLabel : Supported } msg
secondLabel =
    A.secondLabel


{-| See `M3e.Attributes.showSeconds`.
-}
showSeconds : Bool -> Attr { c | showSeconds : Supported } msg
showSeconds =
    A.showSeconds


{-| See `M3e.Events.onViewChange`.
-}
onViewChange : msg -> Attr { c | onViewChange : Supported } msg
onViewChange =
    Ev.onViewChange


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange
