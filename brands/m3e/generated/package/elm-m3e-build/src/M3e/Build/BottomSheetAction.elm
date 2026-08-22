module M3e.Build.BottomSheetAction exposing (Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withId, withSlot, withStyle, withChild)

{-| The **BottomSheetAction** element — the flat per-element builder surface,
sourced through the **BottomSheet** family façade
(`M3e.Component.BottomSheet`). This module and the aggregated
`M3e.Build.BottomSheet` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withId, withSlot, withStyle, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.BottomSheet as Component
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.ActionIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.ActionBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.ActionAttrCaps


{-| -}
type alias SlotCaps =
    Component.ActionSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ActionChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.ActionContent


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-bottom-sheet-action" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.ActionIs kind) admittedBy msg
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
