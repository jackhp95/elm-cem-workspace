module Sl.Component.ResizeObserver exposing (ResizeObserverIs, ResizeObserverAttrs, ResizeObserverBuilder, ResizeObserverAttrCaps, ResizeObserverSlotCaps, ResizeObserverChildAdmittedBy, resizeObserver, resizeObserverDisabled, resizeObserverOnResize, resizeObserverChild)

{-| The **ResizeObserver** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.ResizeObserver`](Sl.Element.ResizeObserver) as `resizeObserver`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs ResizeObserverIs, ResizeObserverAttrs, ResizeObserverBuilder, ResizeObserverAttrCaps, ResizeObserverSlotCaps, ResizeObserverChildAdmittedBy, resizeObserver, resizeObserverDisabled, resizeObserverOnResize, resizeObserverChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.ResizeObserver as ResizeObserver_


{-| The `resizeObserver` element of this family — delegates to [`Sl.Element.ResizeObserver.component`](Sl.Element.ResizeObserver#component).
-}
resizeObserver :
    List (Attr ResizeObserverAttrs msg)
    -> List (Element childAccepts (ResizeObserverChildAdmittedBy childAdm) msg)
    -> Element (ResizeObserverIs s) admittedBy msg
resizeObserver =
    ResizeObserver_.component


{-| See [`Sl.Element.ResizeObserver.Is`](Sl.Element.ResizeObserver#Is).
-}
type alias ResizeObserverIs s =
    ResizeObserver_.Is s


{-| See [`Sl.Element.ResizeObserver.Attrs`](Sl.Element.ResizeObserver#Attrs).
-}
type alias ResizeObserverAttrs =
    ResizeObserver_.Attrs


{-| See [`Sl.Element.ResizeObserver.Builder`](Sl.Element.ResizeObserver#Builder).
-}
type alias ResizeObserverBuilder attrCaps slotCaps msg kind =
    ResizeObserver_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.ResizeObserver.AttrCaps`](Sl.Element.ResizeObserver#AttrCaps).
-}
type alias ResizeObserverAttrCaps =
    ResizeObserver_.AttrCaps


{-| See [`Sl.Element.ResizeObserver.SlotCaps`](Sl.Element.ResizeObserver#SlotCaps).
-}
type alias ResizeObserverSlotCaps =
    ResizeObserver_.SlotCaps


{-| See [`Sl.Element.ResizeObserver.ChildAdmittedBy`](Sl.Element.ResizeObserver#ChildAdmittedBy).
-}
type alias ResizeObserverChildAdmittedBy childAdm =
    ResizeObserver_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.ResizeObserver.disabled`](Sl.Element.ResizeObserver#disabled).
-}
resizeObserverDisabled : Bool -> Attr { c | disabled : Supported } msg
resizeObserverDisabled =
    ResizeObserver_.disabled


{-| See [`Sl.Element.ResizeObserver.onResize`](Sl.Element.ResizeObserver#onResize).
-}
resizeObserverOnResize : msg -> Attr { c | onResize : Supported } msg
resizeObserverOnResize =
    ResizeObserver_.onResize


{-| See [`Sl.Element.ResizeObserver.child`](Sl.Element.ResizeObserver#child).
-}
resizeObserverChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
resizeObserverChild =
    ResizeObserver_.child
