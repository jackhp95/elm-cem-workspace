module Sl.Component.Switch exposing (SwitchIs, SwitchAttrs, SwitchBuilder, SwitchAttrCaps, SwitchSlotCaps, SwitchContent, SwitchChildAdmittedBy, SwitchSize, switch, switchSize, switchChecked, switchDisabled, switchForm, switchHelpText, switchName, switchRequired, switchTitle, switchValue, switchDefaultChecked, switchDefaultValue, switchOnBlur, switchOnChange, switchOnInput, switchOnFocus, switchOnInvalid, switchChild)

{-| The **Switch** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Switch`](Sl.Element.Switch) as `switch`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs SwitchIs, SwitchAttrs, SwitchBuilder, SwitchAttrCaps, SwitchSlotCaps, SwitchContent, SwitchChildAdmittedBy, SwitchSize, switch, switchSize, switchChecked, switchDisabled, switchForm, switchHelpText, switchName, switchRequired, switchTitle, switchValue, switchDefaultChecked, switchDefaultValue, switchOnBlur, switchOnChange, switchOnInput, switchOnFocus, switchOnInvalid, switchChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Switch as Switch_


{-| The `switch` element of this family — delegates to [`Sl.Element.Switch.component`](Sl.Element.Switch#component).
-}
switch :
    List (Attr SwitchAttrs msg)
    -> List (Element SwitchContent (SwitchChildAdmittedBy childAdm) msg)
    -> Element (SwitchIs s) admittedBy msg
switch =
    Switch_.component


{-| See [`Sl.Element.Switch.Is`](Sl.Element.Switch#Is).
-}
type alias SwitchIs s =
    Switch_.Is s


{-| See [`Sl.Element.Switch.Attrs`](Sl.Element.Switch#Attrs).
-}
type alias SwitchAttrs =
    Switch_.Attrs


{-| See [`Sl.Element.Switch.Builder`](Sl.Element.Switch#Builder).
-}
type alias SwitchBuilder attrCaps slotCaps msg kind =
    Switch_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Switch.AttrCaps`](Sl.Element.Switch#AttrCaps).
-}
type alias SwitchAttrCaps =
    Switch_.AttrCaps


{-| See [`Sl.Element.Switch.SlotCaps`](Sl.Element.Switch#SlotCaps).
-}
type alias SwitchSlotCaps =
    Switch_.SlotCaps


{-| See [`Sl.Element.Switch.Content`](Sl.Element.Switch#Content).
-}
type alias SwitchContent =
    Switch_.Content


{-| See [`Sl.Element.Switch.ChildAdmittedBy`](Sl.Element.Switch#ChildAdmittedBy).
-}
type alias SwitchChildAdmittedBy childAdm =
    Switch_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Switch.Size`](Sl.Element.Switch#Size).
-}
type alias SwitchSize =
    Switch_.Size


{-| See [`Sl.Element.Switch.size`](Sl.Element.Switch#size).
-}
switchSize : Value SwitchSize -> Attr { c | size : Supported } msg
switchSize =
    Switch_.size


{-| See [`Sl.Element.Switch.checked`](Sl.Element.Switch#checked).
-}
switchChecked : Bool -> Attr { c | checked : Supported } msg
switchChecked =
    Switch_.checked


{-| See [`Sl.Element.Switch.disabled`](Sl.Element.Switch#disabled).
-}
switchDisabled : Bool -> Attr { c | disabled : Supported } msg
switchDisabled =
    Switch_.disabled


{-| See [`Sl.Element.Switch.form`](Sl.Element.Switch#form).
-}
switchForm : String -> Attr { c | form : Supported } msg
switchForm =
    Switch_.form


{-| See [`Sl.Element.Switch.helpText`](Sl.Element.Switch#helpText).
-}
switchHelpText : String -> Attr { c | helpText : Supported } msg
switchHelpText =
    Switch_.helpText


{-| See [`Sl.Element.Switch.name`](Sl.Element.Switch#name).
-}
switchName : String -> Attr { c | name : Supported } msg
switchName =
    Switch_.name


{-| See [`Sl.Element.Switch.required`](Sl.Element.Switch#required).
-}
switchRequired : Bool -> Attr { c | required : Supported } msg
switchRequired =
    Switch_.required


{-| See [`Sl.Element.Switch.title`](Sl.Element.Switch#title).
-}
switchTitle : String -> Attr { c | title : Supported } msg
switchTitle =
    Switch_.title


{-| See [`Sl.Element.Switch.value`](Sl.Element.Switch#value).
-}
switchValue : String -> Attr { c | value : Supported } msg
switchValue =
    Switch_.value


{-| See [`Sl.Element.Switch.defaultChecked`](Sl.Element.Switch#defaultChecked).
-}
switchDefaultChecked : Bool -> Attr { c | checked : Supported } msg
switchDefaultChecked =
    Switch_.defaultChecked


{-| See [`Sl.Element.Switch.defaultValue`](Sl.Element.Switch#defaultValue).
-}
switchDefaultValue : String -> Attr { c | value : Supported } msg
switchDefaultValue =
    Switch_.defaultValue


{-| See [`Sl.Element.Switch.onBlur`](Sl.Element.Switch#onBlur).
-}
switchOnBlur : msg -> Attr { c | onBlur : Supported } msg
switchOnBlur =
    Switch_.onBlur


{-| See [`Sl.Element.Switch.onChange`](Sl.Element.Switch#onChange).
-}
switchOnChange : msg -> Attr { c | onChange : Supported } msg
switchOnChange =
    Switch_.onChange


{-| See [`Sl.Element.Switch.onInput`](Sl.Element.Switch#onInput).
-}
switchOnInput : msg -> Attr { c | onInput : Supported } msg
switchOnInput =
    Switch_.onInput


{-| See [`Sl.Element.Switch.onFocus`](Sl.Element.Switch#onFocus).
-}
switchOnFocus : msg -> Attr { c | onFocus : Supported } msg
switchOnFocus =
    Switch_.onFocus


{-| See [`Sl.Element.Switch.onInvalid`](Sl.Element.Switch#onInvalid).
-}
switchOnInvalid : msg -> Attr { c | onInvalid : Supported } msg
switchOnInvalid =
    Switch_.onInvalid


{-| See [`Sl.Element.Switch.child`](Sl.Element.Switch#child).
-}
switchChild : Element SwitchContent admittedBy msg -> Element free freeAdmittedBy msg
switchChild =
    Switch_.child
