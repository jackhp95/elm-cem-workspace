module Sl.Component.RadioButton exposing (RadioButtonIs, RadioButtonAttrs, RadioButtonBuilder, RadioButtonAttrCaps, RadioButtonSlotCaps, RadioButtonChildAdmittedBy, RadioButtonSize, radioButton, radioButtonSize, radioButtonDisabled, radioButtonPill, radioButtonValue, radioButtonDefaultValue, radioButtonOnBlur, radioButtonOnFocus)

{-| The **RadioButton** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.RadioButton`](Sl.Element.RadioButton) as `radioButton`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs RadioButtonIs, RadioButtonAttrs, RadioButtonBuilder, RadioButtonAttrCaps, RadioButtonSlotCaps, RadioButtonChildAdmittedBy, RadioButtonSize, radioButton, radioButtonSize, radioButtonDisabled, radioButtonPill, radioButtonValue, radioButtonDefaultValue, radioButtonOnBlur, radioButtonOnFocus

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.RadioButton as RadioButton_


{-| The `radioButton` element of this family — delegates to [`Sl.Element.RadioButton.component`](Sl.Element.RadioButton#component).
-}
radioButton :
    List (Attr RadioButtonAttrs msg)
    -> List (Element childAccepts (RadioButtonChildAdmittedBy childAdm) msg)
    -> Element (RadioButtonIs s) admittedBy msg
radioButton =
    RadioButton_.component


{-| See [`Sl.Element.RadioButton.Is`](Sl.Element.RadioButton#Is).
-}
type alias RadioButtonIs s =
    RadioButton_.Is s


{-| See [`Sl.Element.RadioButton.Attrs`](Sl.Element.RadioButton#Attrs).
-}
type alias RadioButtonAttrs =
    RadioButton_.Attrs


{-| See [`Sl.Element.RadioButton.Builder`](Sl.Element.RadioButton#Builder).
-}
type alias RadioButtonBuilder attrCaps slotCaps msg kind =
    RadioButton_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.RadioButton.AttrCaps`](Sl.Element.RadioButton#AttrCaps).
-}
type alias RadioButtonAttrCaps =
    RadioButton_.AttrCaps


{-| See [`Sl.Element.RadioButton.SlotCaps`](Sl.Element.RadioButton#SlotCaps).
-}
type alias RadioButtonSlotCaps =
    RadioButton_.SlotCaps


{-| See [`Sl.Element.RadioButton.ChildAdmittedBy`](Sl.Element.RadioButton#ChildAdmittedBy).
-}
type alias RadioButtonChildAdmittedBy childAdm =
    RadioButton_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.RadioButton.Size`](Sl.Element.RadioButton#Size).
-}
type alias RadioButtonSize =
    RadioButton_.Size


{-| See [`Sl.Element.RadioButton.size`](Sl.Element.RadioButton#size).
-}
radioButtonSize : Value RadioButtonSize -> Attr { c | size : Supported } msg
radioButtonSize =
    RadioButton_.size


{-| See [`Sl.Element.RadioButton.disabled`](Sl.Element.RadioButton#disabled).
-}
radioButtonDisabled : Bool -> Attr { c | disabled : Supported } msg
radioButtonDisabled =
    RadioButton_.disabled


{-| See [`Sl.Element.RadioButton.pill`](Sl.Element.RadioButton#pill).
-}
radioButtonPill : Bool -> Attr { c | pill : Supported } msg
radioButtonPill =
    RadioButton_.pill


{-| See [`Sl.Element.RadioButton.value`](Sl.Element.RadioButton#value).
-}
radioButtonValue : String -> Attr { c | value : Supported } msg
radioButtonValue =
    RadioButton_.value


{-| See [`Sl.Element.RadioButton.defaultValue`](Sl.Element.RadioButton#defaultValue).
-}
radioButtonDefaultValue : String -> Attr { c | value : Supported } msg
radioButtonDefaultValue =
    RadioButton_.defaultValue


{-| See [`Sl.Element.RadioButton.onBlur`](Sl.Element.RadioButton#onBlur).
-}
radioButtonOnBlur : msg -> Attr { c | onBlur : Supported } msg
radioButtonOnBlur =
    RadioButton_.onBlur


{-| See [`Sl.Element.RadioButton.onFocus`](Sl.Element.RadioButton#onFocus).
-}
radioButtonOnFocus : msg -> Attr { c | onFocus : Supported } msg
radioButtonOnFocus =
    RadioButton_.onFocus
