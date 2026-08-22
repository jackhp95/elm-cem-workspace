module Sl.Component.RelativeTime exposing (RelativeTimeIs, RelativeTimeAttrs, RelativeTimeBuilder, RelativeTimeAttrCaps, RelativeTimeSlotCaps, RelativeTimeChildAdmittedBy, RelativeTimeFormat, RelativeTimeNumeric, relativeTime, relativeTimeFormat, relativeTimeNumeric, relativeTimeDate, relativeTimeSync)

{-| The **RelativeTime** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.RelativeTime`](Sl.Element.RelativeTime) as `relativeTime`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs RelativeTimeIs, RelativeTimeAttrs, RelativeTimeBuilder, RelativeTimeAttrCaps, RelativeTimeSlotCaps, RelativeTimeChildAdmittedBy, RelativeTimeFormat, RelativeTimeNumeric, relativeTime, relativeTimeFormat, relativeTimeNumeric, relativeTimeDate, relativeTimeSync

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.RelativeTime as RelativeTime_


{-| The `relativeTime` element of this family — delegates to [`Sl.Element.RelativeTime.component`](Sl.Element.RelativeTime#component).
-}
relativeTime :
    List (Attr RelativeTimeAttrs msg)
    -> List (Element childAccepts (RelativeTimeChildAdmittedBy childAdm) msg)
    -> Element (RelativeTimeIs s) admittedBy msg
relativeTime =
    RelativeTime_.component


{-| See [`Sl.Element.RelativeTime.Is`](Sl.Element.RelativeTime#Is).
-}
type alias RelativeTimeIs s =
    RelativeTime_.Is s


{-| See [`Sl.Element.RelativeTime.Attrs`](Sl.Element.RelativeTime#Attrs).
-}
type alias RelativeTimeAttrs =
    RelativeTime_.Attrs


{-| See [`Sl.Element.RelativeTime.Builder`](Sl.Element.RelativeTime#Builder).
-}
type alias RelativeTimeBuilder attrCaps slotCaps msg kind =
    RelativeTime_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.RelativeTime.AttrCaps`](Sl.Element.RelativeTime#AttrCaps).
-}
type alias RelativeTimeAttrCaps =
    RelativeTime_.AttrCaps


{-| See [`Sl.Element.RelativeTime.SlotCaps`](Sl.Element.RelativeTime#SlotCaps).
-}
type alias RelativeTimeSlotCaps =
    RelativeTime_.SlotCaps


{-| See [`Sl.Element.RelativeTime.ChildAdmittedBy`](Sl.Element.RelativeTime#ChildAdmittedBy).
-}
type alias RelativeTimeChildAdmittedBy childAdm =
    RelativeTime_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.RelativeTime.Format`](Sl.Element.RelativeTime#Format).
-}
type alias RelativeTimeFormat =
    RelativeTime_.Format


{-| See [`Sl.Element.RelativeTime.format`](Sl.Element.RelativeTime#format).
-}
relativeTimeFormat : Value RelativeTimeFormat -> Attr { c | format : Supported } msg
relativeTimeFormat =
    RelativeTime_.format


{-| See [`Sl.Element.RelativeTime.Numeric`](Sl.Element.RelativeTime#Numeric).
-}
type alias RelativeTimeNumeric =
    RelativeTime_.Numeric


{-| See [`Sl.Element.RelativeTime.numeric`](Sl.Element.RelativeTime#numeric).
-}
relativeTimeNumeric : Value RelativeTimeNumeric -> Attr { c | numeric : Supported } msg
relativeTimeNumeric =
    RelativeTime_.numeric


{-| See [`Sl.Element.RelativeTime.date`](Sl.Element.RelativeTime#date).
-}
relativeTimeDate : String -> Attr { c | date : Supported } msg
relativeTimeDate =
    RelativeTime_.date


{-| See [`Sl.Element.RelativeTime.sync`](Sl.Element.RelativeTime#sync).
-}
relativeTimeSync : Bool -> Attr { c | sync : Supported } msg
relativeTimeSync =
    RelativeTime_.sync
