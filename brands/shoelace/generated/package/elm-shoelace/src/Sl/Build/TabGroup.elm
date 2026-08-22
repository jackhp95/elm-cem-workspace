module Sl.Build.TabGroup exposing (Builder, AttrCaps, SlotCaps, Is, Content, NavSlot, ChildAdmittedBy, build, toElement, withActivation, withClass, withFixedScrollControls, withId, withNoScrollControls, withOnTabHide, withOnTabShow, withPlacement, withSlot, withStyle, nav, withNav, withChild)

{-| The **TabGroup** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.TabGroup`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, NavSlot, ChildAdmittedBy, build, toElement, withActivation, withClass, withFixedScrollControls, withId, withNoScrollControls, withOnTabHide, withOnTabShow, withPlacement, withSlot, withStyle, nav, withNav, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.TabGroup as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.TabGroupIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.TabGroupBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.TabGroupAttrCaps


{-| -}
type alias SlotCaps =
    Component.TabGroupSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.TabGroupChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.TabGroupContent


{-| -}
type alias NavSlot =
    Component.TabGroupNavSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-tab-group" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.TabGroupIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
nav :
    B.Builder childRow childAttrCaps childSlotCaps Component.TabGroupNavSlot msg
    -> Element free freeAdmittedBy msg
nav builder =
    Component.tabGroupNav (B.toElement builder)


{-| -}
withNav :
    B.Builder childRow childAttrCaps childSlotCaps Component.TabGroupNavSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withNav slotBuilder builder_ =
    B.withChild (El.toNode (Component.tabGroupNav (B.toElement slotBuilder))) builder_


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
withActivation : Value Component.TabGroupActivation -> Builder { a | activation : Available } slotCaps msg kind -> Builder { a | activation : Used } slotCaps msg kind
withActivation value_ =
    B.withAttribute (Component.tabGroupActivation value_)


{-| -}
withFixedScrollControls : Bool -> Builder { a | fixedScrollControls : Available } slotCaps msg kind -> Builder { a | fixedScrollControls : Used } slotCaps msg kind
withFixedScrollControls value_ =
    B.withAttribute (A.fixedScrollControls value_)


{-| -}
withNoScrollControls : Bool -> Builder { a | noScrollControls : Available } slotCaps msg kind -> Builder { a | noScrollControls : Used } slotCaps msg kind
withNoScrollControls value_ =
    B.withAttribute (A.noScrollControls value_)


{-| -}
withPlacement : Value Component.TabGroupPlacement -> Builder { a | placement : Available } slotCaps msg kind -> Builder { a | placement : Used } slotCaps msg kind
withPlacement value_ =
    B.withAttribute (Component.tabGroupPlacement value_)


{-| -}
withOnTabShow : msg -> Builder { a | onTabShow : Available } slotCaps msg kind -> Builder { a | onTabShow : Used } slotCaps msg kind
withOnTabShow value_ =
    B.withAttribute (Ev.onTabShow value_)


{-| -}
withOnTabHide : msg -> Builder { a | onTabHide : Available } slotCaps msg kind -> Builder { a | onTabHide : Used } slotCaps msg kind
withOnTabHide value_ =
    B.withAttribute (Ev.onTabHide value_)
