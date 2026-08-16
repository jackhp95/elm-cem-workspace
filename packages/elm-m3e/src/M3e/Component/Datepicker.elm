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
