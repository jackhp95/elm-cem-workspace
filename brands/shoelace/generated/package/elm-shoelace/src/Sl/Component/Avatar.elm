module Sl.Component.Avatar exposing (AvatarIs, AvatarAttrs, AvatarBuilder, AvatarAttrCaps, AvatarSlotCaps, AvatarChildAdmittedBy, AvatarLoading, AvatarShape, avatar, avatarLoading, avatarShape, avatarImage, avatarInitials, avatarLabel, avatarOnError)

{-| The **Avatar** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Avatar`](Sl.Element.Avatar) as `avatar`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs AvatarIs, AvatarAttrs, AvatarBuilder, AvatarAttrCaps, AvatarSlotCaps, AvatarChildAdmittedBy, AvatarLoading, AvatarShape, avatar, avatarLoading, avatarShape, avatarImage, avatarInitials, avatarLabel, avatarOnError

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Avatar as Avatar_


{-| The `avatar` element of this family — delegates to [`Sl.Element.Avatar.component`](Sl.Element.Avatar#component).
-}
avatar :
    List (Attr AvatarAttrs msg)
    -> List (Element childAccepts (AvatarChildAdmittedBy childAdm) msg)
    -> Element (AvatarIs s) admittedBy msg
avatar =
    Avatar_.component


{-| See [`Sl.Element.Avatar.Is`](Sl.Element.Avatar#Is).
-}
type alias AvatarIs s =
    Avatar_.Is s


{-| See [`Sl.Element.Avatar.Attrs`](Sl.Element.Avatar#Attrs).
-}
type alias AvatarAttrs =
    Avatar_.Attrs


{-| See [`Sl.Element.Avatar.Builder`](Sl.Element.Avatar#Builder).
-}
type alias AvatarBuilder attrCaps slotCaps msg kind =
    Avatar_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Avatar.AttrCaps`](Sl.Element.Avatar#AttrCaps).
-}
type alias AvatarAttrCaps =
    Avatar_.AttrCaps


{-| See [`Sl.Element.Avatar.SlotCaps`](Sl.Element.Avatar#SlotCaps).
-}
type alias AvatarSlotCaps =
    Avatar_.SlotCaps


{-| See [`Sl.Element.Avatar.ChildAdmittedBy`](Sl.Element.Avatar#ChildAdmittedBy).
-}
type alias AvatarChildAdmittedBy childAdm =
    Avatar_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Avatar.Loading`](Sl.Element.Avatar#Loading).
-}
type alias AvatarLoading =
    Avatar_.Loading


{-| See [`Sl.Element.Avatar.loading`](Sl.Element.Avatar#loading).
-}
avatarLoading : Value AvatarLoading -> Attr { c | loading : Supported } msg
avatarLoading =
    Avatar_.loading


{-| See [`Sl.Element.Avatar.Shape`](Sl.Element.Avatar#Shape).
-}
type alias AvatarShape =
    Avatar_.Shape


{-| See [`Sl.Element.Avatar.shape`](Sl.Element.Avatar#shape).
-}
avatarShape : Value AvatarShape -> Attr { c | shape : Supported } msg
avatarShape =
    Avatar_.shape


{-| See [`Sl.Element.Avatar.image`](Sl.Element.Avatar#image).
-}
avatarImage : String -> Attr { c | image : Supported } msg
avatarImage =
    Avatar_.image


{-| See [`Sl.Element.Avatar.initials`](Sl.Element.Avatar#initials).
-}
avatarInitials : String -> Attr { c | initials : Supported } msg
avatarInitials =
    Avatar_.initials


{-| See [`Sl.Element.Avatar.label`](Sl.Element.Avatar#label).
-}
avatarLabel : String -> Attr { c | label : Supported } msg
avatarLabel =
    Avatar_.label


{-| See [`Sl.Element.Avatar.onError`](Sl.Element.Avatar#onError).
-}
avatarOnError : msg -> Attr { c | onError : Supported } msg
avatarOnError =
    Avatar_.onError
