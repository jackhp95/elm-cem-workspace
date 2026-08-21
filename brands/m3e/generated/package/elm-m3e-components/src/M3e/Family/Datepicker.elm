module M3e.Family.Datepicker exposing (DatepickerIs, DatepickerAttrs, DatepickerBuilder, DatepickerAttrCaps, DatepickerSlotCaps, DatepickerChildAdmittedBy, DatepickerStartView, DatepickerVariant, ToggleIs, ToggleAttrs, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleChildAdmittedBy, datepicker, datepickerStartView, datepickerVariant, datepickerClearLabel, datepickerClearable, datepickerConfirmLabel, datepickerDate, datepickerDismissLabel, datepickerFor, datepickerLabel, datepickerMaxDate, datepickerMinDate, datepickerNextMonthLabel, datepickerNextMultiYearLabel, datepickerNextYearLabel, datepickerPreviousMonthLabel, datepickerPreviousMultiYearLabel, datepickerPreviousYearLabel, datepickerRange, datepickerRangeEnd, datepickerRangeStart, datepickerStartAt, datepickerOnChange, datepickerOnBeforetoggle, datepickerOnToggle, toggle, toggleFor)

{-| The **Datepicker** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.Datepicker`](M3e.Component.Datepicker) as `datepicker`, [`M3e.Component.DatepickerToggle`](M3e.Component.DatepickerToggle) as `toggle`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs DatepickerIs, DatepickerAttrs, DatepickerBuilder, DatepickerAttrCaps, DatepickerSlotCaps, DatepickerChildAdmittedBy, DatepickerStartView, DatepickerVariant, ToggleIs, ToggleAttrs, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleChildAdmittedBy, datepicker, datepickerStartView, datepickerVariant, datepickerClearLabel, datepickerClearable, datepickerConfirmLabel, datepickerDate, datepickerDismissLabel, datepickerFor, datepickerLabel, datepickerMaxDate, datepickerMinDate, datepickerNextMonthLabel, datepickerNextMultiYearLabel, datepickerNextYearLabel, datepickerPreviousMonthLabel, datepickerPreviousMultiYearLabel, datepickerPreviousYearLabel, datepickerRange, datepickerRangeEnd, datepickerRangeStart, datepickerStartAt, datepickerOnChange, datepickerOnBeforetoggle, datepickerOnToggle, toggle, toggleFor

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Component.Datepicker as Datepicker_
import M3e.Component.DatepickerToggle as Toggle_


{-| The `datepicker` element of this family — delegates to [`M3e.Component.Datepicker.component`](M3e.Component.Datepicker#component).
-}
datepicker :
    List (Attr DatepickerAttrs msg)
    -> List (Element childAccepts (DatepickerChildAdmittedBy childAdm) msg)
    -> Element (DatepickerIs s) admittedBy msg
datepicker =
    Datepicker_.component


{-| See [`M3e.Component.Datepicker.Is`](M3e.Component.Datepicker#Is).
-}
type alias DatepickerIs s =
    Datepicker_.Is s


{-| See [`M3e.Component.Datepicker.Attrs`](M3e.Component.Datepicker#Attrs).
-}
type alias DatepickerAttrs =
    Datepicker_.Attrs


{-| See [`M3e.Component.Datepicker.Builder`](M3e.Component.Datepicker#Builder).
-}
type alias DatepickerBuilder attrCaps slotCaps msg kind =
    Datepicker_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.Datepicker.AttrCaps`](M3e.Component.Datepicker#AttrCaps).
-}
type alias DatepickerAttrCaps =
    Datepicker_.AttrCaps


{-| See [`M3e.Component.Datepicker.SlotCaps`](M3e.Component.Datepicker#SlotCaps).
-}
type alias DatepickerSlotCaps =
    Datepicker_.SlotCaps


{-| See [`M3e.Component.Datepicker.ChildAdmittedBy`](M3e.Component.Datepicker#ChildAdmittedBy).
-}
type alias DatepickerChildAdmittedBy childAdm =
    Datepicker_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.Datepicker.StartView`](M3e.Component.Datepicker#StartView).
-}
type alias DatepickerStartView =
    Datepicker_.StartView


{-| See [`M3e.Component.Datepicker.startView`](M3e.Component.Datepicker#startView).
-}
datepickerStartView : Value DatepickerStartView -> Attr { c | startView : Supported } msg
datepickerStartView =
    Datepicker_.startView


{-| See [`M3e.Component.Datepicker.Variant`](M3e.Component.Datepicker#Variant).
-}
type alias DatepickerVariant =
    Datepicker_.Variant


{-| See [`M3e.Component.Datepicker.variant`](M3e.Component.Datepicker#variant).
-}
datepickerVariant : Value DatepickerVariant -> Attr { c | variant : Supported } msg
datepickerVariant =
    Datepicker_.variant


{-| See [`M3e.Component.Datepicker.clearLabel`](M3e.Component.Datepicker#clearLabel).
-}
datepickerClearLabel : String -> Attr { c | clearLabel : Supported } msg
datepickerClearLabel =
    Datepicker_.clearLabel


{-| See [`M3e.Component.Datepicker.clearable`](M3e.Component.Datepicker#clearable).
-}
datepickerClearable : Bool -> Attr { c | clearable : Supported } msg
datepickerClearable =
    Datepicker_.clearable


{-| See [`M3e.Component.Datepicker.confirmLabel`](M3e.Component.Datepicker#confirmLabel).
-}
datepickerConfirmLabel : String -> Attr { c | confirmLabel : Supported } msg
datepickerConfirmLabel =
    Datepicker_.confirmLabel


{-| See [`M3e.Component.Datepicker.date`](M3e.Component.Datepicker#date).
-}
datepickerDate : String -> Attr { c | date : Supported } msg
datepickerDate =
    Datepicker_.date


{-| See [`M3e.Component.Datepicker.dismissLabel`](M3e.Component.Datepicker#dismissLabel).
-}
datepickerDismissLabel : String -> Attr { c | dismissLabel : Supported } msg
datepickerDismissLabel =
    Datepicker_.dismissLabel


{-| See [`M3e.Component.Datepicker.for`](M3e.Component.Datepicker#for).
-}
datepickerFor : String -> Attr { c | for : Supported } msg
datepickerFor =
    Datepicker_.for


{-| See [`M3e.Component.Datepicker.label`](M3e.Component.Datepicker#label).
-}
datepickerLabel : String -> Attr { c | label : Supported } msg
datepickerLabel =
    Datepicker_.label


{-| See [`M3e.Component.Datepicker.maxDate`](M3e.Component.Datepicker#maxDate).
-}
datepickerMaxDate : String -> Attr { c | maxDate : Supported } msg
datepickerMaxDate =
    Datepicker_.maxDate


{-| See [`M3e.Component.Datepicker.minDate`](M3e.Component.Datepicker#minDate).
-}
datepickerMinDate : String -> Attr { c | minDate : Supported } msg
datepickerMinDate =
    Datepicker_.minDate


{-| See [`M3e.Component.Datepicker.nextMonthLabel`](M3e.Component.Datepicker#nextMonthLabel).
-}
datepickerNextMonthLabel : String -> Attr { c | nextMonthLabel : Supported } msg
datepickerNextMonthLabel =
    Datepicker_.nextMonthLabel


{-| See [`M3e.Component.Datepicker.nextMultiYearLabel`](M3e.Component.Datepicker#nextMultiYearLabel).
-}
datepickerNextMultiYearLabel : String -> Attr { c | nextMultiYearLabel : Supported } msg
datepickerNextMultiYearLabel =
    Datepicker_.nextMultiYearLabel


{-| See [`M3e.Component.Datepicker.nextYearLabel`](M3e.Component.Datepicker#nextYearLabel).
-}
datepickerNextYearLabel : String -> Attr { c | nextYearLabel : Supported } msg
datepickerNextYearLabel =
    Datepicker_.nextYearLabel


{-| See [`M3e.Component.Datepicker.previousMonthLabel`](M3e.Component.Datepicker#previousMonthLabel).
-}
datepickerPreviousMonthLabel : String -> Attr { c | previousMonthLabel : Supported } msg
datepickerPreviousMonthLabel =
    Datepicker_.previousMonthLabel


{-| See [`M3e.Component.Datepicker.previousMultiYearLabel`](M3e.Component.Datepicker#previousMultiYearLabel).
-}
datepickerPreviousMultiYearLabel : String -> Attr { c | previousMultiYearLabel : Supported } msg
datepickerPreviousMultiYearLabel =
    Datepicker_.previousMultiYearLabel


{-| See [`M3e.Component.Datepicker.previousYearLabel`](M3e.Component.Datepicker#previousYearLabel).
-}
datepickerPreviousYearLabel : String -> Attr { c | previousYearLabel : Supported } msg
datepickerPreviousYearLabel =
    Datepicker_.previousYearLabel


{-| See [`M3e.Component.Datepicker.range`](M3e.Component.Datepicker#range).
-}
datepickerRange : Bool -> Attr { c | range : Supported } msg
datepickerRange =
    Datepicker_.range


{-| See [`M3e.Component.Datepicker.rangeEnd`](M3e.Component.Datepicker#rangeEnd).
-}
datepickerRangeEnd : String -> Attr { c | rangeEnd : Supported } msg
datepickerRangeEnd =
    Datepicker_.rangeEnd


{-| See [`M3e.Component.Datepicker.rangeStart`](M3e.Component.Datepicker#rangeStart).
-}
datepickerRangeStart : String -> Attr { c | rangeStart : Supported } msg
datepickerRangeStart =
    Datepicker_.rangeStart


{-| See [`M3e.Component.Datepicker.startAt`](M3e.Component.Datepicker#startAt).
-}
datepickerStartAt : String -> Attr { c | startAt : Supported } msg
datepickerStartAt =
    Datepicker_.startAt


{-| See [`M3e.Component.Datepicker.onChange`](M3e.Component.Datepicker#onChange).
-}
datepickerOnChange : (String -> msg) -> Attr { c | onChange : Supported } msg
datepickerOnChange =
    Datepicker_.onChange


{-| See [`M3e.Component.Datepicker.onBeforetoggle`](M3e.Component.Datepicker#onBeforetoggle).
-}
datepickerOnBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
datepickerOnBeforetoggle =
    Datepicker_.onBeforetoggle


{-| See [`M3e.Component.Datepicker.onToggle`](M3e.Component.Datepicker#onToggle).
-}
datepickerOnToggle : msg -> Attr { c | onToggle : Supported } msg
datepickerOnToggle =
    Datepicker_.onToggle


{-| The `toggle` element of this family — delegates to [`M3e.Component.DatepickerToggle.component`](M3e.Component.DatepickerToggle#component).
-}
toggle :
    List (Attr ToggleAttrs msg)
    -> List (Element childAccepts (ToggleChildAdmittedBy childAdm) msg)
    -> Element (ToggleIs s) admittedBy msg
toggle =
    Toggle_.component


{-| See [`M3e.Component.DatepickerToggle.Is`](M3e.Component.DatepickerToggle#Is).
-}
type alias ToggleIs s =
    Toggle_.Is s


{-| See [`M3e.Component.DatepickerToggle.Attrs`](M3e.Component.DatepickerToggle#Attrs).
-}
type alias ToggleAttrs =
    Toggle_.Attrs


{-| See [`M3e.Component.DatepickerToggle.Builder`](M3e.Component.DatepickerToggle#Builder).
-}
type alias ToggleBuilder attrCaps slotCaps msg kind =
    Toggle_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.DatepickerToggle.AttrCaps`](M3e.Component.DatepickerToggle#AttrCaps).
-}
type alias ToggleAttrCaps =
    Toggle_.AttrCaps


{-| See [`M3e.Component.DatepickerToggle.SlotCaps`](M3e.Component.DatepickerToggle#SlotCaps).
-}
type alias ToggleSlotCaps =
    Toggle_.SlotCaps


{-| See [`M3e.Component.DatepickerToggle.ChildAdmittedBy`](M3e.Component.DatepickerToggle#ChildAdmittedBy).
-}
type alias ToggleChildAdmittedBy childAdm =
    Toggle_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.DatepickerToggle.for`](M3e.Component.DatepickerToggle#for).
-}
toggleFor : String -> Attr { c | for : Supported } msg
toggleFor =
    Toggle_.for
