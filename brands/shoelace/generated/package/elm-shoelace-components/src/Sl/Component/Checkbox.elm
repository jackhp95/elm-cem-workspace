module Sl.Component.Checkbox exposing (CheckboxIs, CheckboxAttrs, CheckboxBuilder, CheckboxAttrCaps, CheckboxSlotCaps, CheckboxContent, CheckboxChildAdmittedBy, CheckboxSize, checkbox, checkboxSize, checkboxChecked, checkboxDisabled, checkboxForm, checkboxHelpText, checkboxIndeterminate, checkboxName, checkboxRequired, checkboxTitle, checkboxValue, checkboxDefaultChecked, checkboxDefaultValue, checkboxOnBlur, checkboxOnChange, checkboxOnFocus, checkboxOnInput, checkboxOnInvalid, checkboxChild)

{-| The **Checkbox** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Checkbox`](Sl.Element.Checkbox) as `checkbox`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs CheckboxIs, CheckboxAttrs, CheckboxBuilder, CheckboxAttrCaps, CheckboxSlotCaps, CheckboxContent, CheckboxChildAdmittedBy, CheckboxSize, checkbox, checkboxSize, checkboxChecked, checkboxDisabled, checkboxForm, checkboxHelpText, checkboxIndeterminate, checkboxName, checkboxRequired, checkboxTitle, checkboxValue, checkboxDefaultChecked, checkboxDefaultValue, checkboxOnBlur, checkboxOnChange, checkboxOnFocus, checkboxOnInput, checkboxOnInvalid, checkboxChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Checkbox as Checkbox_


{-| The `checkbox` element of this family — delegates to [`Sl.Element.Checkbox.component`](Sl.Element.Checkbox#component).
-}
checkbox :
    List (Attr CheckboxAttrs msg)
    -> List (Element CheckboxContent (CheckboxChildAdmittedBy childAdm) msg)
    -> Element (CheckboxIs s) admittedBy msg
checkbox =
    Checkbox_.component


{-| See [`Sl.Element.Checkbox.Is`](Sl.Element.Checkbox#Is).
-}
type alias CheckboxIs s =
    Checkbox_.Is s


{-| See [`Sl.Element.Checkbox.Attrs`](Sl.Element.Checkbox#Attrs).
-}
type alias CheckboxAttrs =
    Checkbox_.Attrs


{-| See [`Sl.Element.Checkbox.Builder`](Sl.Element.Checkbox#Builder).
-}
type alias CheckboxBuilder attrCaps slotCaps msg kind =
    Checkbox_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Checkbox.AttrCaps`](Sl.Element.Checkbox#AttrCaps).
-}
type alias CheckboxAttrCaps =
    Checkbox_.AttrCaps


{-| See [`Sl.Element.Checkbox.SlotCaps`](Sl.Element.Checkbox#SlotCaps).
-}
type alias CheckboxSlotCaps =
    Checkbox_.SlotCaps


{-| See [`Sl.Element.Checkbox.Content`](Sl.Element.Checkbox#Content).
-}
type alias CheckboxContent =
    Checkbox_.Content


{-| See [`Sl.Element.Checkbox.ChildAdmittedBy`](Sl.Element.Checkbox#ChildAdmittedBy).
-}
type alias CheckboxChildAdmittedBy childAdm =
    Checkbox_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Checkbox.Size`](Sl.Element.Checkbox#Size).
-}
type alias CheckboxSize =
    Checkbox_.Size


{-| See [`Sl.Element.Checkbox.size`](Sl.Element.Checkbox#size).
-}
checkboxSize : Value CheckboxSize -> Attr { c | size : Supported } msg
checkboxSize =
    Checkbox_.size


{-| See [`Sl.Element.Checkbox.checked`](Sl.Element.Checkbox#checked).
-}
checkboxChecked : Bool -> Attr { c | checked : Supported } msg
checkboxChecked =
    Checkbox_.checked


{-| See [`Sl.Element.Checkbox.disabled`](Sl.Element.Checkbox#disabled).
-}
checkboxDisabled : Bool -> Attr { c | disabled : Supported } msg
checkboxDisabled =
    Checkbox_.disabled


{-| See [`Sl.Element.Checkbox.form`](Sl.Element.Checkbox#form).
-}
checkboxForm : String -> Attr { c | form : Supported } msg
checkboxForm =
    Checkbox_.form


{-| See [`Sl.Element.Checkbox.helpText`](Sl.Element.Checkbox#helpText).
-}
checkboxHelpText : String -> Attr { c | helpText : Supported } msg
checkboxHelpText =
    Checkbox_.helpText


{-| See [`Sl.Element.Checkbox.indeterminate`](Sl.Element.Checkbox#indeterminate).
-}
checkboxIndeterminate : Bool -> Attr { c | indeterminate : Supported } msg
checkboxIndeterminate =
    Checkbox_.indeterminate


{-| See [`Sl.Element.Checkbox.name`](Sl.Element.Checkbox#name).
-}
checkboxName : String -> Attr { c | name : Supported } msg
checkboxName =
    Checkbox_.name


{-| See [`Sl.Element.Checkbox.required`](Sl.Element.Checkbox#required).
-}
checkboxRequired : Bool -> Attr { c | required : Supported } msg
checkboxRequired =
    Checkbox_.required


{-| See [`Sl.Element.Checkbox.title`](Sl.Element.Checkbox#title).
-}
checkboxTitle : String -> Attr { c | title : Supported } msg
checkboxTitle =
    Checkbox_.title


{-| See [`Sl.Element.Checkbox.value`](Sl.Element.Checkbox#value).
-}
checkboxValue : String -> Attr { c | value : Supported } msg
checkboxValue =
    Checkbox_.value


{-| See [`Sl.Element.Checkbox.defaultChecked`](Sl.Element.Checkbox#defaultChecked).
-}
checkboxDefaultChecked : Bool -> Attr { c | checked : Supported } msg
checkboxDefaultChecked =
    Checkbox_.defaultChecked


{-| See [`Sl.Element.Checkbox.defaultValue`](Sl.Element.Checkbox#defaultValue).
-}
checkboxDefaultValue : String -> Attr { c | value : Supported } msg
checkboxDefaultValue =
    Checkbox_.defaultValue


{-| See [`Sl.Element.Checkbox.onBlur`](Sl.Element.Checkbox#onBlur).
-}
checkboxOnBlur : msg -> Attr { c | onBlur : Supported } msg
checkboxOnBlur =
    Checkbox_.onBlur


{-| See [`Sl.Element.Checkbox.onChange`](Sl.Element.Checkbox#onChange).
-}
checkboxOnChange : msg -> Attr { c | onChange : Supported } msg
checkboxOnChange =
    Checkbox_.onChange


{-| See [`Sl.Element.Checkbox.onFocus`](Sl.Element.Checkbox#onFocus).
-}
checkboxOnFocus : msg -> Attr { c | onFocus : Supported } msg
checkboxOnFocus =
    Checkbox_.onFocus


{-| See [`Sl.Element.Checkbox.onInput`](Sl.Element.Checkbox#onInput).
-}
checkboxOnInput : msg -> Attr { c | onInput : Supported } msg
checkboxOnInput =
    Checkbox_.onInput


{-| See [`Sl.Element.Checkbox.onInvalid`](Sl.Element.Checkbox#onInvalid).
-}
checkboxOnInvalid : msg -> Attr { c | onInvalid : Supported } msg
checkboxOnInvalid =
    Checkbox_.onInvalid


{-| See [`Sl.Element.Checkbox.child`](Sl.Element.Checkbox#child).
-}
checkboxChild : Element CheckboxContent admittedBy msg -> Element free freeAdmittedBy msg
checkboxChild =
    Checkbox_.child
