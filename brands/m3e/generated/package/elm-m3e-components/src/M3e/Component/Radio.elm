module M3e.Component.Radio exposing (RadioIs, RadioAttrs, RadioBuilder, RadioAttrCaps, RadioSlotCaps, RadioChildAdmittedBy, radio, radioChecked, radioDisabled, radioName, radioRequired, radioValue, radioDefaultChecked, radioDefaultValue, radioOnBeforeinput, radioOnInput, radioOnChange, radioOnClick)

{-| The **Radio** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Radio`](M3e.Element.Radio) as `radio`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs RadioIs, RadioAttrs, RadioBuilder, RadioAttrCaps, RadioSlotCaps, RadioChildAdmittedBy, radio, radioChecked, radioDisabled, radioName, radioRequired, radioValue, radioDefaultChecked, radioDefaultValue, radioOnBeforeinput, radioOnInput, radioOnChange, radioOnClick

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.Radio as Radio_


{-| The `radio` element of this family — delegates to [`M3e.Element.Radio.component`](M3e.Element.Radio#component).
-}
radio :
    List (Attr RadioAttrs msg)
    -> List (Element childAccepts (RadioChildAdmittedBy childAdm) msg)
    -> Element (RadioIs s) admittedBy msg
radio =
    Radio_.component


{-| See [`M3e.Element.Radio.Is`](M3e.Element.Radio#Is).
-}
type alias RadioIs s =
    Radio_.Is s


{-| See [`M3e.Element.Radio.Attrs`](M3e.Element.Radio#Attrs).
-}
type alias RadioAttrs =
    Radio_.Attrs


{-| See [`M3e.Element.Radio.Builder`](M3e.Element.Radio#Builder).
-}
type alias RadioBuilder attrCaps slotCaps msg kind =
    Radio_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Radio.AttrCaps`](M3e.Element.Radio#AttrCaps).
-}
type alias RadioAttrCaps =
    Radio_.AttrCaps


{-| See [`M3e.Element.Radio.SlotCaps`](M3e.Element.Radio#SlotCaps).
-}
type alias RadioSlotCaps =
    Radio_.SlotCaps


{-| See [`M3e.Element.Radio.ChildAdmittedBy`](M3e.Element.Radio#ChildAdmittedBy).
-}
type alias RadioChildAdmittedBy childAdm =
    Radio_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Radio.checked`](M3e.Element.Radio#checked).
-}
radioChecked : Bool -> Attr { c | checked : Supported } msg
radioChecked =
    Radio_.checked


{-| See [`M3e.Element.Radio.disabled`](M3e.Element.Radio#disabled).
-}
radioDisabled : Bool -> Attr { c | disabled : Supported } msg
radioDisabled =
    Radio_.disabled


{-| See [`M3e.Element.Radio.name`](M3e.Element.Radio#name).
-}
radioName : String -> Attr { c | name : Supported } msg
radioName =
    Radio_.name


{-| See [`M3e.Element.Radio.required`](M3e.Element.Radio#required).
-}
radioRequired : Bool -> Attr { c | required : Supported } msg
radioRequired =
    Radio_.required


{-| See [`M3e.Element.Radio.value`](M3e.Element.Radio#value).
-}
radioValue : String -> Attr { c | value : Supported } msg
radioValue =
    Radio_.value


{-| See [`M3e.Element.Radio.defaultChecked`](M3e.Element.Radio#defaultChecked).
-}
radioDefaultChecked : Bool -> Attr { c | checked : Supported } msg
radioDefaultChecked =
    Radio_.defaultChecked


{-| See [`M3e.Element.Radio.defaultValue`](M3e.Element.Radio#defaultValue).
-}
radioDefaultValue : String -> Attr { c | value : Supported } msg
radioDefaultValue =
    Radio_.defaultValue


{-| See [`M3e.Element.Radio.onBeforeinput`](M3e.Element.Radio#onBeforeinput).
-}
radioOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
radioOnBeforeinput =
    Radio_.onBeforeinput


{-| See [`M3e.Element.Radio.onInput`](M3e.Element.Radio#onInput).
-}
radioOnInput : msg -> Attr { c | onInput : Supported } msg
radioOnInput =
    Radio_.onInput


{-| See [`M3e.Element.Radio.onChange`](M3e.Element.Radio#onChange).
-}
radioOnChange : msg -> Attr { c | onChange : Supported } msg
radioOnChange =
    Radio_.onChange


{-| See [`M3e.Element.Radio.onClick`](M3e.Element.Radio#onClick).
-}
radioOnClick : msg -> Attr { c | onClick : Supported } msg
radioOnClick =
    Radio_.onClick
