module Hz.Component.Blocked exposing (BlockedIs, BlockedAttrs, BlockedBuilder, BlockedAttrCaps, BlockedSlotCaps, BlockedContent, BlockedChildAdmittedBy, blocked, blockedLabel, blockedChild)

{-| The **Blocked** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Hz.Element.Blocked`](Hz.Element.Blocked) as `blocked`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs BlockedIs, BlockedAttrs, BlockedBuilder, BlockedAttrCaps, BlockedSlotCaps, BlockedContent, BlockedChildAdmittedBy, blocked, blockedLabel, blockedChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Hz.Element.Blocked as Blocked_


{-| The `blocked` element of this family — delegates to [`Hz.Element.Blocked.component`](Hz.Element.Blocked#component).
-}
blocked :
    List (Attr BlockedAttrs msg)
    -> List (Element BlockedContent (BlockedChildAdmittedBy childAdm) msg)
    -> Element (BlockedIs s) admittedBy msg
blocked =
    Blocked_.component


{-| See [`Hz.Element.Blocked.Is`](Hz.Element.Blocked#Is).
-}
type alias BlockedIs s =
    Blocked_.Is s


{-| See [`Hz.Element.Blocked.Attrs`](Hz.Element.Blocked#Attrs).
-}
type alias BlockedAttrs =
    Blocked_.Attrs


{-| See [`Hz.Element.Blocked.Builder`](Hz.Element.Blocked#Builder).
-}
type alias BlockedBuilder attrCaps slotCaps msg kind =
    Blocked_.Builder attrCaps slotCaps msg kind


{-| See [`Hz.Element.Blocked.AttrCaps`](Hz.Element.Blocked#AttrCaps).
-}
type alias BlockedAttrCaps =
    Blocked_.AttrCaps


{-| See [`Hz.Element.Blocked.SlotCaps`](Hz.Element.Blocked#SlotCaps).
-}
type alias BlockedSlotCaps =
    Blocked_.SlotCaps


{-| See [`Hz.Element.Blocked.Content`](Hz.Element.Blocked#Content).
-}
type alias BlockedContent =
    Blocked_.Content


{-| See [`Hz.Element.Blocked.ChildAdmittedBy`](Hz.Element.Blocked#ChildAdmittedBy).
-}
type alias BlockedChildAdmittedBy childAdm =
    Blocked_.ChildAdmittedBy childAdm


{-| See [`Hz.Element.Blocked.label`](Hz.Element.Blocked#label).
-}
blockedLabel : String -> Attr { c | label : Supported } msg
blockedLabel =
    Blocked_.label


{-| See [`Hz.Element.Blocked.child`](Hz.Element.Blocked#child).
-}
blockedChild : Element BlockedContent admittedBy msg -> Element free freeAdmittedBy msg
blockedChild =
    Blocked_.child
