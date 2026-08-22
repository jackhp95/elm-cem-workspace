module Mini.Component.Chip exposing (ChipIs, ChipAttrs, ChipBuilder, ChipAttrCaps, ChipSlotCaps, ChipContent, ChipChildAdmittedBy, ChipSize, chip, chipSize, chipDisabled, chipChild)

{-| The **Chip** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Mini.Element.Chip`](Mini.Element.Chip) as `chip`.

Prefer whichever import reads best — the flat `Mini.Element.*` modules and
this family module are the same elements, same types.

@docs ChipIs, ChipAttrs, ChipBuilder, ChipAttrCaps, ChipSlotCaps, ChipContent, ChipChildAdmittedBy, ChipSize, chip, chipSize, chipDisabled, chipChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Mini.Element.Chip as Chip_


{-| The `chip` element of this family — delegates to [`Mini.Element.Chip.component`](Mini.Element.Chip#component).
-}
chip :
    List (Attr ChipAttrs msg)
    -> List (Element ChipContent (ChipChildAdmittedBy childAdm) msg)
    -> Element (ChipIs s) admittedBy msg
chip =
    Chip_.component


{-| See [`Mini.Element.Chip.Is`](Mini.Element.Chip#Is).
-}
type alias ChipIs s =
    Chip_.Is s


{-| See [`Mini.Element.Chip.Attrs`](Mini.Element.Chip#Attrs).
-}
type alias ChipAttrs =
    Chip_.Attrs


{-| See [`Mini.Element.Chip.Builder`](Mini.Element.Chip#Builder).
-}
type alias ChipBuilder attrCaps slotCaps msg kind =
    Chip_.Builder attrCaps slotCaps msg kind


{-| See [`Mini.Element.Chip.AttrCaps`](Mini.Element.Chip#AttrCaps).
-}
type alias ChipAttrCaps =
    Chip_.AttrCaps


{-| See [`Mini.Element.Chip.SlotCaps`](Mini.Element.Chip#SlotCaps).
-}
type alias ChipSlotCaps =
    Chip_.SlotCaps


{-| See [`Mini.Element.Chip.Content`](Mini.Element.Chip#Content).
-}
type alias ChipContent =
    Chip_.Content


{-| See [`Mini.Element.Chip.ChildAdmittedBy`](Mini.Element.Chip#ChildAdmittedBy).
-}
type alias ChipChildAdmittedBy childAdm =
    Chip_.ChildAdmittedBy childAdm


{-| See [`Mini.Element.Chip.Size`](Mini.Element.Chip#Size).
-}
type alias ChipSize =
    Chip_.Size


{-| See [`Mini.Element.Chip.size`](Mini.Element.Chip#size).
-}
chipSize : Value ChipSize -> Attr { c | size : Supported } msg
chipSize =
    Chip_.size


{-| See [`Mini.Element.Chip.disabled`](Mini.Element.Chip#disabled).
-}
chipDisabled : Bool -> Attr { c | disabled : Supported } msg
chipDisabled =
    Chip_.disabled


{-| See [`Mini.Element.Chip.child`](Mini.Element.Chip#child).
-}
chipChild : Element ChipContent admittedBy msg -> Element free freeAdmittedBy msg
chipChild =
    Chip_.child
