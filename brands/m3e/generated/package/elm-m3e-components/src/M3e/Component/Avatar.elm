module M3e.Component.Avatar exposing (AvatarIs, AvatarAttrs, AvatarBuilder, AvatarAttrCaps, AvatarSlotCaps, AvatarChildAdmittedBy, avatar, avatarChild)

{-| The **Avatar** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Avatar`](M3e.Element.Avatar) as `avatar`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs AvatarIs, AvatarAttrs, AvatarBuilder, AvatarAttrCaps, AvatarSlotCaps, AvatarChildAdmittedBy, avatar, avatarChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import M3e.Element.Avatar as Avatar_


{-| The `avatar` element of this family — delegates to [`M3e.Element.Avatar.component`](M3e.Element.Avatar#component).
-}
avatar :
    List (Attr AvatarAttrs msg)
    -> List (Element childAccepts (AvatarChildAdmittedBy childAdm) msg)
    -> Element (AvatarIs s) admittedBy msg
avatar =
    Avatar_.component


{-| See [`M3e.Element.Avatar.Is`](M3e.Element.Avatar#Is).
-}
type alias AvatarIs s =
    Avatar_.Is s


{-| See [`M3e.Element.Avatar.Attrs`](M3e.Element.Avatar#Attrs).
-}
type alias AvatarAttrs =
    Avatar_.Attrs


{-| See [`M3e.Element.Avatar.Builder`](M3e.Element.Avatar#Builder).
-}
type alias AvatarBuilder attrCaps slotCaps msg kind =
    Avatar_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Avatar.AttrCaps`](M3e.Element.Avatar#AttrCaps).
-}
type alias AvatarAttrCaps =
    Avatar_.AttrCaps


{-| See [`M3e.Element.Avatar.SlotCaps`](M3e.Element.Avatar#SlotCaps).
-}
type alias AvatarSlotCaps =
    Avatar_.SlotCaps


{-| See [`M3e.Element.Avatar.ChildAdmittedBy`](M3e.Element.Avatar#ChildAdmittedBy).
-}
type alias AvatarChildAdmittedBy childAdm =
    Avatar_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Avatar.child`](M3e.Element.Avatar#child).
-}
avatarChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
avatarChild =
    Avatar_.child
