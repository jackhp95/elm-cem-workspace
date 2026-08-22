module M3e.Component.ActionList exposing (ActionListIs, ActionListAttrs, ActionListBuilder, ActionListAttrCaps, ActionListSlotCaps, ActionListContent, ActionListChildAdmittedBy, ActionListVariant, actionList, actionListVariant, actionListChild)

{-| The **ActionList** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.ActionList`](M3e.Element.ActionList) as `actionList`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ActionListIs, ActionListAttrs, ActionListBuilder, ActionListAttrCaps, ActionListSlotCaps, ActionListContent, ActionListChildAdmittedBy, ActionListVariant, actionList, actionListVariant, actionListChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.ActionList as ActionList_


{-| The `actionList` element of this family — delegates to [`M3e.Element.ActionList.component`](M3e.Element.ActionList#component).
-}
actionList :
    List (Attr ActionListAttrs msg)
    -> List (Element ActionListContent (ActionListChildAdmittedBy childAdm) msg)
    -> Element (ActionListIs s) admittedBy msg
actionList =
    ActionList_.component


{-| See [`M3e.Element.ActionList.Is`](M3e.Element.ActionList#Is).
-}
type alias ActionListIs s =
    ActionList_.Is s


{-| See [`M3e.Element.ActionList.Attrs`](M3e.Element.ActionList#Attrs).
-}
type alias ActionListAttrs =
    ActionList_.Attrs


{-| See [`M3e.Element.ActionList.Builder`](M3e.Element.ActionList#Builder).
-}
type alias ActionListBuilder attrCaps slotCaps msg kind =
    ActionList_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.ActionList.AttrCaps`](M3e.Element.ActionList#AttrCaps).
-}
type alias ActionListAttrCaps =
    ActionList_.AttrCaps


{-| See [`M3e.Element.ActionList.SlotCaps`](M3e.Element.ActionList#SlotCaps).
-}
type alias ActionListSlotCaps =
    ActionList_.SlotCaps


{-| See [`M3e.Element.ActionList.Content`](M3e.Element.ActionList#Content).
-}
type alias ActionListContent =
    ActionList_.Content


{-| See [`M3e.Element.ActionList.ChildAdmittedBy`](M3e.Element.ActionList#ChildAdmittedBy).
-}
type alias ActionListChildAdmittedBy childAdm =
    ActionList_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.ActionList.Variant`](M3e.Element.ActionList#Variant).
-}
type alias ActionListVariant =
    ActionList_.Variant


{-| See [`M3e.Element.ActionList.variant`](M3e.Element.ActionList#variant).
-}
actionListVariant : Value ActionListVariant -> Attr { c | variant : Supported } msg
actionListVariant =
    ActionList_.variant


{-| See [`M3e.Element.ActionList.child`](M3e.Element.ActionList#child).
-}
actionListChild : Element ActionListContent admittedBy msg -> Element free freeAdmittedBy msg
actionListChild =
    ActionList_.child
