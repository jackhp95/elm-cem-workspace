module Sl.Component.Input exposing (InputIs, InputAttrs, InputBuilder, InputAttrCaps, InputSlotCaps, InputChildAdmittedBy, InputAutocapitalize, InputAutocorrect, InputEnterkeyhint, InputInputmode, InputSize, InputType, input, inputAutocapitalize, inputAutocorrect, inputEnterkeyhint, inputInputmode, inputSize, inputType_, inputAutocomplete, inputAutofocus, inputClearable, inputDisabled, inputFilled, inputForm, inputHelpText, inputLabel, inputMax, inputMaxlength, inputMin, inputMinlength, inputName, inputNoSpinButtons, inputPasswordToggle, inputPasswordVisible, inputPattern, inputPill, inputPlaceholder, inputReadonly, inputRequired, inputSpellcheck, inputStep, inputTitle, inputValue, inputDefaultValue, inputOnBlur, inputOnChange, inputOnClear, inputOnFocus, inputOnInput, inputOnInvalid)

{-| The **Input** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Input`](Sl.Element.Input) as `input`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs InputIs, InputAttrs, InputBuilder, InputAttrCaps, InputSlotCaps, InputChildAdmittedBy, InputAutocapitalize, InputAutocorrect, InputEnterkeyhint, InputInputmode, InputSize, InputType, input, inputAutocapitalize, inputAutocorrect, inputEnterkeyhint, inputInputmode, inputSize, inputType_, inputAutocomplete, inputAutofocus, inputClearable, inputDisabled, inputFilled, inputForm, inputHelpText, inputLabel, inputMax, inputMaxlength, inputMin, inputMinlength, inputName, inputNoSpinButtons, inputPasswordToggle, inputPasswordVisible, inputPattern, inputPill, inputPlaceholder, inputReadonly, inputRequired, inputSpellcheck, inputStep, inputTitle, inputValue, inputDefaultValue, inputOnBlur, inputOnChange, inputOnClear, inputOnFocus, inputOnInput, inputOnInvalid

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Input as Input_


{-| The `input` element of this family — delegates to [`Sl.Element.Input.component`](Sl.Element.Input#component).
-}
input :
    List (Attr InputAttrs msg)
    -> List (Element childAccepts (InputChildAdmittedBy childAdm) msg)
    -> Element (InputIs s) admittedBy msg
input =
    Input_.component


{-| See [`Sl.Element.Input.Is`](Sl.Element.Input#Is).
-}
type alias InputIs s =
    Input_.Is s


{-| See [`Sl.Element.Input.Attrs`](Sl.Element.Input#Attrs).
-}
type alias InputAttrs =
    Input_.Attrs


{-| See [`Sl.Element.Input.Builder`](Sl.Element.Input#Builder).
-}
type alias InputBuilder attrCaps slotCaps msg kind =
    Input_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Input.AttrCaps`](Sl.Element.Input#AttrCaps).
-}
type alias InputAttrCaps =
    Input_.AttrCaps


{-| See [`Sl.Element.Input.SlotCaps`](Sl.Element.Input#SlotCaps).
-}
type alias InputSlotCaps =
    Input_.SlotCaps


{-| See [`Sl.Element.Input.ChildAdmittedBy`](Sl.Element.Input#ChildAdmittedBy).
-}
type alias InputChildAdmittedBy childAdm =
    Input_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Input.Autocapitalize`](Sl.Element.Input#Autocapitalize).
-}
type alias InputAutocapitalize =
    Input_.Autocapitalize


{-| See [`Sl.Element.Input.autocapitalize`](Sl.Element.Input#autocapitalize).
-}
inputAutocapitalize : Value InputAutocapitalize -> Attr { c | autocapitalize : Supported } msg
inputAutocapitalize =
    Input_.autocapitalize


{-| See [`Sl.Element.Input.Autocorrect`](Sl.Element.Input#Autocorrect).
-}
type alias InputAutocorrect =
    Input_.Autocorrect


{-| See [`Sl.Element.Input.autocorrect`](Sl.Element.Input#autocorrect).
-}
inputAutocorrect : Value InputAutocorrect -> Attr { c | autocorrect : Supported } msg
inputAutocorrect =
    Input_.autocorrect


{-| See [`Sl.Element.Input.Enterkeyhint`](Sl.Element.Input#Enterkeyhint).
-}
type alias InputEnterkeyhint =
    Input_.Enterkeyhint


{-| See [`Sl.Element.Input.enterkeyhint`](Sl.Element.Input#enterkeyhint).
-}
inputEnterkeyhint : Value InputEnterkeyhint -> Attr { c | enterkeyhint : Supported } msg
inputEnterkeyhint =
    Input_.enterkeyhint


{-| See [`Sl.Element.Input.Inputmode`](Sl.Element.Input#Inputmode).
-}
type alias InputInputmode =
    Input_.Inputmode


{-| See [`Sl.Element.Input.inputmode`](Sl.Element.Input#inputmode).
-}
inputInputmode : Value InputInputmode -> Attr { c | inputmode : Supported } msg
inputInputmode =
    Input_.inputmode


{-| See [`Sl.Element.Input.Size`](Sl.Element.Input#Size).
-}
type alias InputSize =
    Input_.Size


{-| See [`Sl.Element.Input.size`](Sl.Element.Input#size).
-}
inputSize : Value InputSize -> Attr { c | size : Supported } msg
inputSize =
    Input_.size


{-| See [`Sl.Element.Input.Type`](Sl.Element.Input#Type).
-}
type alias InputType =
    Input_.Type


{-| See [`Sl.Element.Input.type_`](Sl.Element.Input#type_).
-}
inputType_ : Value InputType -> Attr { c | type_ : Supported } msg
inputType_ =
    Input_.type_


{-| See [`Sl.Element.Input.autocomplete`](Sl.Element.Input#autocomplete).
-}
inputAutocomplete : String -> Attr { c | autocomplete : Supported } msg
inputAutocomplete =
    Input_.autocomplete


{-| See [`Sl.Element.Input.autofocus`](Sl.Element.Input#autofocus).
-}
inputAutofocus : Bool -> Attr { c | autofocus : Supported } msg
inputAutofocus =
    Input_.autofocus


{-| See [`Sl.Element.Input.clearable`](Sl.Element.Input#clearable).
-}
inputClearable : Bool -> Attr { c | clearable : Supported } msg
inputClearable =
    Input_.clearable


{-| See [`Sl.Element.Input.disabled`](Sl.Element.Input#disabled).
-}
inputDisabled : Bool -> Attr { c | disabled : Supported } msg
inputDisabled =
    Input_.disabled


{-| See [`Sl.Element.Input.filled`](Sl.Element.Input#filled).
-}
inputFilled : Bool -> Attr { c | filled : Supported } msg
inputFilled =
    Input_.filled


{-| See [`Sl.Element.Input.form`](Sl.Element.Input#form).
-}
inputForm : String -> Attr { c | form : Supported } msg
inputForm =
    Input_.form


{-| See [`Sl.Element.Input.helpText`](Sl.Element.Input#helpText).
-}
inputHelpText : String -> Attr { c | helpText : Supported } msg
inputHelpText =
    Input_.helpText


{-| See [`Sl.Element.Input.label`](Sl.Element.Input#label).
-}
inputLabel : String -> Attr { c | label : Supported } msg
inputLabel =
    Input_.label


{-| See [`Sl.Element.Input.max`](Sl.Element.Input#max).
-}
inputMax : String -> Attr { c | max : Supported } msg
inputMax =
    Input_.max


{-| See [`Sl.Element.Input.maxlength`](Sl.Element.Input#maxlength).
-}
inputMaxlength : Float -> Attr { c | maxlength : Supported } msg
inputMaxlength =
    Input_.maxlength


{-| See [`Sl.Element.Input.min`](Sl.Element.Input#min).
-}
inputMin : String -> Attr { c | min : Supported } msg
inputMin =
    Input_.min


{-| See [`Sl.Element.Input.minlength`](Sl.Element.Input#minlength).
-}
inputMinlength : Float -> Attr { c | minlength : Supported } msg
inputMinlength =
    Input_.minlength


{-| See [`Sl.Element.Input.name`](Sl.Element.Input#name).
-}
inputName : String -> Attr { c | name : Supported } msg
inputName =
    Input_.name


{-| See [`Sl.Element.Input.noSpinButtons`](Sl.Element.Input#noSpinButtons).
-}
inputNoSpinButtons : Bool -> Attr { c | noSpinButtons : Supported } msg
inputNoSpinButtons =
    Input_.noSpinButtons


{-| See [`Sl.Element.Input.passwordToggle`](Sl.Element.Input#passwordToggle).
-}
inputPasswordToggle : Bool -> Attr { c | passwordToggle : Supported } msg
inputPasswordToggle =
    Input_.passwordToggle


{-| See [`Sl.Element.Input.passwordVisible`](Sl.Element.Input#passwordVisible).
-}
inputPasswordVisible : Bool -> Attr { c | passwordVisible : Supported } msg
inputPasswordVisible =
    Input_.passwordVisible


{-| See [`Sl.Element.Input.pattern`](Sl.Element.Input#pattern).
-}
inputPattern : String -> Attr { c | pattern : Supported } msg
inputPattern =
    Input_.pattern


{-| See [`Sl.Element.Input.pill`](Sl.Element.Input#pill).
-}
inputPill : Bool -> Attr { c | pill : Supported } msg
inputPill =
    Input_.pill


{-| See [`Sl.Element.Input.placeholder`](Sl.Element.Input#placeholder).
-}
inputPlaceholder : String -> Attr { c | placeholder : Supported } msg
inputPlaceholder =
    Input_.placeholder


{-| See [`Sl.Element.Input.readonly`](Sl.Element.Input#readonly).
-}
inputReadonly : Bool -> Attr { c | readonly : Supported } msg
inputReadonly =
    Input_.readonly


{-| See [`Sl.Element.Input.required`](Sl.Element.Input#required).
-}
inputRequired : Bool -> Attr { c | required : Supported } msg
inputRequired =
    Input_.required


{-| See [`Sl.Element.Input.spellcheck`](Sl.Element.Input#spellcheck).
-}
inputSpellcheck : Bool -> Attr { c | spellcheck : Supported } msg
inputSpellcheck =
    Input_.spellcheck


{-| See [`Sl.Element.Input.step`](Sl.Element.Input#step).
-}
inputStep : String -> Attr { c | step : Supported } msg
inputStep =
    Input_.step


{-| See [`Sl.Element.Input.title`](Sl.Element.Input#title).
-}
inputTitle : String -> Attr { c | title : Supported } msg
inputTitle =
    Input_.title


{-| See [`Sl.Element.Input.value`](Sl.Element.Input#value).
-}
inputValue : String -> Attr { c | value : Supported } msg
inputValue =
    Input_.value


{-| See [`Sl.Element.Input.defaultValue`](Sl.Element.Input#defaultValue).
-}
inputDefaultValue : String -> Attr { c | value : Supported } msg
inputDefaultValue =
    Input_.defaultValue


{-| See [`Sl.Element.Input.onBlur`](Sl.Element.Input#onBlur).
-}
inputOnBlur : msg -> Attr { c | onBlur : Supported } msg
inputOnBlur =
    Input_.onBlur


{-| See [`Sl.Element.Input.onChange`](Sl.Element.Input#onChange).
-}
inputOnChange : msg -> Attr { c | onChange : Supported } msg
inputOnChange =
    Input_.onChange


{-| See [`Sl.Element.Input.onClear`](Sl.Element.Input#onClear).
-}
inputOnClear : msg -> Attr { c | onClear : Supported } msg
inputOnClear =
    Input_.onClear


{-| See [`Sl.Element.Input.onFocus`](Sl.Element.Input#onFocus).
-}
inputOnFocus : msg -> Attr { c | onFocus : Supported } msg
inputOnFocus =
    Input_.onFocus


{-| See [`Sl.Element.Input.onInput`](Sl.Element.Input#onInput).
-}
inputOnInput : msg -> Attr { c | onInput : Supported } msg
inputOnInput =
    Input_.onInput


{-| See [`Sl.Element.Input.onInvalid`](Sl.Element.Input#onInvalid).
-}
inputOnInvalid : msg -> Attr { c | onInvalid : Supported } msg
inputOnInvalid =
    Input_.onInvalid
