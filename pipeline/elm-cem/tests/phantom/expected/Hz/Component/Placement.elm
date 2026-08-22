module Hz.Component.Placement exposing (PlacementIs, PlacementAttrs, PlacementBuilder, PlacementAttrCaps, PlacementSlotCaps, PlacementContent, PlacementChildAdmittedBy, PlacementPosition, placement, placementPosition, placementChild)

{-| The **Placement** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Hz.Element.Placement`](Hz.Element.Placement) as `placement`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs PlacementIs, PlacementAttrs, PlacementBuilder, PlacementAttrCaps, PlacementSlotCaps, PlacementContent, PlacementChildAdmittedBy, PlacementPosition, placement, placementPosition, placementChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Hz.Element.Placement as Placement_


{-| The `placement` element of this family — delegates to [`Hz.Element.Placement.component`](Hz.Element.Placement#component).
-}
placement :
    List (Attr PlacementAttrs msg)
    -> List (Element PlacementContent (PlacementChildAdmittedBy childAdm) msg)
    -> Element (PlacementIs s) admittedBy msg
placement =
    Placement_.component


{-| See [`Hz.Element.Placement.Is`](Hz.Element.Placement#Is).
-}
type alias PlacementIs s =
    Placement_.Is s


{-| See [`Hz.Element.Placement.Attrs`](Hz.Element.Placement#Attrs).
-}
type alias PlacementAttrs =
    Placement_.Attrs


{-| See [`Hz.Element.Placement.Builder`](Hz.Element.Placement#Builder).
-}
type alias PlacementBuilder attrCaps slotCaps msg kind =
    Placement_.Builder attrCaps slotCaps msg kind


{-| See [`Hz.Element.Placement.AttrCaps`](Hz.Element.Placement#AttrCaps).
-}
type alias PlacementAttrCaps =
    Placement_.AttrCaps


{-| See [`Hz.Element.Placement.SlotCaps`](Hz.Element.Placement#SlotCaps).
-}
type alias PlacementSlotCaps =
    Placement_.SlotCaps


{-| See [`Hz.Element.Placement.Content`](Hz.Element.Placement#Content).
-}
type alias PlacementContent =
    Placement_.Content


{-| See [`Hz.Element.Placement.ChildAdmittedBy`](Hz.Element.Placement#ChildAdmittedBy).
-}
type alias PlacementChildAdmittedBy childAdm =
    Placement_.ChildAdmittedBy childAdm


{-| See [`Hz.Element.Placement.Position`](Hz.Element.Placement#Position).
-}
type alias PlacementPosition =
    Placement_.Position


{-| See [`Hz.Element.Placement.position`](Hz.Element.Placement#position).
-}
placementPosition : Value PlacementPosition -> Attr { c | position : Supported } msg
placementPosition =
    Placement_.position


{-| See [`Hz.Element.Placement.child`](Hz.Element.Placement#child).
-}
placementChild : Element PlacementContent admittedBy msg -> Element free freeAdmittedBy msg
placementChild =
    Placement_.child
