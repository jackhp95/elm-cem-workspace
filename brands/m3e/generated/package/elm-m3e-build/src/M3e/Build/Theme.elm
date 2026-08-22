module M3e.Build.Theme exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withColor, withContrast, withDensity, withId, withMotion, withOnChange, withScheme, withSlot, withStrongFocus, withStyle, withVariant, withChild)

{-| The **Theme** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.Theme`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withColor, withContrast, withDensity, withId, withMotion, withOnChange, withScheme, withSlot, withStrongFocus, withStyle, withVariant, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Theme as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.ThemeIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.ThemeBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.ThemeAttrCaps


{-| -}
type alias SlotCaps =
    Component.ThemeSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ThemeChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-theme" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.ThemeIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
withChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


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
withContrast : Value Component.ThemeContrast -> Builder { a | contrast : Available } slotCaps msg kind -> Builder { a | contrast : Used } slotCaps msg kind
withContrast value_ =
    B.withAttribute (Component.themeContrast value_)


{-| -}
withDensity : Float -> Builder { a | density : Available } slotCaps msg kind -> Builder { a | density : Used } slotCaps msg kind
withDensity value_ =
    B.withAttribute (A.density value_)


{-| -}
withMotion : Value Component.ThemeMotion -> Builder { a | motion : Available } slotCaps msg kind -> Builder { a | motion : Used } slotCaps msg kind
withMotion value_ =
    B.withAttribute (Component.themeMotion value_)


{-| -}
withScheme : Value Component.ThemeScheme -> Builder { a | scheme : Available } slotCaps msg kind -> Builder { a | scheme : Used } slotCaps msg kind
withScheme value_ =
    B.withAttribute (Component.themeScheme value_)


{-| -}
withStrongFocus : Bool -> Builder { a | strongFocus : Available } slotCaps msg kind -> Builder { a | strongFocus : Used } slotCaps msg kind
withStrongFocus value_ =
    B.withAttribute (A.strongFocus value_)


{-| -}
withVariant : Value Component.ThemeVariant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.themeVariant value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)
