module M3e.Build.NavRail exposing (NavRailBuilder, NavRailAttrCaps, NavRailSlotCaps, NavRailIs, NavRailContent, NavRailChildAdmittedBy, navRailBuild, navRailToElement, navRailWithClass, navRailWithId, navRailWithMode, navRailWithOnBeforeinput, navRailWithOnChange, navRailWithOnInput, navRailWithSlot, navRailWithStyle, navRailWithChild, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleIs, ToggleChildAdmittedBy, toggleBuild, toggleToElement, toggleWithClass, toggleWithFor, toggleWithId, toggleWithSlot, toggleWithStyle)

{-| The **NavRail** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.NavRail`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs NavRailBuilder, NavRailAttrCaps, NavRailSlotCaps, NavRailIs, NavRailContent, NavRailChildAdmittedBy, navRailBuild, navRailToElement, navRailWithClass, navRailWithId, navRailWithMode, navRailWithOnBeforeinput, navRailWithOnChange, navRailWithOnInput, navRailWithSlot, navRailWithStyle, navRailWithChild, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleIs, ToggleChildAdmittedBy, toggleBuild, toggleToElement, toggleWithClass, toggleWithFor, toggleWithId, toggleWithSlot, toggleWithStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.NavRail as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias NavRailIs s =
    Component.NavRailIs s


{-| -}
type alias NavRailBuilder attrCaps slotCaps msg kind =
    Component.NavRailBuilder attrCaps slotCaps msg kind


{-| -}
type alias NavRailAttrCaps =
    Component.NavRailAttrCaps


{-| -}
type alias NavRailSlotCaps =
    Component.NavRailSlotCaps


{-| -}
type alias NavRailChildAdmittedBy childAdm =
    Component.NavRailChildAdmittedBy childAdm


{-| -}
type alias NavRailContent =
    Component.NavRailContent


{-| -}
navRailBuild : NavRailBuilder NavRailAttrCaps NavRailSlotCaps msg kind
navRailBuild =
    B.init "m3e-nav-rail" [] []


{-| -}
navRailToElement : NavRailBuilder attrCaps slotCaps msg kind -> Element (Component.NavRailIs kind) admittedBy msg
navRailToElement =
    B.toElement


{-| -}
navRailWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> NavRailBuilder attrCaps slotCaps msg kind
    -> NavRailBuilder attrCaps slotCaps msg kind
navRailWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
navRailWithClass : String -> NavRailBuilder { a | class : Available } slotCaps msg kind -> NavRailBuilder { a | class : Used } slotCaps msg kind
navRailWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
navRailWithId : String -> NavRailBuilder { a | id : Available } slotCaps msg kind -> NavRailBuilder { a | id : Used } slotCaps msg kind
navRailWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
navRailWithSlot : String -> NavRailBuilder { a | slot : Available } slotCaps msg kind -> NavRailBuilder { a | slot : Used } slotCaps msg kind
navRailWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
navRailWithStyle : String -> String -> NavRailBuilder { a | style : Available } slotCaps msg kind -> NavRailBuilder { a | style : Used } slotCaps msg kind
navRailWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
navRailWithMode : Value Component.NavRailMode -> NavRailBuilder { a | mode : Available } slotCaps msg kind -> NavRailBuilder { a | mode : Used } slotCaps msg kind
navRailWithMode value_ =
    B.withAttribute (Component.navRailMode value_)


{-| -}
navRailWithOnBeforeinput : msg -> NavRailBuilder { a | onBeforeinput : Available } slotCaps msg kind -> NavRailBuilder { a | onBeforeinput : Used } slotCaps msg kind
navRailWithOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
navRailWithOnInput : msg -> NavRailBuilder { a | onInput : Available } slotCaps msg kind -> NavRailBuilder { a | onInput : Used } slotCaps msg kind
navRailWithOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
navRailWithOnChange : msg -> NavRailBuilder { a | onChange : Available } slotCaps msg kind -> NavRailBuilder { a | onChange : Used } slotCaps msg kind
navRailWithOnChange value_ =
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
    B.init "m3e-nav-rail-toggle" [] []


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
