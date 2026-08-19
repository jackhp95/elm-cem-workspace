module M3e.Component.Datepicker exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , StartView, startView, Variant, variant
    , clearLabel, clearable, confirmLabel, date, dismissLabel, for, label, maxDate, minDate, nextMonthLabel, nextMultiYearLabel, nextYearLabel, previousMonthLabel, previousMultiYearLabel, previousYearLabel, range, rangeEnd, rangeStart, startAt, onChange, onBeforetoggle, onToggle
    )

{-| The `m3e-datepicker` component — strict per-component surface.

Presents a date picker on a temporary surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs StartView, startView, Variant, variant
@docs clearLabel, clearable, confirmLabel, date, dismissLabel, for, label, maxDate, minDate, nextMonthLabel, nextMultiYearLabel, nextYearLabel, previousMonthLabel, previousMultiYearLabel, previousYearLabel, range, rangeEnd, rangeStart, startAt, onChange, onBeforetoggle, onToggle


## Examples


### Examples

<!-- elm-cem:example title="Basic usage" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld1" ] [ M3e.text "Date Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld1" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "calendar_today" ] [], ariaLabel = "Open calendar", action = M3e.Action.none } [] [ M3e.Component.DatepickerToggle.component [ M3e.Component.DatepickerToggle.for "datepicker" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "MM/DD/YYYY" ]) ]
    , M3e.Component.Datepicker.component [ M3e.Component.Datepicker.variant M3e.Values.auto, M3e.Attributes.id "datepicker" ] []
    ]
```

<!-- elm-cem:example title="Variants" -->
```elm
M3e.Component.Datepicker.component [ M3e.Component.Datepicker.variant M3e.Values.auto ] []
```

<!-- elm-cem:example title="Date selection" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld8" ] [ M3e.text "Date Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld8" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "calendar_today" ] [], ariaLabel = "Open calendar", action = M3e.Action.none } [] [ M3e.Component.DatepickerToggle.component [ M3e.Component.DatepickerToggle.for "picker5" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "MM/DD/YYYY" ]) ]
    , M3e.Component.Datepicker.component [ M3e.Component.Datepicker.variant M3e.Values.auto, M3e.Attributes.id "picker5", M3e.Component.Datepicker.date "2026-01-01", M3e.Component.Datepicker.clearable True ] []
    ]
```

<!-- elm-cem:example title="Start date" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld7" ] [ M3e.text "Date Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld7" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "calendar_today" ] [], ariaLabel = "Open calendar", action = M3e.Action.none } [] [ M3e.Component.DatepickerToggle.component [ M3e.Component.DatepickerToggle.for "picker4" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "MM/DD/YYYY" ]) ]
    , M3e.Component.Datepicker.component [ M3e.Component.Datepicker.variant M3e.Values.auto, M3e.Attributes.id "picker4", M3e.Component.Datepicker.startAt "2026-01-01" ] []
    ]
```

<!-- elm-cem:example title="Start view" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld6" ] [ M3e.text "Date Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld6" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "calendar_today" ] [], ariaLabel = "Open calendar", action = M3e.Action.none } [] [ M3e.Component.DatepickerToggle.component [ M3e.Component.DatepickerToggle.for "picker3" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "MM/DD/YYYY" ]) ]
    , M3e.Component.Datepicker.component [ M3e.Component.Datepicker.variant M3e.Values.auto, M3e.Attributes.id "picker3", M3e.Component.Datepicker.startView M3e.Values.multiYear ] []
    ]
```

<!-- elm-cem:example title="Date ranges" -->
```elm
[ M3e.Component.FormField.component [ M3e.Attributes.id "range-field", M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld5" ] [ M3e.text "Date Range Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld5" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "calendar_today" ] [], ariaLabel = "Open calendar", action = M3e.Action.none } [] [ M3e.Component.DatepickerToggle.component [ M3e.Component.DatepickerToggle.for "date-range" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "MM/DD/YYYY - MM/DD/YYYY" ]) ]
    , M3e.Component.Datepicker.component [ M3e.Attributes.id "date-range", M3e.Component.Datepicker.rangeStart "2026-01-01", M3e.Component.Datepicker.rangeEnd "2026-01-09", M3e.Component.Datepicker.startAt "2026-01-01" ] []
    ]
```

<!-- elm-cem:example title="Min and max dates" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld4" ] [ M3e.text "Date Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld4" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "calendar_today" ] [], ariaLabel = "Open calendar", action = M3e.Action.none } [] [ M3e.Component.DatepickerToggle.component [ M3e.Component.DatepickerToggle.for "picker1" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "MM/DD/YYYY" ]) ]
    , M3e.Component.Datepicker.component [ M3e.Attributes.id "picker1", M3e.Component.Datepicker.startAt "2026-04-01", M3e.Component.Datepicker.minDate "2026-01-01", M3e.Component.Datepicker.maxDate "2026-04-30" ] []
    ]
```

<!-- elm-cem:example title="Blackout dates" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld3" ] [ M3e.text "Date Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld3" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "calendar_today" ] [], ariaLabel = "Open calendar", action = M3e.Action.none } [] [ M3e.Component.DatepickerToggle.component [ M3e.Component.DatepickerToggle.for "blackout-dates" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "MM/DD/YYYY" ]) ]
    , M3e.Component.Datepicker.component [ M3e.Component.Datepicker.variant M3e.Values.auto, M3e.Attributes.id "blackout-dates" ] []
    ]
```

<!-- elm-cem:example title="Special dates" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld2" ] [ M3e.text "Date Field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "autocomplete" "off", TypedHtml.Unsafe.Attributes.customAttribute "id" "fld2" ] [], M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "calendar_today" ] [], ariaLabel = "Open calendar", action = M3e.Action.none } [] [ M3e.Component.DatepickerToggle.component [ M3e.Component.DatepickerToggle.for "special-dates" ] [] ]), M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "MM/DD/YYYY" ]) ]
    , M3e.Component.Datepicker.component [ M3e.Component.Datepicker.variant M3e.Values.auto, M3e.Attributes.id "special-dates", M3e.Component.Datepicker.startAt "2026-04-01" ] []
    ]
```

<!-- elm-cem:docmeta category=Text inputs -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Decode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Datepicker
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-datepicker` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Datepicker.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Datepicker.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Datepicker.ChildAdmittedBy childAdm


{-| The `startView` values valid on this component (compile-tight narrowing).
-}
type alias StartView =
    M3e.Internal.Types.Datepicker.StartView


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.Datepicker.Variant


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Datepicker.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Datepicker.AttrCaps


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
    H.datepicker


{-| The initial view used to select a date. (default: `"month"`)
-}
startView : Value StartView -> Attr { c | startView : Supported } msg
startView value_ =
    Ir.attribute "start-view" (Val.toString value_)


{-| The appearance variant of the picker. (default: `"docked"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.clearLabel`.
-}
clearLabel : String -> Attr { c | clearLabel : Supported } msg
clearLabel =
    A.clearLabel


{-| See `M3e.Attributes.clearable`.
-}
clearable : Bool -> Attr { c | clearable : Supported } msg
clearable =
    A.clearable


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


{-| See `M3e.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    A.label


{-| See `M3e.Attributes.maxDate`.
-}
maxDate : String -> Attr { c | maxDate : Supported } msg
maxDate =
    A.maxDate


{-| See `M3e.Attributes.minDate`.
-}
minDate : String -> Attr { c | minDate : Supported } msg
minDate =
    A.minDate


{-| See `M3e.Attributes.nextMonthLabel`.
-}
nextMonthLabel : String -> Attr { c | nextMonthLabel : Supported } msg
nextMonthLabel =
    A.nextMonthLabel


{-| See `M3e.Attributes.nextMultiYearLabel`.
-}
nextMultiYearLabel : String -> Attr { c | nextMultiYearLabel : Supported } msg
nextMultiYearLabel =
    A.nextMultiYearLabel


{-| See `M3e.Attributes.nextYearLabel`.
-}
nextYearLabel : String -> Attr { c | nextYearLabel : Supported } msg
nextYearLabel =
    A.nextYearLabel


{-| See `M3e.Attributes.previousMonthLabel`.
-}
previousMonthLabel : String -> Attr { c | previousMonthLabel : Supported } msg
previousMonthLabel =
    A.previousMonthLabel


{-| See `M3e.Attributes.previousMultiYearLabel`.
-}
previousMultiYearLabel : String -> Attr { c | previousMultiYearLabel : Supported } msg
previousMultiYearLabel =
    A.previousMultiYearLabel


{-| See `M3e.Attributes.previousYearLabel`.
-}
previousYearLabel : String -> Attr { c | previousYearLabel : Supported } msg
previousYearLabel =
    A.previousYearLabel


{-| See `M3e.Attributes.range`.
-}
range : Bool -> Attr { c | range : Supported } msg
range =
    A.range


{-| See `M3e.Attributes.rangeEnd`.
-}
rangeEnd : String -> Attr { c | rangeEnd : Supported } msg
rangeEnd =
    A.rangeEnd


{-| See `M3e.Attributes.rangeStart`.
-}
rangeStart : String -> Attr { c | rangeStart : Supported } msg
rangeStart =
    A.rangeStart


{-| See `M3e.Attributes.startAt`.
-}
startAt : String -> Attr { c | startAt : Supported } msg
startAt =
    A.startAt


{-| Typed `change` event: decodes `target.date` as String.
-}
onChange : (String -> msg) -> Attr { c | onChange : Supported } msg
onChange toMsg =
    Ir.on "change" (Json.Decode.map toMsg (Json.Decode.at [ "target", "date" ] Json.Decode.string))


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
