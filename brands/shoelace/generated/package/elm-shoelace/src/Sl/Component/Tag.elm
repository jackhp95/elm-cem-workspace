module Sl.Component.Tag exposing (TagIs, TagAttrs, TagBuilder, TagAttrCaps, TagSlotCaps, TagChildAdmittedBy, TagSize, TagVariant, tag, tagSize, tagVariant, tagPill, tagRemovable, tagOnRemove)

{-| The **Tag** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Tag`](Sl.Element.Tag) as `tag`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs TagIs, TagAttrs, TagBuilder, TagAttrCaps, TagSlotCaps, TagChildAdmittedBy, TagSize, TagVariant, tag, tagSize, tagVariant, tagPill, tagRemovable, tagOnRemove

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Tag as Tag_


{-| The `tag` element of this family — delegates to [`Sl.Element.Tag.component`](Sl.Element.Tag#component).
-}
tag :
    List (Attr TagAttrs msg)
    -> List (Element childAccepts (TagChildAdmittedBy childAdm) msg)
    -> Element (TagIs s) admittedBy msg
tag =
    Tag_.component


{-| See [`Sl.Element.Tag.Is`](Sl.Element.Tag#Is).
-}
type alias TagIs s =
    Tag_.Is s


{-| See [`Sl.Element.Tag.Attrs`](Sl.Element.Tag#Attrs).
-}
type alias TagAttrs =
    Tag_.Attrs


{-| See [`Sl.Element.Tag.Builder`](Sl.Element.Tag#Builder).
-}
type alias TagBuilder attrCaps slotCaps msg kind =
    Tag_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Tag.AttrCaps`](Sl.Element.Tag#AttrCaps).
-}
type alias TagAttrCaps =
    Tag_.AttrCaps


{-| See [`Sl.Element.Tag.SlotCaps`](Sl.Element.Tag#SlotCaps).
-}
type alias TagSlotCaps =
    Tag_.SlotCaps


{-| See [`Sl.Element.Tag.ChildAdmittedBy`](Sl.Element.Tag#ChildAdmittedBy).
-}
type alias TagChildAdmittedBy childAdm =
    Tag_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Tag.Size`](Sl.Element.Tag#Size).
-}
type alias TagSize =
    Tag_.Size


{-| See [`Sl.Element.Tag.size`](Sl.Element.Tag#size).
-}
tagSize : Value TagSize -> Attr { c | size : Supported } msg
tagSize =
    Tag_.size


{-| See [`Sl.Element.Tag.Variant`](Sl.Element.Tag#Variant).
-}
type alias TagVariant =
    Tag_.Variant


{-| See [`Sl.Element.Tag.variant`](Sl.Element.Tag#variant).
-}
tagVariant : Value TagVariant -> Attr { c | variant : Supported } msg
tagVariant =
    Tag_.variant


{-| See [`Sl.Element.Tag.pill`](Sl.Element.Tag#pill).
-}
tagPill : Bool -> Attr { c | pill : Supported } msg
tagPill =
    Tag_.pill


{-| See [`Sl.Element.Tag.removable`](Sl.Element.Tag#removable).
-}
tagRemovable : Bool -> Attr { c | removable : Supported } msg
tagRemovable =
    Tag_.removable


{-| See [`Sl.Element.Tag.onRemove`](Sl.Element.Tag#onRemove).
-}
tagOnRemove : msg -> Attr { c | onRemove : Supported } msg
tagOnRemove =
    Tag_.onRemove
