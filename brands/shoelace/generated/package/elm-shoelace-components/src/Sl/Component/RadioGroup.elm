module Sl.Component.RadioGroup exposing (RadioGroupIs, RadioGroupAttrs, RadioGroupBuilder, RadioGroupAttrCaps, RadioGroupSlotCaps, RadioGroupChildAdmittedBy, RadioGroupSize, radioGroup, radioGroupSize, radioGroupForm, radioGroupHelpText, radioGroupLabel, radioGroupName, radioGroupRequired, radioGroupValue, radioGroupDefaultValue, radioGroupOnChange, radioGroupOnInput, radioGroupOnInvalid)

{-| The **RadioGroup** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.RadioGroup`](Sl.Element.RadioGroup) as `radioGroup`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs RadioGroupIs, RadioGroupAttrs, RadioGroupBuilder, RadioGroupAttrCaps, RadioGroupSlotCaps, RadioGroupChildAdmittedBy, RadioGroupSize, radioGroup, radioGroupSize, radioGroupForm, radioGroupHelpText, radioGroupLabel, radioGroupName, radioGroupRequired, radioGroupValue, radioGroupDefaultValue, radioGroupOnChange, radioGroupOnInput, radioGroupOnInvalid

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.RadioGroup as RadioGroup_


{-| The `radioGroup` element of this family — delegates to [`Sl.Element.RadioGroup.component`](Sl.Element.RadioGroup#component).
-}
radioGroup :
    List (Attr RadioGroupAttrs msg)
    -> List (Element childAccepts (RadioGroupChildAdmittedBy childAdm) msg)
    -> Element (RadioGroupIs s) admittedBy msg
radioGroup =
    RadioGroup_.component


{-| See [`Sl.Element.RadioGroup.Is`](Sl.Element.RadioGroup#Is).
-}
type alias RadioGroupIs s =
    RadioGroup_.Is s


{-| See [`Sl.Element.RadioGroup.Attrs`](Sl.Element.RadioGroup#Attrs).
-}
type alias RadioGroupAttrs =
    RadioGroup_.Attrs


{-| See [`Sl.Element.RadioGroup.Builder`](Sl.Element.RadioGroup#Builder).
-}
type alias RadioGroupBuilder attrCaps slotCaps msg kind =
    RadioGroup_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.RadioGroup.AttrCaps`](Sl.Element.RadioGroup#AttrCaps).
-}
type alias RadioGroupAttrCaps =
    RadioGroup_.AttrCaps


{-| See [`Sl.Element.RadioGroup.SlotCaps`](Sl.Element.RadioGroup#SlotCaps).
-}
type alias RadioGroupSlotCaps =
    RadioGroup_.SlotCaps


{-| See [`Sl.Element.RadioGroup.ChildAdmittedBy`](Sl.Element.RadioGroup#ChildAdmittedBy).
-}
type alias RadioGroupChildAdmittedBy childAdm =
    RadioGroup_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.RadioGroup.Size`](Sl.Element.RadioGroup#Size).
-}
type alias RadioGroupSize =
    RadioGroup_.Size


{-| See [`Sl.Element.RadioGroup.size`](Sl.Element.RadioGroup#size).
-}
radioGroupSize : Value RadioGroupSize -> Attr { c | size : Supported } msg
radioGroupSize =
    RadioGroup_.size


{-| See [`Sl.Element.RadioGroup.form`](Sl.Element.RadioGroup#form).
-}
radioGroupForm : String -> Attr { c | form : Supported } msg
radioGroupForm =
    RadioGroup_.form


{-| See [`Sl.Element.RadioGroup.helpText`](Sl.Element.RadioGroup#helpText).
-}
radioGroupHelpText : String -> Attr { c | helpText : Supported } msg
radioGroupHelpText =
    RadioGroup_.helpText


{-| See [`Sl.Element.RadioGroup.label`](Sl.Element.RadioGroup#label).
-}
radioGroupLabel : String -> Attr { c | label : Supported } msg
radioGroupLabel =
    RadioGroup_.label


{-| See [`Sl.Element.RadioGroup.name`](Sl.Element.RadioGroup#name).
-}
radioGroupName : String -> Attr { c | name : Supported } msg
radioGroupName =
    RadioGroup_.name


{-| See [`Sl.Element.RadioGroup.required`](Sl.Element.RadioGroup#required).
-}
radioGroupRequired : Bool -> Attr { c | required : Supported } msg
radioGroupRequired =
    RadioGroup_.required


{-| See [`Sl.Element.RadioGroup.value`](Sl.Element.RadioGroup#value).
-}
radioGroupValue : String -> Attr { c | value : Supported } msg
radioGroupValue =
    RadioGroup_.value


{-| See [`Sl.Element.RadioGroup.defaultValue`](Sl.Element.RadioGroup#defaultValue).
-}
radioGroupDefaultValue : String -> Attr { c | value : Supported } msg
radioGroupDefaultValue =
    RadioGroup_.defaultValue


{-| See [`Sl.Element.RadioGroup.onChange`](Sl.Element.RadioGroup#onChange).
-}
radioGroupOnChange : msg -> Attr { c | onChange : Supported } msg
radioGroupOnChange =
    RadioGroup_.onChange


{-| See [`Sl.Element.RadioGroup.onInput`](Sl.Element.RadioGroup#onInput).
-}
radioGroupOnInput : msg -> Attr { c | onInput : Supported } msg
radioGroupOnInput =
    RadioGroup_.onInput


{-| See [`Sl.Element.RadioGroup.onInvalid`](Sl.Element.RadioGroup#onInvalid).
-}
radioGroupOnInvalid : msg -> Attr { c | onInvalid : Supported } msg
radioGroupOnInvalid =
    RadioGroup_.onInvalid
