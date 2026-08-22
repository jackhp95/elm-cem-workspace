module M3e.Build.FloatingPanel exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withAnchorOffset, withClass, withFitAnchorWidth, withId, withOnBeforetoggle, withOnToggle, withScrollStrategy, withSlot, withStyle, withChild)

{-| The **FloatingPanel** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.FloatingPanel`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withAnchorOffset, withClass, withFitAnchorWidth, withId, withOnBeforetoggle, withOnToggle, withScrollStrategy, withSlot, withStyle, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.FloatingPanel as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.FloatingPanelIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.FloatingPanelBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.FloatingPanelAttrCaps


{-| -}
type alias SlotCaps =
    Component.FloatingPanelSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.FloatingPanelChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-floating-panel" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.FloatingPanelIs kind) admittedBy msg
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
withAnchorOffset : Float -> Builder { a | anchorOffset : Available } slotCaps msg kind -> Builder { a | anchorOffset : Used } slotCaps msg kind
withAnchorOffset value_ =
    B.withAttribute (A.anchorOffset value_)


{-| -}
withFitAnchorWidth : Bool -> Builder { a | fitAnchorWidth : Available } slotCaps msg kind -> Builder { a | fitAnchorWidth : Used } slotCaps msg kind
withFitAnchorWidth value_ =
    B.withAttribute (A.fitAnchorWidth value_)


{-| -}
withScrollStrategy : Value Component.FloatingPanelScrollStrategy -> Builder { a | scrollStrategy : Available } slotCaps msg kind -> Builder { a | scrollStrategy : Used } slotCaps msg kind
withScrollStrategy value_ =
    B.withAttribute (Component.floatingPanelScrollStrategy value_)


{-| -}
withOnBeforetoggle : msg -> Builder { a | onBeforetoggle : Available } slotCaps msg kind -> Builder { a | onBeforetoggle : Used } slotCaps msg kind
withOnBeforetoggle value_ =
    B.withAttribute (Ev.onBeforetoggle value_)


{-| -}
withOnToggle : msg -> Builder { a | onToggle : Available } slotCaps msg kind -> Builder { a | onToggle : Used } slotCaps msg kind
withOnToggle value_ =
    B.withAttribute (Ev.onToggle value_)
