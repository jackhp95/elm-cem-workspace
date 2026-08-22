module M3e.Build.DrawerContainer exposing (DrawerContainerBuilder, DrawerContainerAttrCaps, DrawerContainerSlotCaps, DrawerContainerIs, DrawerContainerChildAdmittedBy, drawerContainerBuild, drawerContainerToElement, drawerContainerWithClass, drawerContainerWithEnd, drawerContainerWithEndDivider, drawerContainerWithEndMode, drawerContainerWithId, drawerContainerWithOnChange, drawerContainerWithSlot, drawerContainerWithStart, drawerContainerWithStartDivider, drawerContainerWithStartMode, drawerContainerWithStyle, drawerContainerEnd, drawerContainerStart, drawerContainerWithEndSlot, drawerContainerWithStartSlot, drawerContainerWithChild, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleIs, ToggleChildAdmittedBy, toggleBuild, toggleToElement, toggleWithClass, toggleWithFor, toggleWithId, toggleWithSlot, toggleWithStyle)

{-| The **DrawerContainer** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.DrawerContainer`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs DrawerContainerBuilder, DrawerContainerAttrCaps, DrawerContainerSlotCaps, DrawerContainerIs, DrawerContainerChildAdmittedBy, drawerContainerBuild, drawerContainerToElement, drawerContainerWithClass, drawerContainerWithEnd, drawerContainerWithEndDivider, drawerContainerWithEndMode, drawerContainerWithId, drawerContainerWithOnChange, drawerContainerWithSlot, drawerContainerWithStart, drawerContainerWithStartDivider, drawerContainerWithStartMode, drawerContainerWithStyle, drawerContainerEnd, drawerContainerStart, drawerContainerWithEndSlot, drawerContainerWithStartSlot, drawerContainerWithChild, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleIs, ToggleChildAdmittedBy, toggleBuild, toggleToElement, toggleWithClass, toggleWithFor, toggleWithId, toggleWithSlot, toggleWithStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.DrawerContainer as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias DrawerContainerIs s =
    Component.DrawerContainerIs s


{-| -}
type alias DrawerContainerBuilder attrCaps slotCaps msg kind =
    Component.DrawerContainerBuilder attrCaps slotCaps msg kind


{-| -}
type alias DrawerContainerAttrCaps =
    Component.DrawerContainerAttrCaps


{-| -}
type alias DrawerContainerSlotCaps =
    Component.DrawerContainerSlotCaps


{-| -}
type alias DrawerContainerChildAdmittedBy childAdm =
    Component.DrawerContainerChildAdmittedBy childAdm


{-| -}
drawerContainerBuild : DrawerContainerBuilder DrawerContainerAttrCaps DrawerContainerSlotCaps msg kind
drawerContainerBuild =
    B.init "m3e-drawer-container" [] []


{-| -}
drawerContainerToElement : DrawerContainerBuilder attrCaps slotCaps msg kind -> Element (Component.DrawerContainerIs kind) admittedBy msg
drawerContainerToElement =
    B.toElement


{-| -}
drawerContainerEnd :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
drawerContainerEnd builder =
    Component.drawerContainerEnd (B.toElement builder)


{-| -}
drawerContainerStart :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
drawerContainerStart builder =
    Component.drawerContainerStart (B.toElement builder)


{-| -}
drawerContainerWithEndSlot :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> DrawerContainerBuilder attrCaps { s | end : Available } msg kind
    -> DrawerContainerBuilder attrCaps { s | end : Used } msg kind
drawerContainerWithEndSlot slotBuilder builder_ =
    B.withChild (El.toNode (Component.drawerContainerEnd (B.toElement slotBuilder))) builder_


{-| -}
drawerContainerWithStartSlot :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> DrawerContainerBuilder attrCaps { s | start : Available } msg kind
    -> DrawerContainerBuilder attrCaps { s | start : Used } msg kind
drawerContainerWithStartSlot slotBuilder builder_ =
    B.withChild (El.toNode (Component.drawerContainerStart (B.toElement slotBuilder))) builder_


{-| -}
drawerContainerWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> DrawerContainerBuilder attrCaps slotCaps msg kind
    -> DrawerContainerBuilder attrCaps slotCaps msg kind
drawerContainerWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
drawerContainerWithClass : String -> DrawerContainerBuilder { a | class : Available } slotCaps msg kind -> DrawerContainerBuilder { a | class : Used } slotCaps msg kind
drawerContainerWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
drawerContainerWithId : String -> DrawerContainerBuilder { a | id : Available } slotCaps msg kind -> DrawerContainerBuilder { a | id : Used } slotCaps msg kind
drawerContainerWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
drawerContainerWithSlot : String -> DrawerContainerBuilder { a | slot : Available } slotCaps msg kind -> DrawerContainerBuilder { a | slot : Used } slotCaps msg kind
drawerContainerWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
drawerContainerWithStyle : String -> String -> DrawerContainerBuilder { a | style : Available } slotCaps msg kind -> DrawerContainerBuilder { a | style : Used } slotCaps msg kind
drawerContainerWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
drawerContainerWithEnd : Bool -> DrawerContainerBuilder { a | end : Available } slotCaps msg kind -> DrawerContainerBuilder { a | end : Used } slotCaps msg kind
drawerContainerWithEnd value_ =
    B.withAttribute (A.end value_)


{-| -}
drawerContainerWithEndDivider : Bool -> DrawerContainerBuilder { a | endDivider : Available } slotCaps msg kind -> DrawerContainerBuilder { a | endDivider : Used } slotCaps msg kind
drawerContainerWithEndDivider value_ =
    B.withAttribute (A.endDivider value_)


{-| -}
drawerContainerWithEndMode : Value Component.DrawerContainerEndMode -> DrawerContainerBuilder { a | endMode : Available } slotCaps msg kind -> DrawerContainerBuilder { a | endMode : Used } slotCaps msg kind
drawerContainerWithEndMode value_ =
    B.withAttribute (Component.drawerContainerEndMode value_)


{-| -}
drawerContainerWithStart : Bool -> DrawerContainerBuilder { a | start : Available } slotCaps msg kind -> DrawerContainerBuilder { a | start : Used } slotCaps msg kind
drawerContainerWithStart value_ =
    B.withAttribute (A.start value_)


{-| -}
drawerContainerWithStartDivider : Bool -> DrawerContainerBuilder { a | startDivider : Available } slotCaps msg kind -> DrawerContainerBuilder { a | startDivider : Used } slotCaps msg kind
drawerContainerWithStartDivider value_ =
    B.withAttribute (A.startDivider value_)


{-| -}
drawerContainerWithStartMode : Value Component.DrawerContainerStartMode -> DrawerContainerBuilder { a | startMode : Available } slotCaps msg kind -> DrawerContainerBuilder { a | startMode : Used } slotCaps msg kind
drawerContainerWithStartMode value_ =
    B.withAttribute (Component.drawerContainerStartMode value_)


{-| -}
drawerContainerWithOnChange : msg -> DrawerContainerBuilder { a | onChange : Available } slotCaps msg kind -> DrawerContainerBuilder { a | onChange : Used } slotCaps msg kind
drawerContainerWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
type alias ToggleIs s =
    Component.ToggleIs s


{-| -}
type alias ToggleBuilder attrCaps slotCaps msg kind =
    Component.ToggleBuilder attrCaps slotCaps msg kind


{-| -}
type alias ToggleAttrCaps =
    Component.ToggleAttrCaps


{-| -}
type alias ToggleSlotCaps =
    Component.ToggleSlotCaps


{-| -}
type alias ToggleChildAdmittedBy childAdm =
    Component.ToggleChildAdmittedBy childAdm


{-| -}
toggleBuild : ToggleBuilder ToggleAttrCaps ToggleSlotCaps msg kind
toggleBuild =
    B.init "m3e-drawer-toggle" [] []


{-| -}
toggleToElement : ToggleBuilder attrCaps slotCaps msg kind -> Element (Component.ToggleIs kind) admittedBy msg
toggleToElement =
    B.toElement


{-| -}
toggleWithClass : String -> ToggleBuilder { a | class : Available } slotCaps msg kind -> ToggleBuilder { a | class : Used } slotCaps msg kind
toggleWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
toggleWithId : String -> ToggleBuilder { a | id : Available } slotCaps msg kind -> ToggleBuilder { a | id : Used } slotCaps msg kind
toggleWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
toggleWithSlot : String -> ToggleBuilder { a | slot : Available } slotCaps msg kind -> ToggleBuilder { a | slot : Used } slotCaps msg kind
toggleWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
toggleWithStyle : String -> String -> ToggleBuilder { a | style : Available } slotCaps msg kind -> ToggleBuilder { a | style : Used } slotCaps msg kind
toggleWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
toggleWithFor : String -> ToggleBuilder { a | for : Available } slotCaps msg kind -> ToggleBuilder { a | for : Used } slotCaps msg kind
toggleWithFor value_ =
    B.withAttribute (A.for value_)
