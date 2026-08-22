module M3e.Component.Checkbox exposing (CheckboxIs, CheckboxAttrs, CheckboxBuilder, CheckboxAttrCaps, CheckboxSlotCaps, CheckboxChildAdmittedBy, checkbox, checkboxChecked, checkboxDisabled, checkboxIndeterminate, checkboxName, checkboxRequired, checkboxValidationmessages, checkboxValue, checkboxDefaultChecked, checkboxDefaultValue, checkboxOnBeforeinput, checkboxOnInput, checkboxOnChange, checkboxOnInvalid, checkboxOnClick)

{-| The **Checkbox** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Checkbox`](M3e.Element.Checkbox) as `checkbox`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs CheckboxIs, CheckboxAttrs, CheckboxBuilder, CheckboxAttrCaps, CheckboxSlotCaps, CheckboxChildAdmittedBy, checkbox, checkboxChecked, checkboxDisabled, checkboxIndeterminate, checkboxName, checkboxRequired, checkboxValidationmessages, checkboxValue, checkboxDefaultChecked, checkboxDefaultValue, checkboxOnBeforeinput, checkboxOnInput, checkboxOnChange, checkboxOnInvalid, checkboxOnClick

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.Checkbox as Checkbox_


{-| The `checkbox` element of this family — delegates to [`M3e.Element.Checkbox.component`](M3e.Element.Checkbox#component).
-}
checkbox :
    List (Attr CheckboxAttrs msg)
    -> List (Element childAccepts (CheckboxChildAdmittedBy childAdm) msg)
    -> Element (CheckboxIs s) admittedBy msg
checkbox =
    Checkbox_.component


{-| See [`M3e.Element.Checkbox.Is`](M3e.Element.Checkbox#Is).
-}
type alias CheckboxIs s =
    Checkbox_.Is s


{-| See [`M3e.Element.Checkbox.Attrs`](M3e.Element.Checkbox#Attrs).
-}
type alias CheckboxAttrs =
    Checkbox_.Attrs


{-| See [`M3e.Element.Checkbox.Builder`](M3e.Element.Checkbox#Builder).
-}
type alias CheckboxBuilder attrCaps slotCaps msg kind =
    Checkbox_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Checkbox.AttrCaps`](M3e.Element.Checkbox#AttrCaps).
-}
type alias CheckboxAttrCaps =
    Checkbox_.AttrCaps


{-| See [`M3e.Element.Checkbox.SlotCaps`](M3e.Element.Checkbox#SlotCaps).
-}
type alias CheckboxSlotCaps =
    Checkbox_.SlotCaps


{-| See [`M3e.Element.Checkbox.ChildAdmittedBy`](M3e.Element.Checkbox#ChildAdmittedBy).
-}
type alias CheckboxChildAdmittedBy childAdm =
    Checkbox_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Checkbox.checked`](M3e.Element.Checkbox#checked).
-}
checkboxChecked : Bool -> Attr { c | checked : Supported } msg
checkboxChecked =
    Checkbox_.checked


{-| See [`M3e.Element.Checkbox.disabled`](M3e.Element.Checkbox#disabled).
-}
checkboxDisabled : Bool -> Attr { c | disabled : Supported } msg
checkboxDisabled =
    Checkbox_.disabled


{-| See [`M3e.Element.Checkbox.indeterminate`](M3e.Element.Checkbox#indeterminate).
-}
checkboxIndeterminate : Bool -> Attr { c | indeterminate : Supported } msg
checkboxIndeterminate =
    Checkbox_.indeterminate


{-| See [`M3e.Element.Checkbox.name`](M3e.Element.Checkbox#name).
-}
checkboxName : String -> Attr { c | name : Supported } msg
checkboxName =
    Checkbox_.name


{-| See [`M3e.Element.Checkbox.required`](M3e.Element.Checkbox#required).
-}
checkboxRequired : Bool -> Attr { c | required : Supported } msg
checkboxRequired =
    Checkbox_.required


{-| See [`M3e.Element.Checkbox.validationmessages`](M3e.Element.Checkbox#validationmessages).
-}
checkboxValidationmessages : String -> Attr { c | validationmessages : Supported } msg
checkboxValidationmessages =
    Checkbox_.validationmessages


{-| See [`M3e.Element.Checkbox.value`](M3e.Element.Checkbox#value).
-}
checkboxValue : String -> Attr { c | value : Supported } msg
checkboxValue =
    Checkbox_.value


{-| See [`M3e.Element.Checkbox.defaultChecked`](M3e.Element.Checkbox#defaultChecked).
-}
checkboxDefaultChecked : Bool -> Attr { c | checked : Supported } msg
checkboxDefaultChecked =
    Checkbox_.defaultChecked


{-| See [`M3e.Element.Checkbox.defaultValue`](M3e.Element.Checkbox#defaultValue).
-}
checkboxDefaultValue : String -> Attr { c | value : Supported } msg
checkboxDefaultValue =
    Checkbox_.defaultValue


{-| See [`M3e.Element.Checkbox.onBeforeinput`](M3e.Element.Checkbox#onBeforeinput).
-}
checkboxOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
checkboxOnBeforeinput =
    Checkbox_.onBeforeinput


{-| See [`M3e.Element.Checkbox.onInput`](M3e.Element.Checkbox#onInput).
-}
checkboxOnInput : msg -> Attr { c | onInput : Supported } msg
checkboxOnInput =
    Checkbox_.onInput


{-| See [`M3e.Element.Checkbox.onChange`](M3e.Element.Checkbox#onChange).
-}
checkboxOnChange : msg -> Attr { c | onChange : Supported } msg
checkboxOnChange =
    Checkbox_.onChange


{-| See [`M3e.Element.Checkbox.onInvalid`](M3e.Element.Checkbox#onInvalid).
-}
checkboxOnInvalid : msg -> Attr { c | onInvalid : Supported } msg
checkboxOnInvalid =
    Checkbox_.onInvalid


{-| See [`M3e.Element.Checkbox.onClick`](M3e.Element.Checkbox#onClick).
-}
checkboxOnClick : msg -> Attr { c | onClick : Supported } msg
checkboxOnClick =
    Checkbox_.onClick
