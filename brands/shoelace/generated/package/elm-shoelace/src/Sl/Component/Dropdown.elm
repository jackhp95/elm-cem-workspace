module Sl.Component.Dropdown exposing (DropdownIs, DropdownAttrs, DropdownBuilder, DropdownAttrCaps, DropdownSlotCaps, DropdownContent, DropdownTriggerSlot, DropdownChildAdmittedBy, DropdownPlacement, DropdownSync, dropdown, dropdownPlacement, dropdownSync, dropdownDisabled, dropdownDistance, dropdownHoist, dropdownOpen, dropdownSkidding, dropdownStayOpenOnSelect, dropdownOnShow, dropdownOnAfterShow, dropdownOnHide, dropdownOnAfterHide, dropdownTrigger, dropdownChild)

{-| The **Dropdown** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Dropdown`](Sl.Element.Dropdown) as `dropdown`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs DropdownIs, DropdownAttrs, DropdownBuilder, DropdownAttrCaps, DropdownSlotCaps, DropdownContent, DropdownTriggerSlot, DropdownChildAdmittedBy, DropdownPlacement, DropdownSync, dropdown, dropdownPlacement, dropdownSync, dropdownDisabled, dropdownDistance, dropdownHoist, dropdownOpen, dropdownSkidding, dropdownStayOpenOnSelect, dropdownOnShow, dropdownOnAfterShow, dropdownOnHide, dropdownOnAfterHide, dropdownTrigger, dropdownChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Dropdown as Dropdown_


{-| The `dropdown` element of this family — delegates to [`Sl.Element.Dropdown.component`](Sl.Element.Dropdown#component).
-}
dropdown :
    List (Attr DropdownAttrs msg)
    -> List (Element DropdownContent (DropdownChildAdmittedBy childAdm) msg)
    -> Element (DropdownIs s) admittedBy msg
dropdown =
    Dropdown_.component


{-| See [`Sl.Element.Dropdown.Is`](Sl.Element.Dropdown#Is).
-}
type alias DropdownIs s =
    Dropdown_.Is s


{-| See [`Sl.Element.Dropdown.Attrs`](Sl.Element.Dropdown#Attrs).
-}
type alias DropdownAttrs =
    Dropdown_.Attrs


{-| See [`Sl.Element.Dropdown.Builder`](Sl.Element.Dropdown#Builder).
-}
type alias DropdownBuilder attrCaps slotCaps msg kind =
    Dropdown_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Dropdown.AttrCaps`](Sl.Element.Dropdown#AttrCaps).
-}
type alias DropdownAttrCaps =
    Dropdown_.AttrCaps


{-| See [`Sl.Element.Dropdown.SlotCaps`](Sl.Element.Dropdown#SlotCaps).
-}
type alias DropdownSlotCaps =
    Dropdown_.SlotCaps


{-| See [`Sl.Element.Dropdown.Content`](Sl.Element.Dropdown#Content).
-}
type alias DropdownContent =
    Dropdown_.Content


{-| See [`Sl.Element.Dropdown.TriggerSlot`](Sl.Element.Dropdown#TriggerSlot).
-}
type alias DropdownTriggerSlot =
    Dropdown_.TriggerSlot


{-| See [`Sl.Element.Dropdown.ChildAdmittedBy`](Sl.Element.Dropdown#ChildAdmittedBy).
-}
type alias DropdownChildAdmittedBy childAdm =
    Dropdown_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Dropdown.Placement`](Sl.Element.Dropdown#Placement).
-}
type alias DropdownPlacement =
    Dropdown_.Placement


{-| See [`Sl.Element.Dropdown.placement`](Sl.Element.Dropdown#placement).
-}
dropdownPlacement : Value DropdownPlacement -> Attr { c | placement : Supported } msg
dropdownPlacement =
    Dropdown_.placement


{-| See [`Sl.Element.Dropdown.Sync`](Sl.Element.Dropdown#Sync).
-}
type alias DropdownSync =
    Dropdown_.Sync


{-| See [`Sl.Element.Dropdown.sync`](Sl.Element.Dropdown#sync).
-}
dropdownSync : Value DropdownSync -> Attr { c | sync : Supported } msg
dropdownSync =
    Dropdown_.sync


{-| See [`Sl.Element.Dropdown.disabled`](Sl.Element.Dropdown#disabled).
-}
dropdownDisabled : Bool -> Attr { c | disabled : Supported } msg
dropdownDisabled =
    Dropdown_.disabled


{-| See [`Sl.Element.Dropdown.distance`](Sl.Element.Dropdown#distance).
-}
dropdownDistance : Float -> Attr { c | distance : Supported } msg
dropdownDistance =
    Dropdown_.distance


{-| See [`Sl.Element.Dropdown.hoist`](Sl.Element.Dropdown#hoist).
-}
dropdownHoist : Bool -> Attr { c | hoist : Supported } msg
dropdownHoist =
    Dropdown_.hoist


{-| See [`Sl.Element.Dropdown.open`](Sl.Element.Dropdown#open).
-}
dropdownOpen : Bool -> Attr { c | open : Supported } msg
dropdownOpen =
    Dropdown_.open


{-| See [`Sl.Element.Dropdown.skidding`](Sl.Element.Dropdown#skidding).
-}
dropdownSkidding : Float -> Attr { c | skidding : Supported } msg
dropdownSkidding =
    Dropdown_.skidding


{-| See [`Sl.Element.Dropdown.stayOpenOnSelect`](Sl.Element.Dropdown#stayOpenOnSelect).
-}
dropdownStayOpenOnSelect : Bool -> Attr { c | stayOpenOnSelect : Supported } msg
dropdownStayOpenOnSelect =
    Dropdown_.stayOpenOnSelect


{-| See [`Sl.Element.Dropdown.onShow`](Sl.Element.Dropdown#onShow).
-}
dropdownOnShow : msg -> Attr { c | onShow : Supported } msg
dropdownOnShow =
    Dropdown_.onShow


{-| See [`Sl.Element.Dropdown.onAfterShow`](Sl.Element.Dropdown#onAfterShow).
-}
dropdownOnAfterShow : msg -> Attr { c | onAfterShow : Supported } msg
dropdownOnAfterShow =
    Dropdown_.onAfterShow


{-| See [`Sl.Element.Dropdown.onHide`](Sl.Element.Dropdown#onHide).
-}
dropdownOnHide : msg -> Attr { c | onHide : Supported } msg
dropdownOnHide =
    Dropdown_.onHide


{-| See [`Sl.Element.Dropdown.onAfterHide`](Sl.Element.Dropdown#onAfterHide).
-}
dropdownOnAfterHide : msg -> Attr { c | onAfterHide : Supported } msg
dropdownOnAfterHide =
    Dropdown_.onAfterHide


{-| See [`Sl.Element.Dropdown.trigger`](Sl.Element.Dropdown#trigger).
-}
dropdownTrigger : Element DropdownTriggerSlot admittedBy msg -> Element free freeAdmittedBy msg
dropdownTrigger =
    Dropdown_.trigger


{-| See [`Sl.Element.Dropdown.child`](Sl.Element.Dropdown#child).
-}
dropdownChild : Element DropdownContent admittedBy msg -> Element free freeAdmittedBy msg
dropdownChild =
    Dropdown_.child
