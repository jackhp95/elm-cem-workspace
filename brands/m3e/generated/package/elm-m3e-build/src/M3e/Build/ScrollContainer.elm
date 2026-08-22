module M3e.Build.ScrollContainer exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDividers, withId, withSlot, withStyle, withThin, withChild)

{-| The **ScrollContainer** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.ScrollContainer`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDividers, withId, withSlot, withStyle, withThin, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.ScrollContainer as Component
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.ScrollContainerIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.ScrollContainerBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.ScrollContainerAttrCaps


{-| -}
type alias SlotCaps =
    Component.ScrollContainerSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ScrollContainerChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-scroll-container" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.ScrollContainerIs kind) admittedBy msg
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
withDividers : Value Component.ScrollContainerDividers -> Builder { a | dividers : Available } slotCaps msg kind -> Builder { a | dividers : Used } slotCaps msg kind
withDividers value_ =
    B.withAttribute (Component.scrollContainerDividers value_)


{-| -}
withThin : Bool -> Builder { a | thin : Available } slotCaps msg kind -> Builder { a | thin : Used } slotCaps msg kind
withThin value_ =
    B.withAttribute (A.thin value_)
