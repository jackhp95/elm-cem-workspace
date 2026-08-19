module M3e.Component.Timepicker exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Format, format, Mode, mode, Orientation, orientation, Variant, variant
    , confirmLabel, date, dialLabel, dismissLabel, for, hideModeToggle, hourLabel, inputLabel, maxTime, minTime, minuteLabel, modeToggleLabel, periodToggleLabel, secondLabel, showSeconds, onChange, onBeforetoggle, onToggle
    )

{-| The `m3e-timepicker` component — strict per-component surface.

Presents a time picker on a temporary surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Format, format, Mode, mode, Orientation, orientation, Variant, variant
@docs confirmLabel, date, dialLabel, dismissLabel, for, hideModeToggle, hourLabel, inputLabel, maxTime, minTime, minuteLabel, modeToggleLabel, periodToggleLabel, secondLabel, showSeconds, onChange, onBeforetoggle, onToggle


## Examples


### Examples

<!-- elm-cem:example title="Basic usage" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld1" ] [ M3e.text "Time Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld1" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "schedule" ] [], ariaLabel = "Open time picker", action = M3e.Action.none } [] [ M3e.Component.TimepickerToggle.component [ M3e.Component.TimepickerToggle.for "timepicker" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "HH:MM" ]) ]
    , M3e.Component.Timepicker.component [ M3e.Attributes.id "timepicker", M3e.Component.Timepicker.variant M3e.Values.auto ] []
    ]
```

<!-- elm-cem:example title="Variants" -->
```elm
M3e.Component.Timepicker.component [ M3e.Component.Timepicker.variant M3e.Values.auto ] []
```

<!-- elm-cem:example title="Orientation" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld2" ] [ M3e.text "Time Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld2" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "schedule" ] [], ariaLabel = "Open time picker", action = M3e.Action.none } [] [ M3e.Component.TimepickerToggle.component [ M3e.Component.TimepickerToggle.for "timepicker2" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "HH:MM" ]) ]
    , M3e.Component.Timepicker.component [ M3e.Attributes.id "timepicker2", M3e.Component.Timepicker.variant M3e.Values.auto, M3e.Component.Timepicker.orientation M3e.Values.horizontal ] []
    ]
```

<!-- elm-cem:example title="Modes" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld3" ] [ M3e.text "Time Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld3" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "schedule" ] [], ariaLabel = "Open time picker", action = M3e.Action.none } [] [ M3e.Component.TimepickerToggle.component [ M3e.Component.TimepickerToggle.for "timepicker3" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "HH:MM" ]) ]
    , M3e.Component.Timepicker.component [ M3e.Attributes.id "timepicker3", M3e.Component.Timepicker.variant M3e.Values.auto, M3e.Component.Timepicker.mode M3e.Values.input, M3e.Component.Timepicker.hideModeToggle True ] []
    ]
```

<!-- elm-cem:example title="Time selection" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld6" ] [ M3e.text "Time Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld6" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "schedule" ] [], ariaLabel = "Open time picker", action = M3e.Action.none } [] [ M3e.Component.TimepickerToggle.component [ M3e.Component.TimepickerToggle.for "timepicker6" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "HH:MM" ]) ]
    , M3e.Component.Timepicker.component [ M3e.Attributes.id "timepicker6", M3e.Component.Timepicker.variant M3e.Values.auto, M3e.Component.Timepicker.date "2026-07-13T23:30:00Z" ] []
    ]
```

<!-- elm-cem:example title="Hour format" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld4" ] [ M3e.text "Time Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld4" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "schedule" ] [], ariaLabel = "Open time picker", action = M3e.Action.none } [] [ M3e.Component.TimepickerToggle.component [ M3e.Component.TimepickerToggle.for "timepicker4" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "HH:MM" ]) ]
    , M3e.Component.Timepicker.component [ M3e.Attributes.id "timepicker4", M3e.Component.Timepicker.variant M3e.Values.auto, M3e.Component.Timepicker.format M3e.Values.value24 ] []
    ]
```

<!-- elm-cem:example title="Min and max times" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld5" ] [ M3e.text "Time Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld5" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "schedule" ] [], ariaLabel = "Open time picker", action = M3e.Action.none } [] [ M3e.Component.TimepickerToggle.component [ M3e.Component.TimepickerToggle.for "timepicker5" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "HH:MM" ]) ]
    , M3e.Component.Timepicker.component [ M3e.Attributes.id "timepicker5", M3e.Component.Timepicker.variant M3e.Values.auto, M3e.Component.Timepicker.minTime "8:15 AM", M3e.Component.Timepicker.maxTime "5:30 PM" ] []
    ]
```

<!-- elm-cem:example title="Blackout times" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld7" ] [ M3e.text "Time Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld7" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "schedule" ] [], ariaLabel = "Open time picker", action = M3e.Action.none } [] [ M3e.Component.TimepickerToggle.component [ M3e.Component.TimepickerToggle.for "blackout-times" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "HH:MM" ]) ]
    , M3e.Component.Timepicker.component [ M3e.Attributes.id "blackout-times", M3e.Component.Timepicker.variant M3e.Values.auto ] []
    ]
```

<!-- elm-cem:example title="Seconds" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld8" ] [ M3e.text "Time Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld8" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "schedule" ] [], ariaLabel = "Open time picker", action = M3e.Action.none } [] [ M3e.Component.TimepickerToggle.component [ M3e.Component.TimepickerToggle.for "timepicker8" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "HH:MM:SS" ]) ]
    , M3e.Component.Timepicker.component [ M3e.Attributes.id "timepicker8", M3e.Component.Timepicker.variant M3e.Values.auto, M3e.Component.Timepicker.showSeconds True ] []
    ]
```

<!-- elm-cem:example title="À-la-carte usage" -->
```elm
[ M3e.Component.TimepickerInput.component [ M3e.Attributes.id "input", M3e.Component.TimepickerInput.for "dial" ] []
    , M3e.Component.TimepickerDial.component [ M3e.Attributes.id "dial" ] []
    , TypedHtml.span [ TypedHtml.Unsafe.Attributes.customAttribute "id" "inputValue" ] [ M3e.text "hour = , minute =" ]
    ]
```

<!-- elm-cem:docmeta category=Text inputs -->

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


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Timepicker.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Timepicker.AttrCaps


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
