module M3e.Component.ThemeIcon exposing (ThemeIconIs, ThemeIconAttrs, ThemeIconBuilder, ThemeIconAttrCaps, ThemeIconSlotCaps, ThemeIconChildAdmittedBy, ThemeIconScheme, ThemeIconVariant, themeIcon, themeIconScheme, themeIconVariant, themeIconColor)

{-| The **ThemeIcon** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.ThemeIcon`](M3e.Element.ThemeIcon) as `themeIcon`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ThemeIconIs, ThemeIconAttrs, ThemeIconBuilder, ThemeIconAttrCaps, ThemeIconSlotCaps, ThemeIconChildAdmittedBy, ThemeIconScheme, ThemeIconVariant, themeIcon, themeIconScheme, themeIconVariant, themeIconColor

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.ThemeIcon as ThemeIcon_


{-| The `themeIcon` element of this family — delegates to [`M3e.Element.ThemeIcon.component`](M3e.Element.ThemeIcon#component).
-}
themeIcon :
    List (Attr ThemeIconAttrs msg)
    -> List (Element childAccepts (ThemeIconChildAdmittedBy childAdm) msg)
    -> Element (ThemeIconIs s) admittedBy msg
themeIcon =
    ThemeIcon_.component


{-| See [`M3e.Element.ThemeIcon.Is`](M3e.Element.ThemeIcon#Is).
-}
type alias ThemeIconIs s =
    ThemeIcon_.Is s


{-| See [`M3e.Element.ThemeIcon.Attrs`](M3e.Element.ThemeIcon#Attrs).
-}
type alias ThemeIconAttrs =
    ThemeIcon_.Attrs


{-| See [`M3e.Element.ThemeIcon.Builder`](M3e.Element.ThemeIcon#Builder).
-}
type alias ThemeIconBuilder attrCaps slotCaps msg kind =
    ThemeIcon_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.ThemeIcon.AttrCaps`](M3e.Element.ThemeIcon#AttrCaps).
-}
type alias ThemeIconAttrCaps =
    ThemeIcon_.AttrCaps


{-| See [`M3e.Element.ThemeIcon.SlotCaps`](M3e.Element.ThemeIcon#SlotCaps).
-}
type alias ThemeIconSlotCaps =
    ThemeIcon_.SlotCaps


{-| See [`M3e.Element.ThemeIcon.ChildAdmittedBy`](M3e.Element.ThemeIcon#ChildAdmittedBy).
-}
type alias ThemeIconChildAdmittedBy childAdm =
    ThemeIcon_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.ThemeIcon.Scheme`](M3e.Element.ThemeIcon#Scheme).
-}
type alias ThemeIconScheme =
    ThemeIcon_.Scheme


{-| See [`M3e.Element.ThemeIcon.scheme`](M3e.Element.ThemeIcon#scheme).
-}
themeIconScheme : Value ThemeIconScheme -> Attr { c | scheme : Supported } msg
themeIconScheme =
    ThemeIcon_.scheme


{-| See [`M3e.Element.ThemeIcon.Variant`](M3e.Element.ThemeIcon#Variant).
-}
type alias ThemeIconVariant =
    ThemeIcon_.Variant


{-| See [`M3e.Element.ThemeIcon.variant`](M3e.Element.ThemeIcon#variant).
-}
themeIconVariant : Value ThemeIconVariant -> Attr { c | variant : Supported } msg
themeIconVariant =
    ThemeIcon_.variant


{-| See [`M3e.Element.ThemeIcon.color`](M3e.Element.ThemeIcon#color).
-}
themeIconColor : String -> Attr { c | color : Supported } msg
themeIconColor =
    ThemeIcon_.color
