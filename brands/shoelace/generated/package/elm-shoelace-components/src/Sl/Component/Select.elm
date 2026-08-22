module Sl.Component.Select exposing (SelectIs, SelectAttrs, SelectBuilder, SelectAttrCaps, SelectSlotCaps, SelectContent, SelectChildAdmittedBy, SelectPlacement, SelectSize, select, selectPlacement, selectSize, selectClearable, selectDisabled, selectFilled, selectForm, selectGettag, selectHelpText, selectHoist, selectLabel, selectMaxOptionsVisible, selectMultiple, selectName, selectOpen, selectPill, selectPlaceholder, selectRequired, selectValue, selectDefaultValue, selectOnChange, selectOnClear, selectOnInput, selectOnFocus, selectOnBlur, selectOnShow, selectOnAfterShow, selectOnHide, selectOnAfterHide, selectOnInvalid, selectChild)

{-| The **Select** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Select`](Sl.Element.Select) as `select`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs SelectIs, SelectAttrs, SelectBuilder, SelectAttrCaps, SelectSlotCaps, SelectContent, SelectChildAdmittedBy, SelectPlacement, SelectSize, select, selectPlacement, selectSize, selectClearable, selectDisabled, selectFilled, selectForm, selectGettag, selectHelpText, selectHoist, selectLabel, selectMaxOptionsVisible, selectMultiple, selectName, selectOpen, selectPill, selectPlaceholder, selectRequired, selectValue, selectDefaultValue, selectOnChange, selectOnClear, selectOnInput, selectOnFocus, selectOnBlur, selectOnShow, selectOnAfterShow, selectOnHide, selectOnAfterHide, selectOnInvalid, selectChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Select as Select_


{-| The `select` element of this family — delegates to [`Sl.Element.Select.component`](Sl.Element.Select#component).
-}
select :
    List (Attr SelectAttrs msg)
    -> List (Element SelectContent (SelectChildAdmittedBy childAdm) msg)
    -> Element (SelectIs s) admittedBy msg
select =
    Select_.component


{-| See [`Sl.Element.Select.Is`](Sl.Element.Select#Is).
-}
type alias SelectIs s =
    Select_.Is s


{-| See [`Sl.Element.Select.Attrs`](Sl.Element.Select#Attrs).
-}
type alias SelectAttrs =
    Select_.Attrs


{-| See [`Sl.Element.Select.Builder`](Sl.Element.Select#Builder).
-}
type alias SelectBuilder attrCaps slotCaps msg kind =
    Select_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Select.AttrCaps`](Sl.Element.Select#AttrCaps).
-}
type alias SelectAttrCaps =
    Select_.AttrCaps


{-| See [`Sl.Element.Select.SlotCaps`](Sl.Element.Select#SlotCaps).
-}
type alias SelectSlotCaps =
    Select_.SlotCaps


{-| See [`Sl.Element.Select.Content`](Sl.Element.Select#Content).
-}
type alias SelectContent =
    Select_.Content


{-| See [`Sl.Element.Select.ChildAdmittedBy`](Sl.Element.Select#ChildAdmittedBy).
-}
type alias SelectChildAdmittedBy childAdm =
    Select_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Select.Placement`](Sl.Element.Select#Placement).
-}
type alias SelectPlacement =
    Select_.Placement


{-| See [`Sl.Element.Select.placement`](Sl.Element.Select#placement).
-}
selectPlacement : Value SelectPlacement -> Attr { c | placement : Supported } msg
selectPlacement =
    Select_.placement


{-| See [`Sl.Element.Select.Size`](Sl.Element.Select#Size).
-}
type alias SelectSize =
    Select_.Size


{-| See [`Sl.Element.Select.size`](Sl.Element.Select#size).
-}
selectSize : Value SelectSize -> Attr { c | size : Supported } msg
selectSize =
    Select_.size


{-| See [`Sl.Element.Select.clearable`](Sl.Element.Select#clearable).
-}
selectClearable : Bool -> Attr { c | clearable : Supported } msg
selectClearable =
    Select_.clearable


{-| See [`Sl.Element.Select.disabled`](Sl.Element.Select#disabled).
-}
selectDisabled : Bool -> Attr { c | disabled : Supported } msg
selectDisabled =
    Select_.disabled


{-| See [`Sl.Element.Select.filled`](Sl.Element.Select#filled).
-}
selectFilled : Bool -> Attr { c | filled : Supported } msg
selectFilled =
    Select_.filled


{-| See [`Sl.Element.Select.form`](Sl.Element.Select#form).
-}
selectForm : String -> Attr { c | form : Supported } msg
selectForm =
    Select_.form


{-| See [`Sl.Element.Select.gettag`](Sl.Element.Select#gettag).
-}
selectGettag : String -> Attr { c | gettag : Supported } msg
selectGettag =
    Select_.gettag


{-| See [`Sl.Element.Select.helpText`](Sl.Element.Select#helpText).
-}
selectHelpText : String -> Attr { c | helpText : Supported } msg
selectHelpText =
    Select_.helpText


{-| See [`Sl.Element.Select.hoist`](Sl.Element.Select#hoist).
-}
selectHoist : Bool -> Attr { c | hoist : Supported } msg
selectHoist =
    Select_.hoist


{-| See [`Sl.Element.Select.label`](Sl.Element.Select#label).
-}
selectLabel : String -> Attr { c | label : Supported } msg
selectLabel =
    Select_.label


{-| See [`Sl.Element.Select.maxOptionsVisible`](Sl.Element.Select#maxOptionsVisible).
-}
selectMaxOptionsVisible : Float -> Attr { c | maxOptionsVisible : Supported } msg
selectMaxOptionsVisible =
    Select_.maxOptionsVisible


{-| See [`Sl.Element.Select.multiple`](Sl.Element.Select#multiple).
-}
selectMultiple : Bool -> Attr { c | multiple : Supported } msg
selectMultiple =
    Select_.multiple


{-| See [`Sl.Element.Select.name`](Sl.Element.Select#name).
-}
selectName : String -> Attr { c | name : Supported } msg
selectName =
    Select_.name


{-| See [`Sl.Element.Select.open`](Sl.Element.Select#open).
-}
selectOpen : Bool -> Attr { c | open : Supported } msg
selectOpen =
    Select_.open


{-| See [`Sl.Element.Select.pill`](Sl.Element.Select#pill).
-}
selectPill : Bool -> Attr { c | pill : Supported } msg
selectPill =
    Select_.pill


{-| See [`Sl.Element.Select.placeholder`](Sl.Element.Select#placeholder).
-}
selectPlaceholder : String -> Attr { c | placeholder : Supported } msg
selectPlaceholder =
    Select_.placeholder


{-| See [`Sl.Element.Select.required`](Sl.Element.Select#required).
-}
selectRequired : Bool -> Attr { c | required : Supported } msg
selectRequired =
    Select_.required


{-| See [`Sl.Element.Select.value`](Sl.Element.Select#value).
-}
selectValue : String -> Attr { c | value : Supported } msg
selectValue =
    Select_.value


{-| See [`Sl.Element.Select.defaultValue`](Sl.Element.Select#defaultValue).
-}
selectDefaultValue : String -> Attr { c | value : Supported } msg
selectDefaultValue =
    Select_.defaultValue


{-| See [`Sl.Element.Select.onChange`](Sl.Element.Select#onChange).
-}
selectOnChange : msg -> Attr { c | onChange : Supported } msg
selectOnChange =
    Select_.onChange


{-| See [`Sl.Element.Select.onClear`](Sl.Element.Select#onClear).
-}
selectOnClear : msg -> Attr { c | onClear : Supported } msg
selectOnClear =
    Select_.onClear


{-| See [`Sl.Element.Select.onInput`](Sl.Element.Select#onInput).
-}
selectOnInput : msg -> Attr { c | onInput : Supported } msg
selectOnInput =
    Select_.onInput


{-| See [`Sl.Element.Select.onFocus`](Sl.Element.Select#onFocus).
-}
selectOnFocus : msg -> Attr { c | onFocus : Supported } msg
selectOnFocus =
    Select_.onFocus


{-| See [`Sl.Element.Select.onBlur`](Sl.Element.Select#onBlur).
-}
selectOnBlur : msg -> Attr { c | onBlur : Supported } msg
selectOnBlur =
    Select_.onBlur


{-| See [`Sl.Element.Select.onShow`](Sl.Element.Select#onShow).
-}
selectOnShow : msg -> Attr { c | onShow : Supported } msg
selectOnShow =
    Select_.onShow


{-| See [`Sl.Element.Select.onAfterShow`](Sl.Element.Select#onAfterShow).
-}
selectOnAfterShow : msg -> Attr { c | onAfterShow : Supported } msg
selectOnAfterShow =
    Select_.onAfterShow


{-| See [`Sl.Element.Select.onHide`](Sl.Element.Select#onHide).
-}
selectOnHide : msg -> Attr { c | onHide : Supported } msg
selectOnHide =
    Select_.onHide


{-| See [`Sl.Element.Select.onAfterHide`](Sl.Element.Select#onAfterHide).
-}
selectOnAfterHide : msg -> Attr { c | onAfterHide : Supported } msg
selectOnAfterHide =
    Select_.onAfterHide


{-| See [`Sl.Element.Select.onInvalid`](Sl.Element.Select#onInvalid).
-}
selectOnInvalid : msg -> Attr { c | onInvalid : Supported } msg
selectOnInvalid =
    Select_.onInvalid


{-| See [`Sl.Element.Select.child`](Sl.Element.Select#child).
-}
selectChild : Element SelectContent admittedBy msg -> Element free freeAdmittedBy msg
selectChild =
    Select_.child
