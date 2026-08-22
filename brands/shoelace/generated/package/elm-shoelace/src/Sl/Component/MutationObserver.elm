module Sl.Component.MutationObserver exposing (MutationObserverIs, MutationObserverAttrs, MutationObserverBuilder, MutationObserverAttrCaps, MutationObserverSlotCaps, MutationObserverChildAdmittedBy, mutationObserver, mutationObserverAttr, mutationObserverAttrOldValue, mutationObserverCharData, mutationObserverCharDataOldValue, mutationObserverChildList, mutationObserverDisabled, mutationObserverOnMutation)

{-| The **MutationObserver** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.MutationObserver`](Sl.Element.MutationObserver) as `mutationObserver`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs MutationObserverIs, MutationObserverAttrs, MutationObserverBuilder, MutationObserverAttrCaps, MutationObserverSlotCaps, MutationObserverChildAdmittedBy, mutationObserver, mutationObserverAttr, mutationObserverAttrOldValue, mutationObserverCharData, mutationObserverCharDataOldValue, mutationObserverChildList, mutationObserverDisabled, mutationObserverOnMutation

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.MutationObserver as MutationObserver_


{-| The `mutationObserver` element of this family — delegates to [`Sl.Element.MutationObserver.component`](Sl.Element.MutationObserver#component).
-}
mutationObserver :
    List (Attr MutationObserverAttrs msg)
    -> List (Element childAccepts (MutationObserverChildAdmittedBy childAdm) msg)
    -> Element (MutationObserverIs s) admittedBy msg
mutationObserver =
    MutationObserver_.component


{-| See [`Sl.Element.MutationObserver.Is`](Sl.Element.MutationObserver#Is).
-}
type alias MutationObserverIs s =
    MutationObserver_.Is s


{-| See [`Sl.Element.MutationObserver.Attrs`](Sl.Element.MutationObserver#Attrs).
-}
type alias MutationObserverAttrs =
    MutationObserver_.Attrs


{-| See [`Sl.Element.MutationObserver.Builder`](Sl.Element.MutationObserver#Builder).
-}
type alias MutationObserverBuilder attrCaps slotCaps msg kind =
    MutationObserver_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.MutationObserver.AttrCaps`](Sl.Element.MutationObserver#AttrCaps).
-}
type alias MutationObserverAttrCaps =
    MutationObserver_.AttrCaps


{-| See [`Sl.Element.MutationObserver.SlotCaps`](Sl.Element.MutationObserver#SlotCaps).
-}
type alias MutationObserverSlotCaps =
    MutationObserver_.SlotCaps


{-| See [`Sl.Element.MutationObserver.ChildAdmittedBy`](Sl.Element.MutationObserver#ChildAdmittedBy).
-}
type alias MutationObserverChildAdmittedBy childAdm =
    MutationObserver_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.MutationObserver.attr`](Sl.Element.MutationObserver#attr).
-}
mutationObserverAttr : String -> Attr { c | attr : Supported } msg
mutationObserverAttr =
    MutationObserver_.attr


{-| See [`Sl.Element.MutationObserver.attrOldValue`](Sl.Element.MutationObserver#attrOldValue).
-}
mutationObserverAttrOldValue : Bool -> Attr { c | attrOldValue : Supported } msg
mutationObserverAttrOldValue =
    MutationObserver_.attrOldValue


{-| See [`Sl.Element.MutationObserver.charData`](Sl.Element.MutationObserver#charData).
-}
mutationObserverCharData : Bool -> Attr { c | charData : Supported } msg
mutationObserverCharData =
    MutationObserver_.charData


{-| See [`Sl.Element.MutationObserver.charDataOldValue`](Sl.Element.MutationObserver#charDataOldValue).
-}
mutationObserverCharDataOldValue : Bool -> Attr { c | charDataOldValue : Supported } msg
mutationObserverCharDataOldValue =
    MutationObserver_.charDataOldValue


{-| See [`Sl.Element.MutationObserver.childList`](Sl.Element.MutationObserver#childList).
-}
mutationObserverChildList : Bool -> Attr { c | childList : Supported } msg
mutationObserverChildList =
    MutationObserver_.childList


{-| See [`Sl.Element.MutationObserver.disabled`](Sl.Element.MutationObserver#disabled).
-}
mutationObserverDisabled : Bool -> Attr { c | disabled : Supported } msg
mutationObserverDisabled =
    MutationObserver_.disabled


{-| See [`Sl.Element.MutationObserver.onMutation`](Sl.Element.MutationObserver#onMutation).
-}
mutationObserverOnMutation : msg -> Attr { c | onMutation : Supported } msg
mutationObserverOnMutation =
    MutationObserver_.onMutation
