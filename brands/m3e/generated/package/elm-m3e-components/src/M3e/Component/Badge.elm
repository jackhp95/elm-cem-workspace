module M3e.Component.Badge exposing (BadgeIs, BadgeAttrs, BadgeBuilder, BadgeAttrCaps, BadgeSlotCaps, BadgeContent, BadgeChildAdmittedBy, BadgePosition, BadgeSize, badge, badgePosition, badgeSize, badgeFor, badgeChild)

{-| The **Badge** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Badge`](M3e.Element.Badge) as `badge`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs BadgeIs, BadgeAttrs, BadgeBuilder, BadgeAttrCaps, BadgeSlotCaps, BadgeContent, BadgeChildAdmittedBy, BadgePosition, BadgeSize, badge, badgePosition, badgeSize, badgeFor, badgeChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Badge as Badge_


{-| The `badge` element of this family — delegates to [`M3e.Element.Badge.component`](M3e.Element.Badge#component).
-}
badge :
    List (Attr BadgeAttrs msg)
    -> List (Element BadgeContent (BadgeChildAdmittedBy childAdm) msg)
    -> Element (BadgeIs s) admittedBy msg
badge =
    Badge_.component


{-| See [`M3e.Element.Badge.Is`](M3e.Element.Badge#Is).
-}
type alias BadgeIs s =
    Badge_.Is s


{-| See [`M3e.Element.Badge.Attrs`](M3e.Element.Badge#Attrs).
-}
type alias BadgeAttrs =
    Badge_.Attrs


{-| See [`M3e.Element.Badge.Builder`](M3e.Element.Badge#Builder).
-}
type alias BadgeBuilder attrCaps slotCaps msg kind =
    Badge_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Badge.AttrCaps`](M3e.Element.Badge#AttrCaps).
-}
type alias BadgeAttrCaps =
    Badge_.AttrCaps


{-| See [`M3e.Element.Badge.SlotCaps`](M3e.Element.Badge#SlotCaps).
-}
type alias BadgeSlotCaps =
    Badge_.SlotCaps


{-| See [`M3e.Element.Badge.Content`](M3e.Element.Badge#Content).
-}
type alias BadgeContent =
    Badge_.Content


{-| See [`M3e.Element.Badge.ChildAdmittedBy`](M3e.Element.Badge#ChildAdmittedBy).
-}
type alias BadgeChildAdmittedBy childAdm =
    Badge_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Badge.Position`](M3e.Element.Badge#Position).
-}
type alias BadgePosition =
    Badge_.Position


{-| See [`M3e.Element.Badge.position`](M3e.Element.Badge#position).
-}
badgePosition : Value BadgePosition -> Attr { c | position : Supported } msg
badgePosition =
    Badge_.position


{-| See [`M3e.Element.Badge.Size`](M3e.Element.Badge#Size).
-}
type alias BadgeSize =
    Badge_.Size


{-| See [`M3e.Element.Badge.size`](M3e.Element.Badge#size).
-}
badgeSize : Value BadgeSize -> Attr { c | size : Supported } msg
badgeSize =
    Badge_.size


{-| See [`M3e.Element.Badge.for`](M3e.Element.Badge#for).
-}
badgeFor : String -> Attr { c | for : Supported } msg
badgeFor =
    Badge_.for


{-| See [`M3e.Element.Badge.child`](M3e.Element.Badge#child).
-}
badgeChild : Element BadgeContent admittedBy msg -> Element free freeAdmittedBy msg
badgeChild =
    Badge_.child
