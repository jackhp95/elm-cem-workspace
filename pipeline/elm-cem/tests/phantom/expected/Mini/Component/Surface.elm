module Mini.Component.Surface exposing (SurfaceIs, SurfaceAttrs, SurfaceBuilder, SurfaceAttrCaps, SurfaceSlotCaps, SurfaceChildAdmittedBy, surface, surfaceGrid, surfaceGridAsInts, surfaceChild)

{-| The **Surface** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Mini.Element.Surface`](Mini.Element.Surface) as `surface`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SurfaceIs, SurfaceAttrs, SurfaceBuilder, SurfaceAttrCaps, SurfaceSlotCaps, SurfaceChildAdmittedBy, surface, surfaceGrid, surfaceGridAsInts, surfaceChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Mini.Element.Surface as Surface_


{-| The `surface` element of this family — delegates to [`Mini.Element.Surface.component`](Mini.Element.Surface#component).
-}
surface :
    List (Attr SurfaceAttrs msg)
    -> List (Element childAccepts (SurfaceChildAdmittedBy childAdm) msg)
    -> Element (SurfaceIs s) admittedBy msg
surface =
    Surface_.component


{-| See [`Mini.Element.Surface.Is`](Mini.Element.Surface#Is).
-}
type alias SurfaceIs s =
    Surface_.Is s


{-| See [`Mini.Element.Surface.Attrs`](Mini.Element.Surface#Attrs).
-}
type alias SurfaceAttrs =
    Surface_.Attrs


{-| See [`Mini.Element.Surface.Builder`](Mini.Element.Surface#Builder).
-}
type alias SurfaceBuilder attrCaps slotCaps msg kind =
    Surface_.Builder attrCaps slotCaps msg kind


{-| See [`Mini.Element.Surface.AttrCaps`](Mini.Element.Surface#AttrCaps).
-}
type alias SurfaceAttrCaps =
    Surface_.AttrCaps


{-| See [`Mini.Element.Surface.SlotCaps`](Mini.Element.Surface#SlotCaps).
-}
type alias SurfaceSlotCaps =
    Surface_.SlotCaps


{-| See [`Mini.Element.Surface.ChildAdmittedBy`](Mini.Element.Surface#ChildAdmittedBy).
-}
type alias SurfaceChildAdmittedBy childAdm =
    Surface_.ChildAdmittedBy childAdm


{-| See [`Mini.Element.Surface.grid`](Mini.Element.Surface#grid).
-}
surfaceGrid : String -> Attr { c | grid : Supported } msg
surfaceGrid =
    Surface_.grid


{-| See [`Mini.Element.Surface.gridAsInts`](Mini.Element.Surface#gridAsInts).
-}
surfaceGridAsInts : List Int -> Attr { c | grid : Supported } msg
surfaceGridAsInts =
    Surface_.gridAsInts


{-| See [`Mini.Element.Surface.child`](Mini.Element.Surface#child).
-}
surfaceChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
surfaceChild =
    Surface_.child
