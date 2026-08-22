module M3e.Component.RadioGroup exposing (RadioGroupIs, RadioGroupAttrs, RadioGroupBuilder, RadioGroupAttrCaps, RadioGroupSlotCaps, RadioGroupChildAdmittedBy, radioGroup, radioGroupAriaInvalid, radioGroupDisabled, radioGroupName, radioGroupRequired, radioGroupValidationmessages, radioGroupOnBeforeinput, radioGroupOnInput, radioGroupOnChange, radioGroupChild)

{-| The **RadioGroup** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.RadioGroup`](M3e.Element.RadioGroup) as `radioGroup`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs RadioGroupIs, RadioGroupAttrs, RadioGroupBuilder, RadioGroupAttrCaps, RadioGroupSlotCaps, RadioGroupChildAdmittedBy, radioGroup, radioGroupAriaInvalid, radioGroupDisabled, radioGroupName, radioGroupRequired, radioGroupValidationmessages, radioGroupOnBeforeinput, radioGroupOnInput, radioGroupOnChange, radioGroupChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.RadioGroup as RadioGroup_


{-| The `radioGroup` element of this family — delegates to [`M3e.Element.RadioGroup.component`](M3e.Element.RadioGroup#component).
-}
radioGroup :
    { content : Element childAccepts (RadioGroupChildAdmittedBy childAdm) msg }
    -> List (Attr RadioGroupAttrs msg)
    -> List (Element childAccepts (RadioGroupChildAdmittedBy childAdm) msg)
    -> Element (RadioGroupIs s) admittedBy msg
radioGroup =
    RadioGroup_.component


{-| See [`M3e.Element.RadioGroup.Is`](M3e.Element.RadioGroup#Is).
-}
type alias RadioGroupIs s =
    RadioGroup_.Is s


{-| See [`M3e.Element.RadioGroup.Attrs`](M3e.Element.RadioGroup#Attrs).
-}
type alias RadioGroupAttrs =
    RadioGroup_.Attrs


{-| See [`M3e.Element.RadioGroup.Builder`](M3e.Element.RadioGroup#Builder).
-}
type alias RadioGroupBuilder attrCaps slotCaps msg kind =
    RadioGroup_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.RadioGroup.AttrCaps`](M3e.Element.RadioGroup#AttrCaps).
-}
type alias RadioGroupAttrCaps =
    RadioGroup_.AttrCaps


{-| See [`M3e.Element.RadioGroup.SlotCaps`](M3e.Element.RadioGroup#SlotCaps).
-}
type alias RadioGroupSlotCaps =
    RadioGroup_.SlotCaps


{-| See [`M3e.Element.RadioGroup.ChildAdmittedBy`](M3e.Element.RadioGroup#ChildAdmittedBy).
-}
type alias RadioGroupChildAdmittedBy childAdm =
    RadioGroup_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.RadioGroup.ariaInvalid`](M3e.Element.RadioGroup#ariaInvalid).
-}
radioGroupAriaInvalid : String -> Attr { c | ariaInvalid : Supported } msg
radioGroupAriaInvalid =
    RadioGroup_.ariaInvalid


{-| See [`M3e.Element.RadioGroup.disabled`](M3e.Element.RadioGroup#disabled).
-}
radioGroupDisabled : Bool -> Attr { c | disabled : Supported } msg
radioGroupDisabled =
    RadioGroup_.disabled


{-| See [`M3e.Element.RadioGroup.name`](M3e.Element.RadioGroup#name).
-}
radioGroupName : String -> Attr { c | name : Supported } msg
radioGroupName =
    RadioGroup_.name


{-| See [`M3e.Element.RadioGroup.required`](M3e.Element.RadioGroup#required).
-}
radioGroupRequired : Bool -> Attr { c | required : Supported } msg
radioGroupRequired =
    RadioGroup_.required


{-| See [`M3e.Element.RadioGroup.validationmessages`](M3e.Element.RadioGroup#validationmessages).
-}
radioGroupValidationmessages : String -> Attr { c | validationmessages : Supported } msg
radioGroupValidationmessages =
    RadioGroup_.validationmessages


{-| See [`M3e.Element.RadioGroup.onBeforeinput`](M3e.Element.RadioGroup#onBeforeinput).
-}
radioGroupOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
radioGroupOnBeforeinput =
    RadioGroup_.onBeforeinput


{-| See [`M3e.Element.RadioGroup.onInput`](M3e.Element.RadioGroup#onInput).
-}
radioGroupOnInput : msg -> Attr { c | onInput : Supported } msg
radioGroupOnInput =
    RadioGroup_.onInput


{-| See [`M3e.Element.RadioGroup.onChange`](M3e.Element.RadioGroup#onChange).
-}
radioGroupOnChange : msg -> Attr { c | onChange : Supported } msg
radioGroupOnChange =
    RadioGroup_.onChange


{-| See [`M3e.Element.RadioGroup.child`](M3e.Element.RadioGroup#child).
-}
radioGroupChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
radioGroupChild =
    RadioGroup_.child
