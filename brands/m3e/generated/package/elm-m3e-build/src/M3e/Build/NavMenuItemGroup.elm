module M3e.Build.NavMenuItemGroup exposing (Builder, AttrCaps, SlotCaps, Is, Content, LabelSlot, ChildAdmittedBy, build, toElement, withClass, withId, withSlot, withStyle, label, withLabel, withChild)

{-| The **NavMenuItemGroup** element — the flat per-element builder surface,
sourced through the **NavMenu** family façade
(`M3e.Component.NavMenu`). This module and the aggregated
`M3e.Build.NavMenu` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, Content, LabelSlot, ChildAdmittedBy, build, toElement, withClass, withId, withSlot, withStyle, label, withLabel, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.NavMenu as Component
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.ItemGroupIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.ItemGroupBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.ItemGroupAttrCaps


{-| -}
type alias SlotCaps =
    Component.ItemGroupSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ItemGroupChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.ItemGroupContent


{-| -}
type alias LabelSlot =
    Component.ItemGroupLabelSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-nav-menu-item-group" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.ItemGroupIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
label :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemGroupLabelSlot msg
    -> Element free freeAdmittedBy msg
label builder =
    Component.itemGroupLabel (B.toElement builder)


{-| -}
withLabel :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemGroupLabelSlot msg
    -> Builder attrCaps { s | label : Available } msg kind
    -> Builder attrCaps { s | label : Used } msg kind
withLabel slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemGroupLabel (B.toElement slotBuilder))) builder_


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
