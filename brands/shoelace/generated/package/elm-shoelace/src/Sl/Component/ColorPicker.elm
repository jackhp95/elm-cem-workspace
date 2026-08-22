module Sl.Component.ColorPicker exposing (ColorPickerIs, ColorPickerAttrs, ColorPickerBuilder, ColorPickerAttrCaps, ColorPickerSlotCaps, ColorPickerChildAdmittedBy, ColorPickerFormat, ColorPickerSize, colorPicker, colorPickerFormat, colorPickerSize, colorPickerDisabled, colorPickerForm, colorPickerHoist, colorPickerInline, colorPickerLabel, colorPickerName, colorPickerNoFormatToggle, colorPickerOpacity, colorPickerRequired, colorPickerSwatches, colorPickerUppercase, colorPickerValue, colorPickerDefaultValue, colorPickerOnBlur, colorPickerOnChange, colorPickerOnFocus, colorPickerOnInput, colorPickerOnInvalid)

{-| The **ColorPicker** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.ColorPicker`](Sl.Element.ColorPicker) as `colorPicker`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ColorPickerIs, ColorPickerAttrs, ColorPickerBuilder, ColorPickerAttrCaps, ColorPickerSlotCaps, ColorPickerChildAdmittedBy, ColorPickerFormat, ColorPickerSize, colorPicker, colorPickerFormat, colorPickerSize, colorPickerDisabled, colorPickerForm, colorPickerHoist, colorPickerInline, colorPickerLabel, colorPickerName, colorPickerNoFormatToggle, colorPickerOpacity, colorPickerRequired, colorPickerSwatches, colorPickerUppercase, colorPickerValue, colorPickerDefaultValue, colorPickerOnBlur, colorPickerOnChange, colorPickerOnFocus, colorPickerOnInput, colorPickerOnInvalid

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.ColorPicker as ColorPicker_


{-| The `colorPicker` element of this family — delegates to [`Sl.Element.ColorPicker.component`](Sl.Element.ColorPicker#component).
-}
colorPicker :
    List (Attr ColorPickerAttrs msg)
    -> List (Element childAccepts (ColorPickerChildAdmittedBy childAdm) msg)
    -> Element (ColorPickerIs s) admittedBy msg
colorPicker =
    ColorPicker_.component


{-| See [`Sl.Element.ColorPicker.Is`](Sl.Element.ColorPicker#Is).
-}
type alias ColorPickerIs s =
    ColorPicker_.Is s


{-| See [`Sl.Element.ColorPicker.Attrs`](Sl.Element.ColorPicker#Attrs).
-}
type alias ColorPickerAttrs =
    ColorPicker_.Attrs


{-| See [`Sl.Element.ColorPicker.Builder`](Sl.Element.ColorPicker#Builder).
-}
type alias ColorPickerBuilder attrCaps slotCaps msg kind =
    ColorPicker_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.ColorPicker.AttrCaps`](Sl.Element.ColorPicker#AttrCaps).
-}
type alias ColorPickerAttrCaps =
    ColorPicker_.AttrCaps


{-| See [`Sl.Element.ColorPicker.SlotCaps`](Sl.Element.ColorPicker#SlotCaps).
-}
type alias ColorPickerSlotCaps =
    ColorPicker_.SlotCaps


{-| See [`Sl.Element.ColorPicker.ChildAdmittedBy`](Sl.Element.ColorPicker#ChildAdmittedBy).
-}
type alias ColorPickerChildAdmittedBy childAdm =
    ColorPicker_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.ColorPicker.Format`](Sl.Element.ColorPicker#Format).
-}
type alias ColorPickerFormat =
    ColorPicker_.Format


{-| See [`Sl.Element.ColorPicker.format`](Sl.Element.ColorPicker#format).
-}
colorPickerFormat : Value ColorPickerFormat -> Attr { c | format : Supported } msg
colorPickerFormat =
    ColorPicker_.format


{-| See [`Sl.Element.ColorPicker.Size`](Sl.Element.ColorPicker#Size).
-}
type alias ColorPickerSize =
    ColorPicker_.Size


{-| See [`Sl.Element.ColorPicker.size`](Sl.Element.ColorPicker#size).
-}
colorPickerSize : Value ColorPickerSize -> Attr { c | size : Supported } msg
colorPickerSize =
    ColorPicker_.size


{-| See [`Sl.Element.ColorPicker.disabled`](Sl.Element.ColorPicker#disabled).
-}
colorPickerDisabled : Bool -> Attr { c | disabled : Supported } msg
colorPickerDisabled =
    ColorPicker_.disabled


{-| See [`Sl.Element.ColorPicker.form`](Sl.Element.ColorPicker#form).
-}
colorPickerForm : String -> Attr { c | form : Supported } msg
colorPickerForm =
    ColorPicker_.form


{-| See [`Sl.Element.ColorPicker.hoist`](Sl.Element.ColorPicker#hoist).
-}
colorPickerHoist : Bool -> Attr { c | hoist : Supported } msg
colorPickerHoist =
    ColorPicker_.hoist


{-| See [`Sl.Element.ColorPicker.inline`](Sl.Element.ColorPicker#inline).
-}
colorPickerInline : Bool -> Attr { c | inline : Supported } msg
colorPickerInline =
    ColorPicker_.inline


{-| See [`Sl.Element.ColorPicker.label`](Sl.Element.ColorPicker#label).
-}
colorPickerLabel : String -> Attr { c | label : Supported } msg
colorPickerLabel =
    ColorPicker_.label


{-| See [`Sl.Element.ColorPicker.name`](Sl.Element.ColorPicker#name).
-}
colorPickerName : String -> Attr { c | name : Supported } msg
colorPickerName =
    ColorPicker_.name


{-| See [`Sl.Element.ColorPicker.noFormatToggle`](Sl.Element.ColorPicker#noFormatToggle).
-}
colorPickerNoFormatToggle : Bool -> Attr { c | noFormatToggle : Supported } msg
colorPickerNoFormatToggle =
    ColorPicker_.noFormatToggle


{-| See [`Sl.Element.ColorPicker.opacity`](Sl.Element.ColorPicker#opacity).
-}
colorPickerOpacity : Bool -> Attr { c | opacity : Supported } msg
colorPickerOpacity =
    ColorPicker_.opacity


{-| See [`Sl.Element.ColorPicker.required`](Sl.Element.ColorPicker#required).
-}
colorPickerRequired : Bool -> Attr { c | required : Supported } msg
colorPickerRequired =
    ColorPicker_.required


{-| See [`Sl.Element.ColorPicker.swatches`](Sl.Element.ColorPicker#swatches).
-}
colorPickerSwatches : String -> Attr { c | swatches : Supported } msg
colorPickerSwatches =
    ColorPicker_.swatches


{-| See [`Sl.Element.ColorPicker.uppercase`](Sl.Element.ColorPicker#uppercase).
-}
colorPickerUppercase : Bool -> Attr { c | uppercase : Supported } msg
colorPickerUppercase =
    ColorPicker_.uppercase


{-| See [`Sl.Element.ColorPicker.value`](Sl.Element.ColorPicker#value).
-}
colorPickerValue : String -> Attr { c | value : Supported } msg
colorPickerValue =
    ColorPicker_.value


{-| See [`Sl.Element.ColorPicker.defaultValue`](Sl.Element.ColorPicker#defaultValue).
-}
colorPickerDefaultValue : String -> Attr { c | value : Supported } msg
colorPickerDefaultValue =
    ColorPicker_.defaultValue


{-| See [`Sl.Element.ColorPicker.onBlur`](Sl.Element.ColorPicker#onBlur).
-}
colorPickerOnBlur : msg -> Attr { c | onBlur : Supported } msg
colorPickerOnBlur =
    ColorPicker_.onBlur


{-| See [`Sl.Element.ColorPicker.onChange`](Sl.Element.ColorPicker#onChange).
-}
colorPickerOnChange : msg -> Attr { c | onChange : Supported } msg
colorPickerOnChange =
    ColorPicker_.onChange


{-| See [`Sl.Element.ColorPicker.onFocus`](Sl.Element.ColorPicker#onFocus).
-}
colorPickerOnFocus : msg -> Attr { c | onFocus : Supported } msg
colorPickerOnFocus =
    ColorPicker_.onFocus


{-| See [`Sl.Element.ColorPicker.onInput`](Sl.Element.ColorPicker#onInput).
-}
colorPickerOnInput : msg -> Attr { c | onInput : Supported } msg
colorPickerOnInput =
    ColorPicker_.onInput


{-| See [`Sl.Element.ColorPicker.onInvalid`](Sl.Element.ColorPicker#onInvalid).
-}
colorPickerOnInvalid : msg -> Attr { c | onInvalid : Supported } msg
colorPickerOnInvalid =
    ColorPicker_.onInvalid
