module M3e.Component.Icon exposing (IconIs, IconAttrs, IconBuilder, IconAttrCaps, IconSlotCaps, IconChildAdmittedBy, IconGrade, IconVariant, icon, iconGrade, iconVariant, iconFilled, iconName, iconOpticalSize, iconWeight)

{-| The **Icon** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Icon`](M3e.Element.Icon) as `icon`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs IconIs, IconAttrs, IconBuilder, IconAttrCaps, IconSlotCaps, IconChildAdmittedBy, IconGrade, IconVariant, icon, iconGrade, iconVariant, iconFilled, iconName, iconOpticalSize, iconWeight

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Icon as Icon_


{-| The `icon` element of this family — delegates to [`M3e.Element.Icon.component`](M3e.Element.Icon#component).
-}
icon :
    List (Attr IconAttrs msg)
    -> List (Element childAccepts (IconChildAdmittedBy childAdm) msg)
    -> Element (IconIs s) admittedBy msg
icon =
    Icon_.component


{-| See [`M3e.Element.Icon.Is`](M3e.Element.Icon#Is).
-}
type alias IconIs s =
    Icon_.Is s


{-| See [`M3e.Element.Icon.Attrs`](M3e.Element.Icon#Attrs).
-}
type alias IconAttrs =
    Icon_.Attrs


{-| See [`M3e.Element.Icon.Builder`](M3e.Element.Icon#Builder).
-}
type alias IconBuilder attrCaps slotCaps msg kind =
    Icon_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Icon.AttrCaps`](M3e.Element.Icon#AttrCaps).
-}
type alias IconAttrCaps =
    Icon_.AttrCaps


{-| See [`M3e.Element.Icon.SlotCaps`](M3e.Element.Icon#SlotCaps).
-}
type alias IconSlotCaps =
    Icon_.SlotCaps


{-| See [`M3e.Element.Icon.ChildAdmittedBy`](M3e.Element.Icon#ChildAdmittedBy).
-}
type alias IconChildAdmittedBy childAdm =
    Icon_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Icon.Grade`](M3e.Element.Icon#Grade).
-}
type alias IconGrade =
    Icon_.Grade


{-| See [`M3e.Element.Icon.grade`](M3e.Element.Icon#grade).
-}
iconGrade : Value IconGrade -> Attr { c | grade : Supported } msg
iconGrade =
    Icon_.grade


{-| See [`M3e.Element.Icon.Variant`](M3e.Element.Icon#Variant).
-}
type alias IconVariant =
    Icon_.Variant


{-| See [`M3e.Element.Icon.variant`](M3e.Element.Icon#variant).
-}
iconVariant : Value IconVariant -> Attr { c | variant : Supported } msg
iconVariant =
    Icon_.variant


{-| See [`M3e.Element.Icon.filled`](M3e.Element.Icon#filled).
-}
iconFilled : Bool -> Attr { c | filled : Supported } msg
iconFilled =
    Icon_.filled


{-| See [`M3e.Element.Icon.name`](M3e.Element.Icon#name).
-}
iconName : String -> Attr { c | name : Supported } msg
iconName =
    Icon_.name


{-| See [`M3e.Element.Icon.opticalSize`](M3e.Element.Icon#opticalSize).
-}
iconOpticalSize : Float -> Attr { c | opticalSize : Supported } msg
iconOpticalSize =
    Icon_.opticalSize


{-| See [`M3e.Element.Icon.weight`](M3e.Element.Icon#weight).
-}
iconWeight : Int -> Attr { c | weight : Supported } msg
iconWeight =
    Icon_.weight
