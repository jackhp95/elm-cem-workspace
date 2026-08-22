module Sl.Component.Details exposing (DetailsIs, DetailsAttrs, DetailsBuilder, DetailsAttrCaps, DetailsSlotCaps, DetailsChildAdmittedBy, details, detailsDisabled, detailsOpen, detailsSummary, detailsOnShow, detailsOnAfterShow, detailsOnHide, detailsOnAfterHide)

{-| The **Details** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Details`](Sl.Element.Details) as `details`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs DetailsIs, DetailsAttrs, DetailsBuilder, DetailsAttrCaps, DetailsSlotCaps, DetailsChildAdmittedBy, details, detailsDisabled, detailsOpen, detailsSummary, detailsOnShow, detailsOnAfterShow, detailsOnHide, detailsOnAfterHide

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.Details as Details_


{-| The `details` element of this family — delegates to [`Sl.Element.Details.component`](Sl.Element.Details#component).
-}
details :
    List (Attr DetailsAttrs msg)
    -> List (Element childAccepts (DetailsChildAdmittedBy childAdm) msg)
    -> Element (DetailsIs s) admittedBy msg
details =
    Details_.component


{-| See [`Sl.Element.Details.Is`](Sl.Element.Details#Is).
-}
type alias DetailsIs s =
    Details_.Is s


{-| See [`Sl.Element.Details.Attrs`](Sl.Element.Details#Attrs).
-}
type alias DetailsAttrs =
    Details_.Attrs


{-| See [`Sl.Element.Details.Builder`](Sl.Element.Details#Builder).
-}
type alias DetailsBuilder attrCaps slotCaps msg kind =
    Details_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Details.AttrCaps`](Sl.Element.Details#AttrCaps).
-}
type alias DetailsAttrCaps =
    Details_.AttrCaps


{-| See [`Sl.Element.Details.SlotCaps`](Sl.Element.Details#SlotCaps).
-}
type alias DetailsSlotCaps =
    Details_.SlotCaps


{-| See [`Sl.Element.Details.ChildAdmittedBy`](Sl.Element.Details#ChildAdmittedBy).
-}
type alias DetailsChildAdmittedBy childAdm =
    Details_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Details.disabled`](Sl.Element.Details#disabled).
-}
detailsDisabled : Bool -> Attr { c | disabled : Supported } msg
detailsDisabled =
    Details_.disabled


{-| See [`Sl.Element.Details.open`](Sl.Element.Details#open).
-}
detailsOpen : Bool -> Attr { c | open : Supported } msg
detailsOpen =
    Details_.open


{-| See [`Sl.Element.Details.summary`](Sl.Element.Details#summary).
-}
detailsSummary : String -> Attr { c | summary : Supported } msg
detailsSummary =
    Details_.summary


{-| See [`Sl.Element.Details.onShow`](Sl.Element.Details#onShow).
-}
detailsOnShow : msg -> Attr { c | onShow : Supported } msg
detailsOnShow =
    Details_.onShow


{-| See [`Sl.Element.Details.onAfterShow`](Sl.Element.Details#onAfterShow).
-}
detailsOnAfterShow : msg -> Attr { c | onAfterShow : Supported } msg
detailsOnAfterShow =
    Details_.onAfterShow


{-| See [`Sl.Element.Details.onHide`](Sl.Element.Details#onHide).
-}
detailsOnHide : msg -> Attr { c | onHide : Supported } msg
detailsOnHide =
    Details_.onHide


{-| See [`Sl.Element.Details.onAfterHide`](Sl.Element.Details#onAfterHide).
-}
detailsOnAfterHide : msg -> Attr { c | onAfterHide : Supported } msg
detailsOnAfterHide =
    Details_.onAfterHide
