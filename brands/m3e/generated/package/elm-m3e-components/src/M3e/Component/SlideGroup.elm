module M3e.Component.SlideGroup exposing (SlideGroupIs, SlideGroupAttrs, SlideGroupBuilder, SlideGroupAttrCaps, SlideGroupSlotCaps, SlideGroupNextIconSlot, SlideGroupPrevIconSlot, SlideGroupChildAdmittedBy, slideGroup, slideGroupDisabled, slideGroupNextPageLabel, slideGroupPreviousPageLabel, slideGroupThreshold, slideGroupVertical, slideGroupNextIcon, slideGroupPrevIcon, slideGroupChild)

{-| The **SlideGroup** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.SlideGroup`](M3e.Element.SlideGroup) as `slideGroup`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SlideGroupIs, SlideGroupAttrs, SlideGroupBuilder, SlideGroupAttrCaps, SlideGroupSlotCaps, SlideGroupNextIconSlot, SlideGroupPrevIconSlot, SlideGroupChildAdmittedBy, slideGroup, slideGroupDisabled, slideGroupNextPageLabel, slideGroupPreviousPageLabel, slideGroupThreshold, slideGroupVertical, slideGroupNextIcon, slideGroupPrevIcon, slideGroupChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.SlideGroup as SlideGroup_


{-| The `slideGroup` element of this family — delegates to [`M3e.Element.SlideGroup.component`](M3e.Element.SlideGroup#component).
-}
slideGroup :
    List (Attr SlideGroupAttrs msg)
    -> List (Element childAccepts (SlideGroupChildAdmittedBy childAdm) msg)
    -> Element (SlideGroupIs s) admittedBy msg
slideGroup =
    SlideGroup_.component


{-| See [`M3e.Element.SlideGroup.Is`](M3e.Element.SlideGroup#Is).
-}
type alias SlideGroupIs s =
    SlideGroup_.Is s


{-| See [`M3e.Element.SlideGroup.Attrs`](M3e.Element.SlideGroup#Attrs).
-}
type alias SlideGroupAttrs =
    SlideGroup_.Attrs


{-| See [`M3e.Element.SlideGroup.Builder`](M3e.Element.SlideGroup#Builder).
-}
type alias SlideGroupBuilder attrCaps slotCaps msg kind =
    SlideGroup_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.SlideGroup.AttrCaps`](M3e.Element.SlideGroup#AttrCaps).
-}
type alias SlideGroupAttrCaps =
    SlideGroup_.AttrCaps


{-| See [`M3e.Element.SlideGroup.SlotCaps`](M3e.Element.SlideGroup#SlotCaps).
-}
type alias SlideGroupSlotCaps =
    SlideGroup_.SlotCaps


{-| See [`M3e.Element.SlideGroup.NextIconSlot`](M3e.Element.SlideGroup#NextIconSlot).
-}
type alias SlideGroupNextIconSlot =
    SlideGroup_.NextIconSlot


{-| See [`M3e.Element.SlideGroup.PrevIconSlot`](M3e.Element.SlideGroup#PrevIconSlot).
-}
type alias SlideGroupPrevIconSlot =
    SlideGroup_.PrevIconSlot


{-| See [`M3e.Element.SlideGroup.ChildAdmittedBy`](M3e.Element.SlideGroup#ChildAdmittedBy).
-}
type alias SlideGroupChildAdmittedBy childAdm =
    SlideGroup_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.SlideGroup.disabled`](M3e.Element.SlideGroup#disabled).
-}
slideGroupDisabled : Bool -> Attr { c | disabled : Supported } msg
slideGroupDisabled =
    SlideGroup_.disabled


{-| See [`M3e.Element.SlideGroup.nextPageLabel`](M3e.Element.SlideGroup#nextPageLabel).
-}
slideGroupNextPageLabel : String -> Attr { c | nextPageLabel : Supported } msg
slideGroupNextPageLabel =
    SlideGroup_.nextPageLabel


{-| See [`M3e.Element.SlideGroup.previousPageLabel`](M3e.Element.SlideGroup#previousPageLabel).
-}
slideGroupPreviousPageLabel : String -> Attr { c | previousPageLabel : Supported } msg
slideGroupPreviousPageLabel =
    SlideGroup_.previousPageLabel


{-| See [`M3e.Element.SlideGroup.threshold`](M3e.Element.SlideGroup#threshold).
-}
slideGroupThreshold : Float -> Attr { c | threshold : Supported } msg
slideGroupThreshold =
    SlideGroup_.threshold


{-| See [`M3e.Element.SlideGroup.vertical`](M3e.Element.SlideGroup#vertical).
-}
slideGroupVertical : Bool -> Attr { c | vertical : Supported } msg
slideGroupVertical =
    SlideGroup_.vertical


{-| See [`M3e.Element.SlideGroup.nextIcon`](M3e.Element.SlideGroup#nextIcon).
-}
slideGroupNextIcon : Element SlideGroupNextIconSlot admittedBy msg -> Element free freeAdmittedBy msg
slideGroupNextIcon =
    SlideGroup_.nextIcon


{-| See [`M3e.Element.SlideGroup.prevIcon`](M3e.Element.SlideGroup#prevIcon).
-}
slideGroupPrevIcon : Element SlideGroupPrevIconSlot admittedBy msg -> Element free freeAdmittedBy msg
slideGroupPrevIcon =
    SlideGroup_.prevIcon


{-| See [`M3e.Element.SlideGroup.child`](M3e.Element.SlideGroup#child).
-}
slideGroupChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
slideGroupChild =
    SlideGroup_.child
