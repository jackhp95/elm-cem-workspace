module Sl.Component.TabGroup exposing (TabGroupIs, TabGroupAttrs, TabGroupBuilder, TabGroupAttrCaps, TabGroupSlotCaps, TabGroupContent, TabGroupNavSlot, TabGroupChildAdmittedBy, TabGroupActivation, TabGroupPlacement, tabGroup, tabGroupActivation, tabGroupPlacement, tabGroupFixedScrollControls, tabGroupNoScrollControls, tabGroupOnTabShow, tabGroupOnTabHide, tabGroupNav, tabGroupChild)

{-| The **TabGroup** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.TabGroup`](Sl.Element.TabGroup) as `tabGroup`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs TabGroupIs, TabGroupAttrs, TabGroupBuilder, TabGroupAttrCaps, TabGroupSlotCaps, TabGroupContent, TabGroupNavSlot, TabGroupChildAdmittedBy, TabGroupActivation, TabGroupPlacement, tabGroup, tabGroupActivation, tabGroupPlacement, tabGroupFixedScrollControls, tabGroupNoScrollControls, tabGroupOnTabShow, tabGroupOnTabHide, tabGroupNav, tabGroupChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.TabGroup as TabGroup_


{-| The `tabGroup` element of this family — delegates to [`Sl.Element.TabGroup.component`](Sl.Element.TabGroup#component).
-}
tabGroup :
    List (Attr TabGroupAttrs msg)
    -> List (Element TabGroupContent (TabGroupChildAdmittedBy childAdm) msg)
    -> Element (TabGroupIs s) admittedBy msg
tabGroup =
    TabGroup_.component


{-| See [`Sl.Element.TabGroup.Is`](Sl.Element.TabGroup#Is).
-}
type alias TabGroupIs s =
    TabGroup_.Is s


{-| See [`Sl.Element.TabGroup.Attrs`](Sl.Element.TabGroup#Attrs).
-}
type alias TabGroupAttrs =
    TabGroup_.Attrs


{-| See [`Sl.Element.TabGroup.Builder`](Sl.Element.TabGroup#Builder).
-}
type alias TabGroupBuilder attrCaps slotCaps msg kind =
    TabGroup_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.TabGroup.AttrCaps`](Sl.Element.TabGroup#AttrCaps).
-}
type alias TabGroupAttrCaps =
    TabGroup_.AttrCaps


{-| See [`Sl.Element.TabGroup.SlotCaps`](Sl.Element.TabGroup#SlotCaps).
-}
type alias TabGroupSlotCaps =
    TabGroup_.SlotCaps


{-| See [`Sl.Element.TabGroup.Content`](Sl.Element.TabGroup#Content).
-}
type alias TabGroupContent =
    TabGroup_.Content


{-| See [`Sl.Element.TabGroup.NavSlot`](Sl.Element.TabGroup#NavSlot).
-}
type alias TabGroupNavSlot =
    TabGroup_.NavSlot


{-| See [`Sl.Element.TabGroup.ChildAdmittedBy`](Sl.Element.TabGroup#ChildAdmittedBy).
-}
type alias TabGroupChildAdmittedBy childAdm =
    TabGroup_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.TabGroup.Activation`](Sl.Element.TabGroup#Activation).
-}
type alias TabGroupActivation =
    TabGroup_.Activation


{-| See [`Sl.Element.TabGroup.activation`](Sl.Element.TabGroup#activation).
-}
tabGroupActivation : Value TabGroupActivation -> Attr { c | activation : Supported } msg
tabGroupActivation =
    TabGroup_.activation


{-| See [`Sl.Element.TabGroup.Placement`](Sl.Element.TabGroup#Placement).
-}
type alias TabGroupPlacement =
    TabGroup_.Placement


{-| See [`Sl.Element.TabGroup.placement`](Sl.Element.TabGroup#placement).
-}
tabGroupPlacement : Value TabGroupPlacement -> Attr { c | placement : Supported } msg
tabGroupPlacement =
    TabGroup_.placement


{-| See [`Sl.Element.TabGroup.fixedScrollControls`](Sl.Element.TabGroup#fixedScrollControls).
-}
tabGroupFixedScrollControls : Bool -> Attr { c | fixedScrollControls : Supported } msg
tabGroupFixedScrollControls =
    TabGroup_.fixedScrollControls


{-| See [`Sl.Element.TabGroup.noScrollControls`](Sl.Element.TabGroup#noScrollControls).
-}
tabGroupNoScrollControls : Bool -> Attr { c | noScrollControls : Supported } msg
tabGroupNoScrollControls =
    TabGroup_.noScrollControls


{-| See [`Sl.Element.TabGroup.onTabShow`](Sl.Element.TabGroup#onTabShow).
-}
tabGroupOnTabShow : msg -> Attr { c | onTabShow : Supported } msg
tabGroupOnTabShow =
    TabGroup_.onTabShow


{-| See [`Sl.Element.TabGroup.onTabHide`](Sl.Element.TabGroup#onTabHide).
-}
tabGroupOnTabHide : msg -> Attr { c | onTabHide : Supported } msg
tabGroupOnTabHide =
    TabGroup_.onTabHide


{-| See [`Sl.Element.TabGroup.nav`](Sl.Element.TabGroup#nav).
-}
tabGroupNav : Element TabGroupNavSlot admittedBy msg -> Element free freeAdmittedBy msg
tabGroupNav =
    TabGroup_.nav


{-| See [`Sl.Element.TabGroup.child`](Sl.Element.TabGroup#child).
-}
tabGroupChild : Element TabGroupContent admittedBy msg -> Element free freeAdmittedBy msg
tabGroupChild =
    TabGroup_.child
