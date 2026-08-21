module M3e.Component.Calendar exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , StartView, startView
    , date, maxDate, minDate, nextMonthLabel, nextMultiYearLabel, nextYearLabel, previousMonthLabel, previousMultiYearLabel, previousYearLabel, rangeEnd, rangeStart, startAt, onChange
    , header
    )

{-| The `m3e-calendar` component — strict per-component surface.

A calendar used to select a date.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs StartView, startView
@docs date, maxDate, minDate, nextMonthLabel, nextMultiYearLabel, nextYearLabel, previousMonthLabel, previousMultiYearLabel, previousYearLabel, rangeEnd, rangeStart, startAt, onChange
@docs header


## Examples


### Examples

<!-- elm-cem:example title="Date selection" -->
```elm
[ M3e.Component.Calendar.component [ M3e.Attributes.id "calendar", M3e.Component.Calendar.date "2026-01-01" ] []
    , TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "id" "selected-date" ] []
    ]
```

<!-- elm-cem:example title="Start date" -->
```elm
M3e.Component.Calendar.component [ M3e.Component.Calendar.startAt "2026-01-01" ] []
```

<!-- elm-cem:example title="Start view" -->
```elm
M3e.Component.Calendar.component [ M3e.Component.Calendar.startView M3e.Values.multiYear ] []
```

<!-- elm-cem:example title="Date ranges" -->
```elm
M3e.Component.Calendar.component [ M3e.Component.Calendar.rangeStart "2026-01-01", M3e.Component.Calendar.rangeEnd "2026-01-09", M3e.Component.Calendar.startAt "2026-01-01" ] []
```

<!-- elm-cem:example title="Min and max dates" -->
```elm
M3e.Component.Calendar.component [ M3e.Component.Calendar.startAt "2026-04-01", M3e.Component.Calendar.minDate "2026-01-01", M3e.Component.Calendar.maxDate "2026-04-30" ] []
```

<!-- elm-cem:example title="Blackout dates" -->
```elm
M3e.Component.Calendar.component [ M3e.Attributes.id "blackout-dates" ] []
```

<!-- elm-cem:example title="Special dates" -->
```elm
M3e.Component.Calendar.component [ M3e.Attributes.id "special-dates", M3e.Component.Calendar.startAt "2026-04-01" ] []
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
import M3e.Internal.Types.Calendar
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-calendar` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Calendar.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Calendar.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Calendar.ChildAdmittedBy childAdm


{-| The `startView` values valid on this component (compile-tight narrowing).
-}
type alias StartView =
    M3e.Internal.Types.Calendar.StartView


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Calendar.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Calendar.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.Calendar.SlotCaps


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.calendar


{-| The initial view used to select a date. (default: `"month"`)
-}
startView : Value StartView -> Attr { c | startView : Supported } msg
startView value_ =
    Ir.attribute "start-view" (Val.toString value_)


{-| See `M3e.Attributes.date`.
-}
date : String -> Attr { c | date : Supported } msg
date =
    A.date


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


{-| Place an element into the named `header` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
header : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
header element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "header") (El.toNode element))
