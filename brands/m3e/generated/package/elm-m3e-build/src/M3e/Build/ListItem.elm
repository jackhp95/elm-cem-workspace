module M3e.Build.ListItem exposing (Builder, AttrCaps, SlotCaps, Is, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, TrailingSlot, ChildAdmittedBy, build, toElement, withClass, withId, withSlot, withStyle, leading, overline, supportingText, trailing, withLeading, withOverline, withSupportingText, withTrailing, withChild)

{-| The **ListItem** element — the flat per-element builder surface,
sourced through the **List** family façade
(`M3e.Component.List`). This module and the aggregated
`M3e.Build.List` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, TrailingSlot, ChildAdmittedBy, build, toElement, withClass, withId, withSlot, withStyle, leading, overline, supportingText, trailing, withLeading, withOverline, withSupportingText, withTrailing, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.List as Component
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.ItemIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.ItemBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.ItemAttrCaps


{-| -}
type alias SlotCaps =
    Component.ItemSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ItemChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.ItemContent


{-| -}
type alias LeadingSlot =
    Component.ItemLeadingSlot


{-| -}
type alias OverlineSlot =
    Component.ItemOverlineSlot


{-| -}
type alias SupportingTextSlot =
    Component.ItemSupportingTextSlot


{-| -}
type alias TrailingSlot =
    Component.ItemTrailingSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-list-item" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.ItemIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
leading :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemLeadingSlot msg
    -> Element free freeAdmittedBy msg
leading builder =
    Component.itemLeading (B.toElement builder)


{-| -}
overline :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemOverlineSlot msg
    -> Element free freeAdmittedBy msg
overline builder =
    Component.itemOverline (B.toElement builder)


{-| -}
supportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemSupportingTextSlot msg
    -> Element free freeAdmittedBy msg
supportingText builder =
    Component.itemSupportingText (B.toElement builder)


{-| -}
trailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemTrailingSlot msg
    -> Element free freeAdmittedBy msg
trailing builder =
    Component.itemTrailing (B.toElement builder)


{-| -}
withLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemLeadingSlot msg
    -> Builder attrCaps { s | leading : Available } msg kind
    -> Builder attrCaps { s | leading : Used } msg kind
withLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemLeading (B.toElement slotBuilder))) builder_


{-| -}
withOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemOverlineSlot msg
    -> Builder attrCaps { s | overline : Available } msg kind
    -> Builder attrCaps { s | overline : Used } msg kind
withOverline slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemOverline (B.toElement slotBuilder))) builder_


{-| -}
withSupportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemSupportingTextSlot msg
    -> Builder attrCaps { s | supportingText : Available } msg kind
    -> Builder attrCaps { s | supportingText : Used } msg kind
withSupportingText slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemSupportingText (B.toElement slotBuilder))) builder_


{-| -}
withTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemTrailingSlot msg
    -> Builder attrCaps { s | trailing : Available } msg kind
    -> Builder attrCaps { s | trailing : Used } msg kind
withTrailing slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemTrailing (B.toElement slotBuilder))) builder_


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
