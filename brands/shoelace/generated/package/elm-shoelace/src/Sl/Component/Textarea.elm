module Sl.Component.Textarea exposing (TextareaIs, TextareaAttrs, TextareaBuilder, TextareaAttrCaps, TextareaSlotCaps, TextareaChildAdmittedBy, TextareaAutocapitalize, TextareaEnterkeyhint, TextareaInputmode, TextareaResize, TextareaSize, textarea, textareaAutocapitalize, textareaEnterkeyhint, textareaInputmode, textareaResize, textareaSize, textareaAutocomplete, textareaAutocorrect, textareaAutofocus, textareaDisabled, textareaFilled, textareaForm, textareaHelpText, textareaLabel, textareaMaxlength, textareaMinlength, textareaName, textareaPlaceholder, textareaReadonly, textareaRequired, textareaRows, textareaSpellcheck, textareaTitle, textareaValue, textareaDefaultValue, textareaOnBlur, textareaOnChange, textareaOnFocus, textareaOnInput, textareaOnInvalid)

{-| The **Textarea** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Textarea`](Sl.Element.Textarea) as `textarea`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs TextareaIs, TextareaAttrs, TextareaBuilder, TextareaAttrCaps, TextareaSlotCaps, TextareaChildAdmittedBy, TextareaAutocapitalize, TextareaEnterkeyhint, TextareaInputmode, TextareaResize, TextareaSize, textarea, textareaAutocapitalize, textareaEnterkeyhint, textareaInputmode, textareaResize, textareaSize, textareaAutocomplete, textareaAutocorrect, textareaAutofocus, textareaDisabled, textareaFilled, textareaForm, textareaHelpText, textareaLabel, textareaMaxlength, textareaMinlength, textareaName, textareaPlaceholder, textareaReadonly, textareaRequired, textareaRows, textareaSpellcheck, textareaTitle, textareaValue, textareaDefaultValue, textareaOnBlur, textareaOnChange, textareaOnFocus, textareaOnInput, textareaOnInvalid

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Textarea as Textarea_


{-| The `textarea` element of this family — delegates to [`Sl.Element.Textarea.component`](Sl.Element.Textarea#component).
-}
textarea :
    List (Attr TextareaAttrs msg)
    -> List (Element childAccepts (TextareaChildAdmittedBy childAdm) msg)
    -> Element (TextareaIs s) admittedBy msg
textarea =
    Textarea_.component


{-| See [`Sl.Element.Textarea.Is`](Sl.Element.Textarea#Is).
-}
type alias TextareaIs s =
    Textarea_.Is s


{-| See [`Sl.Element.Textarea.Attrs`](Sl.Element.Textarea#Attrs).
-}
type alias TextareaAttrs =
    Textarea_.Attrs


{-| See [`Sl.Element.Textarea.Builder`](Sl.Element.Textarea#Builder).
-}
type alias TextareaBuilder attrCaps slotCaps msg kind =
    Textarea_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Textarea.AttrCaps`](Sl.Element.Textarea#AttrCaps).
-}
type alias TextareaAttrCaps =
    Textarea_.AttrCaps


{-| See [`Sl.Element.Textarea.SlotCaps`](Sl.Element.Textarea#SlotCaps).
-}
type alias TextareaSlotCaps =
    Textarea_.SlotCaps


{-| See [`Sl.Element.Textarea.ChildAdmittedBy`](Sl.Element.Textarea#ChildAdmittedBy).
-}
type alias TextareaChildAdmittedBy childAdm =
    Textarea_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Textarea.Autocapitalize`](Sl.Element.Textarea#Autocapitalize).
-}
type alias TextareaAutocapitalize =
    Textarea_.Autocapitalize


{-| See [`Sl.Element.Textarea.autocapitalize`](Sl.Element.Textarea#autocapitalize).
-}
textareaAutocapitalize : Value TextareaAutocapitalize -> Attr { c | autocapitalize : Supported } msg
textareaAutocapitalize =
    Textarea_.autocapitalize


{-| See [`Sl.Element.Textarea.Enterkeyhint`](Sl.Element.Textarea#Enterkeyhint).
-}
type alias TextareaEnterkeyhint =
    Textarea_.Enterkeyhint


{-| See [`Sl.Element.Textarea.enterkeyhint`](Sl.Element.Textarea#enterkeyhint).
-}
textareaEnterkeyhint : Value TextareaEnterkeyhint -> Attr { c | enterkeyhint : Supported } msg
textareaEnterkeyhint =
    Textarea_.enterkeyhint


{-| See [`Sl.Element.Textarea.Inputmode`](Sl.Element.Textarea#Inputmode).
-}
type alias TextareaInputmode =
    Textarea_.Inputmode


{-| See [`Sl.Element.Textarea.inputmode`](Sl.Element.Textarea#inputmode).
-}
textareaInputmode : Value TextareaInputmode -> Attr { c | inputmode : Supported } msg
textareaInputmode =
    Textarea_.inputmode


{-| See [`Sl.Element.Textarea.Resize`](Sl.Element.Textarea#Resize).
-}
type alias TextareaResize =
    Textarea_.Resize


{-| See [`Sl.Element.Textarea.resize`](Sl.Element.Textarea#resize).
-}
textareaResize : Value TextareaResize -> Attr { c | resize : Supported } msg
textareaResize =
    Textarea_.resize


{-| See [`Sl.Element.Textarea.Size`](Sl.Element.Textarea#Size).
-}
type alias TextareaSize =
    Textarea_.Size


{-| See [`Sl.Element.Textarea.size`](Sl.Element.Textarea#size).
-}
textareaSize : Value TextareaSize -> Attr { c | size : Supported } msg
textareaSize =
    Textarea_.size


{-| See [`Sl.Element.Textarea.autocomplete`](Sl.Element.Textarea#autocomplete).
-}
textareaAutocomplete : String -> Attr { c | autocomplete : Supported } msg
textareaAutocomplete =
    Textarea_.autocomplete


{-| See [`Sl.Element.Textarea.autocorrect`](Sl.Element.Textarea#autocorrect).
-}
textareaAutocorrect : String -> Attr { c | autocorrect : Supported } msg
textareaAutocorrect =
    Textarea_.autocorrect


{-| See [`Sl.Element.Textarea.autofocus`](Sl.Element.Textarea#autofocus).
-}
textareaAutofocus : Bool -> Attr { c | autofocus : Supported } msg
textareaAutofocus =
    Textarea_.autofocus


{-| See [`Sl.Element.Textarea.disabled`](Sl.Element.Textarea#disabled).
-}
textareaDisabled : Bool -> Attr { c | disabled : Supported } msg
textareaDisabled =
    Textarea_.disabled


{-| See [`Sl.Element.Textarea.filled`](Sl.Element.Textarea#filled).
-}
textareaFilled : Bool -> Attr { c | filled : Supported } msg
textareaFilled =
    Textarea_.filled


{-| See [`Sl.Element.Textarea.form`](Sl.Element.Textarea#form).
-}
textareaForm : String -> Attr { c | form : Supported } msg
textareaForm =
    Textarea_.form


{-| See [`Sl.Element.Textarea.helpText`](Sl.Element.Textarea#helpText).
-}
textareaHelpText : String -> Attr { c | helpText : Supported } msg
textareaHelpText =
    Textarea_.helpText


{-| See [`Sl.Element.Textarea.label`](Sl.Element.Textarea#label).
-}
textareaLabel : String -> Attr { c | label : Supported } msg
textareaLabel =
    Textarea_.label


{-| See [`Sl.Element.Textarea.maxlength`](Sl.Element.Textarea#maxlength).
-}
textareaMaxlength : Float -> Attr { c | maxlength : Supported } msg
textareaMaxlength =
    Textarea_.maxlength


{-| See [`Sl.Element.Textarea.minlength`](Sl.Element.Textarea#minlength).
-}
textareaMinlength : Float -> Attr { c | minlength : Supported } msg
textareaMinlength =
    Textarea_.minlength


{-| See [`Sl.Element.Textarea.name`](Sl.Element.Textarea#name).
-}
textareaName : String -> Attr { c | name : Supported } msg
textareaName =
    Textarea_.name


{-| See [`Sl.Element.Textarea.placeholder`](Sl.Element.Textarea#placeholder).
-}
textareaPlaceholder : String -> Attr { c | placeholder : Supported } msg
textareaPlaceholder =
    Textarea_.placeholder


{-| See [`Sl.Element.Textarea.readonly`](Sl.Element.Textarea#readonly).
-}
textareaReadonly : Bool -> Attr { c | readonly : Supported } msg
textareaReadonly =
    Textarea_.readonly


{-| See [`Sl.Element.Textarea.required`](Sl.Element.Textarea#required).
-}
textareaRequired : Bool -> Attr { c | required : Supported } msg
textareaRequired =
    Textarea_.required


{-| See [`Sl.Element.Textarea.rows`](Sl.Element.Textarea#rows).
-}
textareaRows : Float -> Attr { c | rows : Supported } msg
textareaRows =
    Textarea_.rows


{-| See [`Sl.Element.Textarea.spellcheck`](Sl.Element.Textarea#spellcheck).
-}
textareaSpellcheck : Bool -> Attr { c | spellcheck : Supported } msg
textareaSpellcheck =
    Textarea_.spellcheck


{-| See [`Sl.Element.Textarea.title`](Sl.Element.Textarea#title).
-}
textareaTitle : String -> Attr { c | title : Supported } msg
textareaTitle =
    Textarea_.title


{-| See [`Sl.Element.Textarea.value`](Sl.Element.Textarea#value).
-}
textareaValue : String -> Attr { c | value : Supported } msg
textareaValue =
    Textarea_.value


{-| See [`Sl.Element.Textarea.defaultValue`](Sl.Element.Textarea#defaultValue).
-}
textareaDefaultValue : String -> Attr { c | value : Supported } msg
textareaDefaultValue =
    Textarea_.defaultValue


{-| See [`Sl.Element.Textarea.onBlur`](Sl.Element.Textarea#onBlur).
-}
textareaOnBlur : msg -> Attr { c | onBlur : Supported } msg
textareaOnBlur =
    Textarea_.onBlur


{-| See [`Sl.Element.Textarea.onChange`](Sl.Element.Textarea#onChange).
-}
textareaOnChange : msg -> Attr { c | onChange : Supported } msg
textareaOnChange =
    Textarea_.onChange


{-| See [`Sl.Element.Textarea.onFocus`](Sl.Element.Textarea#onFocus).
-}
textareaOnFocus : msg -> Attr { c | onFocus : Supported } msg
textareaOnFocus =
    Textarea_.onFocus


{-| See [`Sl.Element.Textarea.onInput`](Sl.Element.Textarea#onInput).
-}
textareaOnInput : msg -> Attr { c | onInput : Supported } msg
textareaOnInput =
    Textarea_.onInput


{-| See [`Sl.Element.Textarea.onInvalid`](Sl.Element.Textarea#onInvalid).
-}
textareaOnInvalid : msg -> Attr { c | onInvalid : Supported } msg
textareaOnInvalid =
    Textarea_.onInvalid
