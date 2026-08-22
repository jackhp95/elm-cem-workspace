module Sl.Component.Range exposing (RangeIs, RangeAttrs, RangeBuilder, RangeAttrCaps, RangeSlotCaps, RangeChildAdmittedBy, RangeTooltip, range, rangeTooltip, rangeDisabled, rangeForm, rangeHelpText, rangeLabel, rangeMax, rangeMin, rangeName, rangeStep, rangeTitle, rangeValue, rangeDefaultValue, rangeOnBlur, rangeOnChange, rangeOnFocus, rangeOnInput, rangeOnInvalid)

{-| The **Range** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Range`](Sl.Element.Range) as `range`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs RangeIs, RangeAttrs, RangeBuilder, RangeAttrCaps, RangeSlotCaps, RangeChildAdmittedBy, RangeTooltip, range, rangeTooltip, rangeDisabled, rangeForm, rangeHelpText, rangeLabel, rangeMax, rangeMin, rangeName, rangeStep, rangeTitle, rangeValue, rangeDefaultValue, rangeOnBlur, rangeOnChange, rangeOnFocus, rangeOnInput, rangeOnInvalid

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Range as Range_


{-| The `range` element of this family — delegates to [`Sl.Element.Range.component`](Sl.Element.Range#component).
-}
range :
    List (Attr RangeAttrs msg)
    -> List (Element childAccepts (RangeChildAdmittedBy childAdm) msg)
    -> Element (RangeIs s) admittedBy msg
range =
    Range_.component


{-| See [`Sl.Element.Range.Is`](Sl.Element.Range#Is).
-}
type alias RangeIs s =
    Range_.Is s


{-| See [`Sl.Element.Range.Attrs`](Sl.Element.Range#Attrs).
-}
type alias RangeAttrs =
    Range_.Attrs


{-| See [`Sl.Element.Range.Builder`](Sl.Element.Range#Builder).
-}
type alias RangeBuilder attrCaps slotCaps msg kind =
    Range_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Range.AttrCaps`](Sl.Element.Range#AttrCaps).
-}
type alias RangeAttrCaps =
    Range_.AttrCaps


{-| See [`Sl.Element.Range.SlotCaps`](Sl.Element.Range#SlotCaps).
-}
type alias RangeSlotCaps =
    Range_.SlotCaps


{-| See [`Sl.Element.Range.ChildAdmittedBy`](Sl.Element.Range#ChildAdmittedBy).
-}
type alias RangeChildAdmittedBy childAdm =
    Range_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Range.Tooltip`](Sl.Element.Range#Tooltip).
-}
type alias RangeTooltip =
    Range_.Tooltip


{-| See [`Sl.Element.Range.tooltip`](Sl.Element.Range#tooltip).
-}
rangeTooltip : Value RangeTooltip -> Attr { c | tooltip : Supported } msg
rangeTooltip =
    Range_.tooltip


{-| See [`Sl.Element.Range.disabled`](Sl.Element.Range#disabled).
-}
rangeDisabled : Bool -> Attr { c | disabled : Supported } msg
rangeDisabled =
    Range_.disabled


{-| See [`Sl.Element.Range.form`](Sl.Element.Range#form).
-}
rangeForm : String -> Attr { c | form : Supported } msg
rangeForm =
    Range_.form


{-| See [`Sl.Element.Range.helpText`](Sl.Element.Range#helpText).
-}
rangeHelpText : String -> Attr { c | helpText : Supported } msg
rangeHelpText =
    Range_.helpText


{-| See [`Sl.Element.Range.label`](Sl.Element.Range#label).
-}
rangeLabel : String -> Attr { c | label : Supported } msg
rangeLabel =
    Range_.label


{-| See [`Sl.Element.Range.max`](Sl.Element.Range#max).
-}
rangeMax : Float -> Attr { c | max : Supported } msg
rangeMax =
    Range_.max


{-| See [`Sl.Element.Range.min`](Sl.Element.Range#min).
-}
rangeMin : Float -> Attr { c | min : Supported } msg
rangeMin =
    Range_.min


{-| See [`Sl.Element.Range.name`](Sl.Element.Range#name).
-}
rangeName : String -> Attr { c | name : Supported } msg
rangeName =
    Range_.name


{-| See [`Sl.Element.Range.step`](Sl.Element.Range#step).
-}
rangeStep : Float -> Attr { c | step : Supported } msg
rangeStep =
    Range_.step


{-| See [`Sl.Element.Range.title`](Sl.Element.Range#title).
-}
rangeTitle : String -> Attr { c | title : Supported } msg
rangeTitle =
    Range_.title


{-| See [`Sl.Element.Range.value`](Sl.Element.Range#value).
-}
rangeValue : Float -> Attr { c | value : Supported } msg
rangeValue =
    Range_.value


{-| See [`Sl.Element.Range.defaultValue`](Sl.Element.Range#defaultValue).
-}
rangeDefaultValue : Float -> Attr { c | value : Supported } msg
rangeDefaultValue =
    Range_.defaultValue


{-| See [`Sl.Element.Range.onBlur`](Sl.Element.Range#onBlur).
-}
rangeOnBlur : msg -> Attr { c | onBlur : Supported } msg
rangeOnBlur =
    Range_.onBlur


{-| See [`Sl.Element.Range.onChange`](Sl.Element.Range#onChange).
-}
rangeOnChange : msg -> Attr { c | onChange : Supported } msg
rangeOnChange =
    Range_.onChange


{-| See [`Sl.Element.Range.onFocus`](Sl.Element.Range#onFocus).
-}
rangeOnFocus : msg -> Attr { c | onFocus : Supported } msg
rangeOnFocus =
    Range_.onFocus


{-| See [`Sl.Element.Range.onInput`](Sl.Element.Range#onInput).
-}
rangeOnInput : msg -> Attr { c | onInput : Supported } msg
rangeOnInput =
    Range_.onInput


{-| See [`Sl.Element.Range.onInvalid`](Sl.Element.Range#onInvalid).
-}
rangeOnInvalid : msg -> Attr { c | onInvalid : Supported } msg
rangeOnInvalid =
    Range_.onInvalid
