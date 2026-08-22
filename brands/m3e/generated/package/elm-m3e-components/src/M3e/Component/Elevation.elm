module M3e.Component.Elevation exposing (ElevationIs, ElevationAttrs, ElevationBuilder, ElevationAttrCaps, ElevationSlotCaps, ElevationChildAdmittedBy, elevation, elevationDisabled, elevationFor, elevationLevel)

{-| The **Elevation** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Elevation`](M3e.Element.Elevation) as `elevation`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ElevationIs, ElevationAttrs, ElevationBuilder, ElevationAttrCaps, ElevationSlotCaps, ElevationChildAdmittedBy, elevation, elevationDisabled, elevationFor, elevationLevel

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.Elevation as Elevation_


{-| The `elevation` element of this family — delegates to [`M3e.Element.Elevation.component`](M3e.Element.Elevation#component).
-}
elevation :
    List (Attr ElevationAttrs msg)
    -> List (Element childAccepts (ElevationChildAdmittedBy childAdm) msg)
    -> Element (ElevationIs s) admittedBy msg
elevation =
    Elevation_.component


{-| See [`M3e.Element.Elevation.Is`](M3e.Element.Elevation#Is).
-}
type alias ElevationIs s =
    Elevation_.Is s


{-| See [`M3e.Element.Elevation.Attrs`](M3e.Element.Elevation#Attrs).
-}
type alias ElevationAttrs =
    Elevation_.Attrs


{-| See [`M3e.Element.Elevation.Builder`](M3e.Element.Elevation#Builder).
-}
type alias ElevationBuilder attrCaps slotCaps msg kind =
    Elevation_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Elevation.AttrCaps`](M3e.Element.Elevation#AttrCaps).
-}
type alias ElevationAttrCaps =
    Elevation_.AttrCaps


{-| See [`M3e.Element.Elevation.SlotCaps`](M3e.Element.Elevation#SlotCaps).
-}
type alias ElevationSlotCaps =
    Elevation_.SlotCaps


{-| See [`M3e.Element.Elevation.ChildAdmittedBy`](M3e.Element.Elevation#ChildAdmittedBy).
-}
type alias ElevationChildAdmittedBy childAdm =
    Elevation_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Elevation.disabled`](M3e.Element.Elevation#disabled).
-}
elevationDisabled : Bool -> Attr { c | disabled : Supported } msg
elevationDisabled =
    Elevation_.disabled


{-| See [`M3e.Element.Elevation.for`](M3e.Element.Elevation#for).
-}
elevationFor : String -> Attr { c | for : Supported } msg
elevationFor =
    Elevation_.for


{-| See [`M3e.Element.Elevation.level`](M3e.Element.Elevation#level).
-}
elevationLevel : Int -> Attr { c | level : Supported } msg
elevationLevel =
    Elevation_.level
