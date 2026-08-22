module M3e.Build.ButtonGroup exposing (Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withId, withMulti, withSize, withSlot, withStyle, withVariant, withChild)

{-| The **ButtonGroup** element — the flat per-element builder surface,
sourced through the **SegmentedButton** family façade
(`M3e.Component.SegmentedButton`). This module and the aggregated
`M3e.Build.SegmentedButton` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withId, withMulti, withSize, withSlot, withStyle, withVariant, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.SegmentedButton as Component
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.GroupIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.GroupBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.GroupAttrCaps


{-| -}
type alias SlotCaps =
    Component.GroupSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.GroupChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.GroupContent


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-button-group" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.GroupIs kind) admittedBy msg
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
withMulti : Bool -> Builder { a | multi : Available } slotCaps msg kind -> Builder { a | multi : Used } slotCaps msg kind
withMulti value_ =
    B.withAttribute (A.multi value_)


{-| -}
withSize : Value Component.GroupSize -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.groupSize value_)


{-| -}
withVariant : Value Component.GroupVariant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.groupVariant value_)
