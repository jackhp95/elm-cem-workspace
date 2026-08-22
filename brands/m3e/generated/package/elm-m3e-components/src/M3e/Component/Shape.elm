module M3e.Component.Shape exposing (ShapeIs, ShapeAttrs, ShapeBuilder, ShapeAttrCaps, ShapeSlotCaps, ShapeChildAdmittedBy, ShapeName, shape, shapeName, shapeChild)

{-| The **Shape** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Shape`](M3e.Element.Shape) as `shape`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ShapeIs, ShapeAttrs, ShapeBuilder, ShapeAttrCaps, ShapeSlotCaps, ShapeChildAdmittedBy, ShapeName, shape, shapeName, shapeChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Shape as Shape_


{-| The `shape` element of this family — delegates to [`M3e.Element.Shape.component`](M3e.Element.Shape#component).
-}
shape :
    List (Attr ShapeAttrs msg)
    -> List (Element childAccepts (ShapeChildAdmittedBy childAdm) msg)
    -> Element (ShapeIs s) admittedBy msg
shape =
    Shape_.component


{-| See [`M3e.Element.Shape.Is`](M3e.Element.Shape#Is).
-}
type alias ShapeIs s =
    Shape_.Is s


{-| See [`M3e.Element.Shape.Attrs`](M3e.Element.Shape#Attrs).
-}
type alias ShapeAttrs =
    Shape_.Attrs


{-| See [`M3e.Element.Shape.Builder`](M3e.Element.Shape#Builder).
-}
type alias ShapeBuilder attrCaps slotCaps msg kind =
    Shape_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Shape.AttrCaps`](M3e.Element.Shape#AttrCaps).
-}
type alias ShapeAttrCaps =
    Shape_.AttrCaps


{-| See [`M3e.Element.Shape.SlotCaps`](M3e.Element.Shape#SlotCaps).
-}
type alias ShapeSlotCaps =
    Shape_.SlotCaps


{-| See [`M3e.Element.Shape.ChildAdmittedBy`](M3e.Element.Shape#ChildAdmittedBy).
-}
type alias ShapeChildAdmittedBy childAdm =
    Shape_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Shape.Name`](M3e.Element.Shape#Name).
-}
type alias ShapeName =
    Shape_.Name


{-| See [`M3e.Element.Shape.name`](M3e.Element.Shape#name).
-}
shapeName : Value ShapeName -> Attr { c | name : Supported } msg
shapeName =
    Shape_.name


{-| See [`M3e.Element.Shape.child`](M3e.Element.Shape#child).
-}
shapeChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
shapeChild =
    Shape_.child
