module M3e.Component.Timepicker exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , Format, format, Mode, mode, Orientation, orientation, Variant, variant
    , confirmLabel, date, dialLabel, dismissLabel, for, hideModeToggle, hourLabel, inputLabel, maxTime, minTime, minuteLabel, modeToggleLabel, periodToggleLabel, secondLabel, showSeconds, onChange, onBeforetoggle, onToggle
    )

{-| The `m3e-timepicker` component — strict per-component surface.

Presents a time picker on a temporary surface.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs Format, format, Mode, mode, Orientation, orientation, Variant, variant
@docs confirmLabel, date, dialLabel, dismissLabel, for, hideModeToggle, hourLabel, inputLabel, maxTime, minTime, minuteLabel, modeToggleLabel, periodToggleLabel, secondLabel, showSeconds, onChange, onBeforetoggle, onToggle

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Timepicker
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-timepicker` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Timepicker.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Timepicker.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Timepicker.ChildAdmittedBy childAdm


{-| The `format` values valid on this component (compile-tight narrowing).
-}
type alias Format =
    M3e.Internal.Types.Timepicker.Format


{-| The `mode` values valid on this component (compile-tight narrowing).
-}
type alias Mode =
    M3e.Internal.Types.Timepicker.Mode


{-| The `orientation` values valid on this component (compile-tight narrowing).
-}
type alias Orientation =
    M3e.Internal.Types.Timepicker.Orientation


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.Timepicker.Variant


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.timepicker


{-| Whether to use a 12‑hour or 24‑hour clock. (default: `"12"`)
-}
format : Value Format -> Attr { c | format : Supported } msg
format value_ =
    Ir.attribute "format" (Val.toString value_)


{-| The mode in which to select time. (default: `"dial"`)
-}
mode : Value Mode -> Attr { c | mode : Supported } msg
mode value_ =
    Ir.attribute "mode" (Val.toString value_)


{-| The orientation of the picker. (default: `"vertical"`)
-}
orientation : Value Orientation -> Attr { c | orientation : Supported } msg
orientation value_ =
    Ir.attribute "orientation" (Val.toString value_)


{-| The appearance variant of the picker. (default: `"docked"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.confirmLabel`.
-}
confirmLabel : String -> Attr { c | confirmLabel : Supported } msg
confirmLabel =
    A.confirmLabel


{-| See `M3e.Attributes.date`.
-}
date : String -> Attr { c | date : Supported } msg
date =
    A.date


{-| See `M3e.Attributes.dialLabel`.
-}
dialLabel : String -> Attr { c | dialLabel : Supported } msg
dialLabel =
    A.dialLabel


{-| See `M3e.Attributes.dismissLabel`.
-}
dismissLabel : String -> Attr { c | dismissLabel : Supported } msg
dismissLabel =
    A.dismissLabel


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for


{-| See `M3e.Attributes.hideModeToggle`.
-}
hideModeToggle : Bool -> Attr { c | hideModeToggle : Supported } msg
hideModeToggle =
    A.hideModeToggle


{-| See `M3e.Attributes.hourLabel`.
-}
hourLabel : String -> Attr { c | hourLabel : Supported } msg
hourLabel =
    A.hourLabel


{-| See `M3e.Attributes.inputLabel`.
-}
inputLabel : String -> Attr { c | inputLabel : Supported } msg
inputLabel =
    A.inputLabel


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


{-| See `M3e.Attributes.minuteLabel`.
-}
minuteLabel : String -> Attr { c | minuteLabel : Supported } msg
minuteLabel =
    A.minuteLabel


{-| See `M3e.Attributes.modeToggleLabel`.
-}
modeToggleLabel : String -> Attr { c | modeToggleLabel : Supported } msg
modeToggleLabel =
    A.modeToggleLabel


{-| See `M3e.Attributes.periodToggleLabel`.
-}
periodToggleLabel : String -> Attr { c | periodToggleLabel : Supported } msg
periodToggleLabel =
    A.periodToggleLabel


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


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


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
