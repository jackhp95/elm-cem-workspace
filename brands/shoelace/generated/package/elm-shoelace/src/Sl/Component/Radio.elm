module Sl.Component.Radio exposing (RadioIs, RadioAttrs, RadioBuilder, RadioAttrCaps, RadioSlotCaps, RadioChildAdmittedBy, RadioSize, radio, radioSize, radioDisabled, radioValue, radioDefaultValue, radioOnBlur, radioOnFocus)

{-| The **Radio** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Radio`](Sl.Element.Radio) as `radio`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs RadioIs, RadioAttrs, RadioBuilder, RadioAttrCaps, RadioSlotCaps, RadioChildAdmittedBy, RadioSize, radio, radioSize, radioDisabled, radioValue, radioDefaultValue, radioOnBlur, radioOnFocus

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Radio as Radio_


{-| The `radio` element of this family — delegates to [`Sl.Element.Radio.component`](Sl.Element.Radio#component).
-}
radio :
    List (Attr RadioAttrs msg)
    -> List (Element childAccepts (RadioChildAdmittedBy childAdm) msg)
    -> Element (RadioIs s) admittedBy msg
radio =
    Radio_.component


{-| See [`Sl.Element.Radio.Is`](Sl.Element.Radio#Is).
-}
type alias RadioIs s =
    Radio_.Is s


{-| See [`Sl.Element.Radio.Attrs`](Sl.Element.Radio#Attrs).
-}
type alias RadioAttrs =
    Radio_.Attrs


{-| See [`Sl.Element.Radio.Builder`](Sl.Element.Radio#Builder).
-}
type alias RadioBuilder attrCaps slotCaps msg kind =
    Radio_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Radio.AttrCaps`](Sl.Element.Radio#AttrCaps).
-}
type alias RadioAttrCaps =
    Radio_.AttrCaps


{-| See [`Sl.Element.Radio.SlotCaps`](Sl.Element.Radio#SlotCaps).
-}
type alias RadioSlotCaps =
    Radio_.SlotCaps


{-| See [`Sl.Element.Radio.ChildAdmittedBy`](Sl.Element.Radio#ChildAdmittedBy).
-}
type alias RadioChildAdmittedBy childAdm =
    Radio_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Radio.Size`](Sl.Element.Radio#Size).
-}
type alias RadioSize =
    Radio_.Size


{-| See [`Sl.Element.Radio.size`](Sl.Element.Radio#size).
-}
radioSize : Value RadioSize -> Attr { c | size : Supported } msg
radioSize =
    Radio_.size


{-| See [`Sl.Element.Radio.disabled`](Sl.Element.Radio#disabled).
-}
radioDisabled : Bool -> Attr { c | disabled : Supported } msg
radioDisabled =
    Radio_.disabled


{-| See [`Sl.Element.Radio.value`](Sl.Element.Radio#value).
-}
radioValue : String -> Attr { c | value : Supported } msg
radioValue =
    Radio_.value


{-| See [`Sl.Element.Radio.defaultValue`](Sl.Element.Radio#defaultValue).
-}
radioDefaultValue : String -> Attr { c | value : Supported } msg
radioDefaultValue =
    Radio_.defaultValue


{-| See [`Sl.Element.Radio.onBlur`](Sl.Element.Radio#onBlur).
-}
radioOnBlur : msg -> Attr { c | onBlur : Supported } msg
radioOnBlur =
    Radio_.onBlur


{-| See [`Sl.Element.Radio.onFocus`](Sl.Element.Radio#onFocus).
-}
radioOnFocus : msg -> Attr { c | onFocus : Supported } msg
radioOnFocus =
    Radio_.onFocus
