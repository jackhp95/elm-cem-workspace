module M3e.Component.Theme exposing (ThemeIs, ThemeAttrs, ThemeBuilder, ThemeAttrCaps, ThemeSlotCaps, ThemeChildAdmittedBy, ThemeContrast, ThemeMotion, ThemeScheme, ThemeVariant, theme, themeContrast, themeMotion, themeScheme, themeVariant, themeColor, themeDensity, themeStrongFocus, themeOnChange, themeChild)

{-| The **Theme** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Theme`](M3e.Element.Theme) as `theme`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ThemeIs, ThemeAttrs, ThemeBuilder, ThemeAttrCaps, ThemeSlotCaps, ThemeChildAdmittedBy, ThemeContrast, ThemeMotion, ThemeScheme, ThemeVariant, theme, themeContrast, themeMotion, themeScheme, themeVariant, themeColor, themeDensity, themeStrongFocus, themeOnChange, themeChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Theme as Theme_


{-| The `theme` element of this family — delegates to [`M3e.Element.Theme.component`](M3e.Element.Theme#component).
-}
theme :
    List (Attr ThemeAttrs msg)
    -> List (Element childAccepts (ThemeChildAdmittedBy childAdm) msg)
    -> Element (ThemeIs s) admittedBy msg
theme =
    Theme_.component


{-| See [`M3e.Element.Theme.Is`](M3e.Element.Theme#Is).
-}
type alias ThemeIs s =
    Theme_.Is s


{-| See [`M3e.Element.Theme.Attrs`](M3e.Element.Theme#Attrs).
-}
type alias ThemeAttrs =
    Theme_.Attrs


{-| See [`M3e.Element.Theme.Builder`](M3e.Element.Theme#Builder).
-}
type alias ThemeBuilder attrCaps slotCaps msg kind =
    Theme_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Theme.AttrCaps`](M3e.Element.Theme#AttrCaps).
-}
type alias ThemeAttrCaps =
    Theme_.AttrCaps


{-| See [`M3e.Element.Theme.SlotCaps`](M3e.Element.Theme#SlotCaps).
-}
type alias ThemeSlotCaps =
    Theme_.SlotCaps


{-| See [`M3e.Element.Theme.ChildAdmittedBy`](M3e.Element.Theme#ChildAdmittedBy).
-}
type alias ThemeChildAdmittedBy childAdm =
    Theme_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Theme.Contrast`](M3e.Element.Theme#Contrast).
-}
type alias ThemeContrast =
    Theme_.Contrast


{-| See [`M3e.Element.Theme.contrast`](M3e.Element.Theme#contrast).
-}
themeContrast : Value ThemeContrast -> Attr { c | contrast : Supported } msg
themeContrast =
    Theme_.contrast


{-| See [`M3e.Element.Theme.Motion`](M3e.Element.Theme#Motion).
-}
type alias ThemeMotion =
    Theme_.Motion


{-| See [`M3e.Element.Theme.motion`](M3e.Element.Theme#motion).
-}
themeMotion : Value ThemeMotion -> Attr { c | motion : Supported } msg
themeMotion =
    Theme_.motion


{-| See [`M3e.Element.Theme.Scheme`](M3e.Element.Theme#Scheme).
-}
type alias ThemeScheme =
    Theme_.Scheme


{-| See [`M3e.Element.Theme.scheme`](M3e.Element.Theme#scheme).
-}
themeScheme : Value ThemeScheme -> Attr { c | scheme : Supported } msg
themeScheme =
    Theme_.scheme


{-| See [`M3e.Element.Theme.Variant`](M3e.Element.Theme#Variant).
-}
type alias ThemeVariant =
    Theme_.Variant


{-| See [`M3e.Element.Theme.variant`](M3e.Element.Theme#variant).
-}
themeVariant : Value ThemeVariant -> Attr { c | variant : Supported } msg
themeVariant =
    Theme_.variant


{-| See [`M3e.Element.Theme.color`](M3e.Element.Theme#color).
-}
themeColor : String -> Attr { c | color : Supported } msg
themeColor =
    Theme_.color


{-| See [`M3e.Element.Theme.density`](M3e.Element.Theme#density).
-}
themeDensity : Float -> Attr { c | density : Supported } msg
themeDensity =
    Theme_.density


{-| See [`M3e.Element.Theme.strongFocus`](M3e.Element.Theme#strongFocus).
-}
themeStrongFocus : Bool -> Attr { c | strongFocus : Supported } msg
themeStrongFocus =
    Theme_.strongFocus


{-| See [`M3e.Element.Theme.onChange`](M3e.Element.Theme#onChange).
-}
themeOnChange : msg -> Attr { c | onChange : Supported } msg
themeOnChange =
    Theme_.onChange


{-| See [`M3e.Element.Theme.child`](M3e.Element.Theme#child).
-}
themeChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
themeChild =
    Theme_.child
