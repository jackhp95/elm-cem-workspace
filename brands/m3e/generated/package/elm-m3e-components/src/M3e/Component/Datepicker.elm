module M3e.Component.Datepicker exposing (DatepickerIs, DatepickerAttrs, DatepickerBuilder, DatepickerAttrCaps, DatepickerSlotCaps, DatepickerChildAdmittedBy, DatepickerStartView, DatepickerVariant, ToggleIs, ToggleAttrs, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleChildAdmittedBy, datepicker, datepickerStartView, datepickerVariant, datepickerClearLabel, datepickerClearable, datepickerConfirmLabel, datepickerDate, datepickerDismissLabel, datepickerFor, datepickerLabel, datepickerMaxDate, datepickerMinDate, datepickerNextMonthLabel, datepickerNextMultiYearLabel, datepickerNextYearLabel, datepickerPreviousMonthLabel, datepickerPreviousMultiYearLabel, datepickerPreviousYearLabel, datepickerRange, datepickerRangeEnd, datepickerRangeStart, datepickerStartAt, datepickerOnChange, datepickerOnBeforetoggle, datepickerOnToggle, toggle, toggleFor)

{-| The **Datepicker** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Datepicker`](M3e.Element.Datepicker) as `datepicker`, [`M3e.Element.DatepickerToggle`](M3e.Element.DatepickerToggle) as `toggle`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs DatepickerIs, DatepickerAttrs, DatepickerBuilder, DatepickerAttrCaps, DatepickerSlotCaps, DatepickerChildAdmittedBy, DatepickerStartView, DatepickerVariant, ToggleIs, ToggleAttrs, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleChildAdmittedBy, datepicker, datepickerStartView, datepickerVariant, datepickerClearLabel, datepickerClearable, datepickerConfirmLabel, datepickerDate, datepickerDismissLabel, datepickerFor, datepickerLabel, datepickerMaxDate, datepickerMinDate, datepickerNextMonthLabel, datepickerNextMultiYearLabel, datepickerNextYearLabel, datepickerPreviousMonthLabel, datepickerPreviousMultiYearLabel, datepickerPreviousYearLabel, datepickerRange, datepickerRangeEnd, datepickerRangeStart, datepickerStartAt, datepickerOnChange, datepickerOnBeforetoggle, datepickerOnToggle, toggle, toggleFor

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Datepicker as Datepicker_
import M3e.Element.DatepickerToggle as Toggle_


{-| The `datepicker` element of this family — delegates to [`M3e.Element.Datepicker.component`](M3e.Element.Datepicker#component).
-}
datepicker :
    List (Attr DatepickerAttrs msg)
    -> List (Element childAccepts (DatepickerChildAdmittedBy childAdm) msg)
    -> Element (DatepickerIs s) admittedBy msg
datepicker =
    Datepicker_.component


{-| See [`M3e.Element.Datepicker.Is`](M3e.Element.Datepicker#Is).
-}
type alias DatepickerIs s =
    Datepicker_.Is s


{-| See [`M3e.Element.Datepicker.Attrs`](M3e.Element.Datepicker#Attrs).
-}
type alias DatepickerAttrs =
    Datepicker_.Attrs


{-| See [`M3e.Element.Datepicker.Builder`](M3e.Element.Datepicker#Builder).
-}
type alias DatepickerBuilder attrCaps slotCaps msg kind =
    Datepicker_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Datepicker.AttrCaps`](M3e.Element.Datepicker#AttrCaps).
-}
type alias DatepickerAttrCaps =
    Datepicker_.AttrCaps


{-| See [`M3e.Element.Datepicker.SlotCaps`](M3e.Element.Datepicker#SlotCaps).
-}
type alias DatepickerSlotCaps =
    Datepicker_.SlotCaps


{-| See [`M3e.Element.Datepicker.ChildAdmittedBy`](M3e.Element.Datepicker#ChildAdmittedBy).
-}
type alias DatepickerChildAdmittedBy childAdm =
    Datepicker_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Datepicker.StartView`](M3e.Element.Datepicker#StartView).
-}
type alias DatepickerStartView =
    Datepicker_.StartView


{-| See [`M3e.Element.Datepicker.startView`](M3e.Element.Datepicker#startView).
-}
datepickerStartView : Value DatepickerStartView -> Attr { c | startView : Supported } msg
datepickerStartView =
    Datepicker_.startView


{-| See [`M3e.Element.Datepicker.Variant`](M3e.Element.Datepicker#Variant).
-}
type alias DatepickerVariant =
    Datepicker_.Variant


{-| See [`M3e.Element.Datepicker.variant`](M3e.Element.Datepicker#variant).
-}
datepickerVariant : Value DatepickerVariant -> Attr { c | variant : Supported } msg
datepickerVariant =
    Datepicker_.variant


{-| See [`M3e.Element.Datepicker.clearLabel`](M3e.Element.Datepicker#clearLabel).
-}
datepickerClearLabel : String -> Attr { c | clearLabel : Supported } msg
datepickerClearLabel =
    Datepicker_.clearLabel


{-| See [`M3e.Element.Datepicker.clearable`](M3e.Element.Datepicker#clearable).
-}
datepickerClearable : Bool -> Attr { c | clearable : Supported } msg
datepickerClearable =
    Datepicker_.clearable


{-| See [`M3e.Element.Datepicker.confirmLabel`](M3e.Element.Datepicker#confirmLabel).
-}
datepickerConfirmLabel : String -> Attr { c | confirmLabel : Supported } msg
datepickerConfirmLabel =
    Datepicker_.confirmLabel


{-| See [`M3e.Element.Datepicker.date`](M3e.Element.Datepicker#date).
-}
datepickerDate : String -> Attr { c | date : Supported } msg
datepickerDate =
    Datepicker_.date


{-| See [`M3e.Element.Datepicker.dismissLabel`](M3e.Element.Datepicker#dismissLabel).
-}
datepickerDismissLabel : String -> Attr { c | dismissLabel : Supported } msg
datepickerDismissLabel =
    Datepicker_.dismissLabel


{-| See [`M3e.Element.Datepicker.for`](M3e.Element.Datepicker#for).
-}
datepickerFor : String -> Attr { c | for : Supported } msg
datepickerFor =
    Datepicker_.for


{-| See [`M3e.Element.Datepicker.label`](M3e.Element.Datepicker#label).
-}
datepickerLabel : String -> Attr { c | label : Supported } msg
datepickerLabel =
    Datepicker_.label


{-| See [`M3e.Element.Datepicker.maxDate`](M3e.Element.Datepicker#maxDate).
-}
datepickerMaxDate : String -> Attr { c | maxDate : Supported } msg
datepickerMaxDate =
    Datepicker_.maxDate


{-| See [`M3e.Element.Datepicker.minDate`](M3e.Element.Datepicker#minDate).
-}
datepickerMinDate : String -> Attr { c | minDate : Supported } msg
datepickerMinDate =
    Datepicker_.minDate


{-| See [`M3e.Element.Datepicker.nextMonthLabel`](M3e.Element.Datepicker#nextMonthLabel).
-}
datepickerNextMonthLabel : String -> Attr { c | nextMonthLabel : Supported } msg
datepickerNextMonthLabel =
    Datepicker_.nextMonthLabel


{-| See [`M3e.Element.Datepicker.nextMultiYearLabel`](M3e.Element.Datepicker#nextMultiYearLabel).
-}
datepickerNextMultiYearLabel : String -> Attr { c | nextMultiYearLabel : Supported } msg
datepickerNextMultiYearLabel =
    Datepicker_.nextMultiYearLabel


{-| See [`M3e.Element.Datepicker.nextYearLabel`](M3e.Element.Datepicker#nextYearLabel).
-}
datepickerNextYearLabel : String -> Attr { c | nextYearLabel : Supported } msg
datepickerNextYearLabel =
    Datepicker_.nextYearLabel


{-| See [`M3e.Element.Datepicker.previousMonthLabel`](M3e.Element.Datepicker#previousMonthLabel).
-}
datepickerPreviousMonthLabel : String -> Attr { c | previousMonthLabel : Supported } msg
datepickerPreviousMonthLabel =
    Datepicker_.previousMonthLabel


{-| See [`M3e.Element.Datepicker.previousMultiYearLabel`](M3e.Element.Datepicker#previousMultiYearLabel).
-}
datepickerPreviousMultiYearLabel : String -> Attr { c | previousMultiYearLabel : Supported } msg
datepickerPreviousMultiYearLabel =
    Datepicker_.previousMultiYearLabel


{-| See [`M3e.Element.Datepicker.previousYearLabel`](M3e.Element.Datepicker#previousYearLabel).
-}
datepickerPreviousYearLabel : String -> Attr { c | previousYearLabel : Supported } msg
datepickerPreviousYearLabel =
    Datepicker_.previousYearLabel


{-| See [`M3e.Element.Datepicker.range`](M3e.Element.Datepicker#range).
-}
datepickerRange : Bool -> Attr { c | range : Supported } msg
datepickerRange =
    Datepicker_.range


{-| See [`M3e.Element.Datepicker.rangeEnd`](M3e.Element.Datepicker#rangeEnd).
-}
datepickerRangeEnd : String -> Attr { c | rangeEnd : Supported } msg
datepickerRangeEnd =
    Datepicker_.rangeEnd


{-| See [`M3e.Element.Datepicker.rangeStart`](M3e.Element.Datepicker#rangeStart).
-}
datepickerRangeStart : String -> Attr { c | rangeStart : Supported } msg
datepickerRangeStart =
    Datepicker_.rangeStart


{-| See [`M3e.Element.Datepicker.startAt`](M3e.Element.Datepicker#startAt).
-}
datepickerStartAt : String -> Attr { c | startAt : Supported } msg
datepickerStartAt =
    Datepicker_.startAt


{-| See [`M3e.Element.Datepicker.onChange`](M3e.Element.Datepicker#onChange).
-}
datepickerOnChange : (String -> msg) -> Attr { c | onChange : Supported } msg
datepickerOnChange =
    Datepicker_.onChange


{-| See [`M3e.Element.Datepicker.onBeforetoggle`](M3e.Element.Datepicker#onBeforetoggle).
-}
datepickerOnBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
datepickerOnBeforetoggle =
    Datepicker_.onBeforetoggle


{-| See [`M3e.Element.Datepicker.onToggle`](M3e.Element.Datepicker#onToggle).
-}
datepickerOnToggle : msg -> Attr { c | onToggle : Supported } msg
datepickerOnToggle =
    Datepicker_.onToggle


{-| The `toggle` element of this family — delegates to [`M3e.Element.DatepickerToggle.component`](M3e.Element.DatepickerToggle#component).
-}
toggle :
    List (Attr ToggleAttrs msg)
    -> List (Element childAccepts (ToggleChildAdmittedBy childAdm) msg)
    -> Element (ToggleIs s) admittedBy msg
toggle =
    Toggle_.component


{-| See [`M3e.Element.DatepickerToggle.Is`](M3e.Element.DatepickerToggle#Is).
-}
type alias ToggleIs s =
    Toggle_.Is s


{-| See [`M3e.Element.DatepickerToggle.Attrs`](M3e.Element.DatepickerToggle#Attrs).
-}
type alias ToggleAttrs =
    Toggle_.Attrs


{-| See [`M3e.Element.DatepickerToggle.Builder`](M3e.Element.DatepickerToggle#Builder).
-}
type alias ToggleBuilder attrCaps slotCaps msg kind =
    Toggle_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.DatepickerToggle.AttrCaps`](M3e.Element.DatepickerToggle#AttrCaps).
-}
type alias ToggleAttrCaps =
    Toggle_.AttrCaps


{-| See [`M3e.Element.DatepickerToggle.SlotCaps`](M3e.Element.DatepickerToggle#SlotCaps).
-}
type alias ToggleSlotCaps =
    Toggle_.SlotCaps


{-| See [`M3e.Element.DatepickerToggle.ChildAdmittedBy`](M3e.Element.DatepickerToggle#ChildAdmittedBy).
-}
type alias ToggleChildAdmittedBy childAdm =
    Toggle_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.DatepickerToggle.for`](M3e.Element.DatepickerToggle#for).
-}
toggleFor : String -> Attr { c | for : Supported } msg
toggleFor =
    Toggle_.for
