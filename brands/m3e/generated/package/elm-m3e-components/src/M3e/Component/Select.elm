module M3e.Component.Select exposing (SelectIs, SelectAttrs, SelectBuilder, SelectAttrCaps, SelectSlotCaps, SelectContent, SelectArrowSlot, SelectChildAdmittedBy, select, selectDisabled, selectHideSelectionIndicator, selectMulti, selectName, selectPanelClass, selectRequired, selectValidationmessages, selectOnChange, selectOnToggle, selectOnBeforeinput, selectOnInput, selectArrow, selectValue, selectChild)

{-| The **Select** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Select`](M3e.Element.Select) as `select`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SelectIs, SelectAttrs, SelectBuilder, SelectAttrCaps, SelectSlotCaps, SelectContent, SelectArrowSlot, SelectChildAdmittedBy, select, selectDisabled, selectHideSelectionIndicator, selectMulti, selectName, selectPanelClass, selectRequired, selectValidationmessages, selectOnChange, selectOnToggle, selectOnBeforeinput, selectOnInput, selectArrow, selectValue, selectChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.Select as Select_


{-| The `select` element of this family — delegates to [`M3e.Element.Select.component`](M3e.Element.Select#component).
-}
select :
    { content : Element SelectContent (SelectChildAdmittedBy childAdm) msg }
    -> List (Attr SelectAttrs msg)
    -> List (Element SelectContent (SelectChildAdmittedBy childAdm) msg)
    -> Element (SelectIs s) admittedBy msg
select =
    Select_.component


{-| See [`M3e.Element.Select.Is`](M3e.Element.Select#Is).
-}
type alias SelectIs s =
    Select_.Is s


{-| See [`M3e.Element.Select.Attrs`](M3e.Element.Select#Attrs).
-}
type alias SelectAttrs =
    Select_.Attrs


{-| See [`M3e.Element.Select.Builder`](M3e.Element.Select#Builder).
-}
type alias SelectBuilder attrCaps slotCaps msg kind =
    Select_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Select.AttrCaps`](M3e.Element.Select#AttrCaps).
-}
type alias SelectAttrCaps =
    Select_.AttrCaps


{-| See [`M3e.Element.Select.SlotCaps`](M3e.Element.Select#SlotCaps).
-}
type alias SelectSlotCaps =
    Select_.SlotCaps


{-| See [`M3e.Element.Select.Content`](M3e.Element.Select#Content).
-}
type alias SelectContent =
    Select_.Content


{-| See [`M3e.Element.Select.ArrowSlot`](M3e.Element.Select#ArrowSlot).
-}
type alias SelectArrowSlot =
    Select_.ArrowSlot


{-| See [`M3e.Element.Select.ChildAdmittedBy`](M3e.Element.Select#ChildAdmittedBy).
-}
type alias SelectChildAdmittedBy childAdm =
    Select_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Select.disabled`](M3e.Element.Select#disabled).
-}
selectDisabled : Bool -> Attr { c | disabled : Supported } msg
selectDisabled =
    Select_.disabled


{-| See [`M3e.Element.Select.hideSelectionIndicator`](M3e.Element.Select#hideSelectionIndicator).
-}
selectHideSelectionIndicator : Bool -> Attr { c | hideSelectionIndicator : Supported } msg
selectHideSelectionIndicator =
    Select_.hideSelectionIndicator


{-| See [`M3e.Element.Select.multi`](M3e.Element.Select#multi).
-}
selectMulti : Bool -> Attr { c | multi : Supported } msg
selectMulti =
    Select_.multi


{-| See [`M3e.Element.Select.name`](M3e.Element.Select#name).
-}
selectName : String -> Attr { c | name : Supported } msg
selectName =
    Select_.name


{-| See [`M3e.Element.Select.panelClass`](M3e.Element.Select#panelClass).
-}
selectPanelClass : String -> Attr { c | panelClass : Supported } msg
selectPanelClass =
    Select_.panelClass


{-| See [`M3e.Element.Select.required`](M3e.Element.Select#required).
-}
selectRequired : Bool -> Attr { c | required : Supported } msg
selectRequired =
    Select_.required


{-| See [`M3e.Element.Select.validationmessages`](M3e.Element.Select#validationmessages).
-}
selectValidationmessages : String -> Attr { c | validationmessages : Supported } msg
selectValidationmessages =
    Select_.validationmessages


{-| See [`M3e.Element.Select.onChange`](M3e.Element.Select#onChange).
-}
selectOnChange : msg -> Attr { c | onChange : Supported } msg
selectOnChange =
    Select_.onChange


{-| See [`M3e.Element.Select.onToggle`](M3e.Element.Select#onToggle).
-}
selectOnToggle : (String -> msg) -> Attr { c | onToggle : Supported } msg
selectOnToggle =
    Select_.onToggle


{-| See [`M3e.Element.Select.onBeforeinput`](M3e.Element.Select#onBeforeinput).
-}
selectOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
selectOnBeforeinput =
    Select_.onBeforeinput


{-| See [`M3e.Element.Select.onInput`](M3e.Element.Select#onInput).
-}
selectOnInput : msg -> Attr { c | onInput : Supported } msg
selectOnInput =
    Select_.onInput


{-| See [`M3e.Element.Select.arrow`](M3e.Element.Select#arrow).
-}
selectArrow : Element SelectArrowSlot admittedBy msg -> Element free freeAdmittedBy msg
selectArrow =
    Select_.arrow


{-| See [`M3e.Element.Select.value`](M3e.Element.Select#value).
-}
selectValue : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
selectValue =
    Select_.value


{-| See [`M3e.Element.Select.child`](M3e.Element.Select#child).
-}
selectChild : Element SelectContent admittedBy msg -> Element free freeAdmittedBy msg
selectChild =
    Select_.child
