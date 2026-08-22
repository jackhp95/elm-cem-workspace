module Hz.Component2.EventClash exposing (EventClashIs, EventClashAttrs, EventClashBuilder, EventClashAttrCaps, EventClashSlotCaps, EventClashContent, EventClashChildAdmittedBy, eventClash, eventClashOnError, eventClashOnHzError, eventClashOnLoad, eventClashOnHzLoad, eventClashChild)

{-| The **EventClash** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Hz.Element.EventClash`](Hz.Element.EventClash) as `eventClash`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs EventClashIs, EventClashAttrs, EventClashBuilder, EventClashAttrCaps, EventClashSlotCaps, EventClashContent, EventClashChildAdmittedBy, eventClash, eventClashOnError, eventClashOnHzError, eventClashOnLoad, eventClashOnHzLoad, eventClashChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Hz.Element.EventClash as EventClash_


{-| The `eventClash` element of this family — delegates to [`Hz.Element.EventClash.component`](Hz.Element.EventClash#component).
-}
eventClash :
    List (Attr EventClashAttrs msg)
    -> List (Element EventClashContent (EventClashChildAdmittedBy childAdm) msg)
    -> Element (EventClashIs s) admittedBy msg
eventClash =
    EventClash_.component


{-| See [`Hz.Element.EventClash.Is`](Hz.Element.EventClash#Is).
-}
type alias EventClashIs s =
    EventClash_.Is s


{-| See [`Hz.Element.EventClash.Attrs`](Hz.Element.EventClash#Attrs).
-}
type alias EventClashAttrs =
    EventClash_.Attrs


{-| See [`Hz.Element.EventClash.Builder`](Hz.Element.EventClash#Builder).
-}
type alias EventClashBuilder attrCaps slotCaps msg kind =
    EventClash_.Builder attrCaps slotCaps msg kind


{-| See [`Hz.Element.EventClash.AttrCaps`](Hz.Element.EventClash#AttrCaps).
-}
type alias EventClashAttrCaps =
    EventClash_.AttrCaps


{-| See [`Hz.Element.EventClash.SlotCaps`](Hz.Element.EventClash#SlotCaps).
-}
type alias EventClashSlotCaps =
    EventClash_.SlotCaps


{-| See [`Hz.Element.EventClash.Content`](Hz.Element.EventClash#Content).
-}
type alias EventClashContent =
    EventClash_.Content


{-| See [`Hz.Element.EventClash.ChildAdmittedBy`](Hz.Element.EventClash#ChildAdmittedBy).
-}
type alias EventClashChildAdmittedBy childAdm =
    EventClash_.ChildAdmittedBy childAdm


{-| See [`Hz.Element.EventClash.onError`](Hz.Element.EventClash#onError).
-}
eventClashOnError : msg -> Attr { c | onError : Supported } msg
eventClashOnError =
    EventClash_.onError


{-| See [`Hz.Element.EventClash.onHzError`](Hz.Element.EventClash#onHzError).
-}
eventClashOnHzError : msg -> Attr { c | onHzError : Supported } msg
eventClashOnHzError =
    EventClash_.onHzError


{-| See [`Hz.Element.EventClash.onLoad`](Hz.Element.EventClash#onLoad).
-}
eventClashOnLoad : msg -> Attr { c | onLoad : Supported } msg
eventClashOnLoad =
    EventClash_.onLoad


{-| See [`Hz.Element.EventClash.onHzLoad`](Hz.Element.EventClash#onHzLoad).
-}
eventClashOnHzLoad : msg -> Attr { c | onHzLoad : Supported } msg
eventClashOnHzLoad =
    EventClash_.onHzLoad


{-| See [`Hz.Element.EventClash.child`](Hz.Element.EventClash#child).
-}
eventClashChild : Element EventClashContent admittedBy msg -> Element free freeAdmittedBy msg
eventClashChild =
    EventClash_.child
