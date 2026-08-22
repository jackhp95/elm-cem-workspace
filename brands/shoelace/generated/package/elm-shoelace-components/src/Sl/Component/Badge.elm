module Sl.Component.Badge exposing (BadgeIs, BadgeAttrs, BadgeBuilder, BadgeAttrCaps, BadgeSlotCaps, BadgeChildAdmittedBy, BadgeVariant, badge, badgeVariant, badgePill, badgePulse)

{-| The **Badge** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Badge`](Sl.Element.Badge) as `badge`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs BadgeIs, BadgeAttrs, BadgeBuilder, BadgeAttrCaps, BadgeSlotCaps, BadgeChildAdmittedBy, BadgeVariant, badge, badgeVariant, badgePill, badgePulse

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Badge as Badge_


{-| The `badge` element of this family — delegates to [`Sl.Element.Badge.component`](Sl.Element.Badge#component).
-}
badge :
    List (Attr BadgeAttrs msg)
    -> List (Element childAccepts (BadgeChildAdmittedBy childAdm) msg)
    -> Element (BadgeIs s) admittedBy msg
badge =
    Badge_.component


{-| See [`Sl.Element.Badge.Is`](Sl.Element.Badge#Is).
-}
type alias BadgeIs s =
    Badge_.Is s


{-| See [`Sl.Element.Badge.Attrs`](Sl.Element.Badge#Attrs).
-}
type alias BadgeAttrs =
    Badge_.Attrs


{-| See [`Sl.Element.Badge.Builder`](Sl.Element.Badge#Builder).
-}
type alias BadgeBuilder attrCaps slotCaps msg kind =
    Badge_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Badge.AttrCaps`](Sl.Element.Badge#AttrCaps).
-}
type alias BadgeAttrCaps =
    Badge_.AttrCaps


{-| See [`Sl.Element.Badge.SlotCaps`](Sl.Element.Badge#SlotCaps).
-}
type alias BadgeSlotCaps =
    Badge_.SlotCaps


{-| See [`Sl.Element.Badge.ChildAdmittedBy`](Sl.Element.Badge#ChildAdmittedBy).
-}
type alias BadgeChildAdmittedBy childAdm =
    Badge_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Badge.Variant`](Sl.Element.Badge#Variant).
-}
type alias BadgeVariant =
    Badge_.Variant


{-| See [`Sl.Element.Badge.variant`](Sl.Element.Badge#variant).
-}
badgeVariant : Value BadgeVariant -> Attr { c | variant : Supported } msg
badgeVariant =
    Badge_.variant


{-| See [`Sl.Element.Badge.pill`](Sl.Element.Badge#pill).
-}
badgePill : Bool -> Attr { c | pill : Supported } msg
badgePill =
    Badge_.pill


{-| See [`Sl.Element.Badge.pulse`](Sl.Element.Badge#pulse).
-}
badgePulse : Bool -> Attr { c | pulse : Supported } msg
badgePulse =
    Badge_.pulse
