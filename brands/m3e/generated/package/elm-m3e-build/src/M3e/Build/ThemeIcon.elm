module M3e.Build.ThemeIcon exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withColor, withId, withScheme, withSlot, withStyle, withVariant)

{-| The **ThemeIcon** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.ThemeIcon`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withColor, withId, withScheme, withSlot, withStyle, withVariant

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.ThemeIcon as Component
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.ThemeIconIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.ThemeIconBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.ThemeIconAttrCaps


{-| -}
type alias SlotCaps =
    Component.ThemeIconSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ThemeIconChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-theme-icon" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.ThemeIconIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
withClass : String -> Builder { a | class : Available } slotCaps msg kind -> Builder { a | class : Used } slotCaps msg kind
withClass value_ =
    B.withAttribute (A.class value_)


{-| -}
withId : String -> Builder { a | id : Available } slotCaps msg kind -> Builder { a | id : Used } slotCaps msg kind
withId value_ =
    B.withAttribute (A.id value_)


{-| -}
withSlot : String -> Builder { a | slot : Available } slotCaps msg kind -> Builder { a | slot : Used } slotCaps msg kind
withSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
withStyle : String -> String -> Builder { a | style : Available } slotCaps msg kind -> Builder { a | style : Used } slotCaps msg kind
withStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
withColor : String -> Builder { a | color : Available } slotCaps msg kind -> Builder { a | color : Used } slotCaps msg kind
withColor value_ =
    B.withAttribute (A.color value_)


{-| -}
withScheme : Value Component.ThemeIconScheme -> Builder { a | scheme : Available } slotCaps msg kind -> Builder { a | scheme : Used } slotCaps msg kind
withScheme value_ =
    B.withAttribute (Component.themeIconScheme value_)


{-| -}
withVariant : Value Component.ThemeIconVariant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.themeIconVariant value_)
