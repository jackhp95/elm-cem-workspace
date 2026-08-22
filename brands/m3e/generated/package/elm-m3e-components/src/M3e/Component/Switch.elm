module M3e.Component.Switch exposing (SwitchIs, SwitchAttrs, SwitchBuilder, SwitchAttrCaps, SwitchSlotCaps, SwitchChildAdmittedBy, SwitchIcons, switch, switchIcons, switchChecked, switchDisabled, switchName, switchValidationmessages, switchValue, switchDefaultChecked, switchDefaultValue, switchOnBeforeinput, switchOnInput, switchOnChange, switchOnClick)

{-| The **Switch** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Switch`](M3e.Element.Switch) as `switch`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SwitchIs, SwitchAttrs, SwitchBuilder, SwitchAttrCaps, SwitchSlotCaps, SwitchChildAdmittedBy, SwitchIcons, switch, switchIcons, switchChecked, switchDisabled, switchName, switchValidationmessages, switchValue, switchDefaultChecked, switchDefaultValue, switchOnBeforeinput, switchOnInput, switchOnChange, switchOnClick

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Switch as Switch_


{-| The `switch` element of this family — delegates to [`M3e.Element.Switch.component`](M3e.Element.Switch#component).
-}
switch :
    List (Attr SwitchAttrs msg)
    -> List (Element childAccepts (SwitchChildAdmittedBy childAdm) msg)
    -> Element (SwitchIs s) admittedBy msg
switch =
    Switch_.component


{-| See [`M3e.Element.Switch.Is`](M3e.Element.Switch#Is).
-}
type alias SwitchIs s =
    Switch_.Is s


{-| See [`M3e.Element.Switch.Attrs`](M3e.Element.Switch#Attrs).
-}
type alias SwitchAttrs =
    Switch_.Attrs


{-| See [`M3e.Element.Switch.Builder`](M3e.Element.Switch#Builder).
-}
type alias SwitchBuilder attrCaps slotCaps msg kind =
    Switch_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Switch.AttrCaps`](M3e.Element.Switch#AttrCaps).
-}
type alias SwitchAttrCaps =
    Switch_.AttrCaps


{-| See [`M3e.Element.Switch.SlotCaps`](M3e.Element.Switch#SlotCaps).
-}
type alias SwitchSlotCaps =
    Switch_.SlotCaps


{-| See [`M3e.Element.Switch.ChildAdmittedBy`](M3e.Element.Switch#ChildAdmittedBy).
-}
type alias SwitchChildAdmittedBy childAdm =
    Switch_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Switch.Icons`](M3e.Element.Switch#Icons).
-}
type alias SwitchIcons =
    Switch_.Icons


{-| See [`M3e.Element.Switch.icons`](M3e.Element.Switch#icons).
-}
switchIcons : Value SwitchIcons -> Attr { c | icons : Supported } msg
switchIcons =
    Switch_.icons


{-| See [`M3e.Element.Switch.checked`](M3e.Element.Switch#checked).
-}
switchChecked : Bool -> Attr { c | checked : Supported } msg
switchChecked =
    Switch_.checked


{-| See [`M3e.Element.Switch.disabled`](M3e.Element.Switch#disabled).
-}
switchDisabled : Bool -> Attr { c | disabled : Supported } msg
switchDisabled =
    Switch_.disabled


{-| See [`M3e.Element.Switch.name`](M3e.Element.Switch#name).
-}
switchName : String -> Attr { c | name : Supported } msg
switchName =
    Switch_.name


{-| See [`M3e.Element.Switch.validationmessages`](M3e.Element.Switch#validationmessages).
-}
switchValidationmessages : String -> Attr { c | validationmessages : Supported } msg
switchValidationmessages =
    Switch_.validationmessages


{-| See [`M3e.Element.Switch.value`](M3e.Element.Switch#value).
-}
switchValue : String -> Attr { c | value : Supported } msg
switchValue =
    Switch_.value


{-| See [`M3e.Element.Switch.defaultChecked`](M3e.Element.Switch#defaultChecked).
-}
switchDefaultChecked : Bool -> Attr { c | checked : Supported } msg
switchDefaultChecked =
    Switch_.defaultChecked


{-| See [`M3e.Element.Switch.defaultValue`](M3e.Element.Switch#defaultValue).
-}
switchDefaultValue : String -> Attr { c | value : Supported } msg
switchDefaultValue =
    Switch_.defaultValue


{-| See [`M3e.Element.Switch.onBeforeinput`](M3e.Element.Switch#onBeforeinput).
-}
switchOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
switchOnBeforeinput =
    Switch_.onBeforeinput


{-| See [`M3e.Element.Switch.onInput`](M3e.Element.Switch#onInput).
-}
switchOnInput : msg -> Attr { c | onInput : Supported } msg
switchOnInput =
    Switch_.onInput


{-| See [`M3e.Element.Switch.onChange`](M3e.Element.Switch#onChange).
-}
switchOnChange : msg -> Attr { c | onChange : Supported } msg
switchOnChange =
    Switch_.onChange


{-| See [`M3e.Element.Switch.onClick`](M3e.Element.Switch#onClick).
-}
switchOnClick : msg -> Attr { c | onClick : Supported } msg
switchOnClick =
    Switch_.onClick
