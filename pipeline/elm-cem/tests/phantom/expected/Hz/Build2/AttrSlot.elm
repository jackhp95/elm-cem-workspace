module Hz.Build2.AttrSlot exposing (Builder, AttrCaps, SlotCaps, Is, HintSlot, LabelSlot, ChildAdmittedBy, build, toElement, withClass, withId, withSlot, withStyle, withWithHint, withWithLabel, hint, label, withHintSlot, withLabelSlot)

{-| The **AttrSlot** family — COMPOSED builders (DAG-rework Task 3 dual-emit).

One module carrying every member's builder surface
(degenerate single-member family — flat, un-prefixed surface),
sourced through `Hz.Component2.AttrSlot` (the family façade) rather
than the per-element `Hz.Element.*` modules. This is the Shape A
`Build2` cutover; it emits ALONGSIDE the shipped per-element `Hz.Build.*`
surface and does not replace it (until Task 4 materialize).

@docs Builder, AttrCaps, SlotCaps, Is, HintSlot, LabelSlot, ChildAdmittedBy, build, toElement, withClass, withId, withSlot, withStyle, withWithHint, withWithLabel, hint, label, withHintSlot, withLabelSlot

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Hz.Attributes as A
import Hz.Component2.AttrSlot as Component
import Hz.Forge.Internal as B
import Hz.Kind exposing (Available, Brand, Ctx, Used)
import Hz.Values


{-| -}
type alias Is s =
    Component.AttrSlotIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.AttrSlotBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.AttrSlotAttrCaps


{-| -}
type alias SlotCaps =
    Component.AttrSlotSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.AttrSlotChildAdmittedBy childAdm


{-| -}
type alias HintSlot =
    Component.AttrSlotHintSlot


{-| -}
type alias LabelSlot =
    Component.AttrSlotLabelSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "hz-attr-slot" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.AttrSlotIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
hint :
    B.Builder childRow childAttrCaps childSlotCaps Component.AttrSlotHintSlot msg
    -> Element free freeAdmittedBy msg
hint builder =
    Component.attrSlotHint (B.toElement builder)


{-| -}
label :
    B.Builder childRow childAttrCaps childSlotCaps Component.AttrSlotLabelSlot msg
    -> Element free freeAdmittedBy msg
label builder =
    Component.attrSlotLabel (B.toElement builder)


{-| -}
withHintSlot :
    B.Builder childRow childAttrCaps childSlotCaps Component.AttrSlotHintSlot msg
    -> Builder attrCaps { s | hint : Available } msg kind
    -> Builder attrCaps { s | hint : Used } msg kind
withHintSlot slotBuilder builder_ =
    B.withChild (El.toNode (Component.attrSlotHint (B.toElement slotBuilder))) builder_


{-| -}
withLabelSlot :
    B.Builder childRow childAttrCaps childSlotCaps Component.AttrSlotLabelSlot msg
    -> Builder attrCaps { s | label : Available } msg kind
    -> Builder attrCaps { s | label : Used } msg kind
withLabelSlot slotBuilder builder_ =
    B.withChild (El.toNode (Component.attrSlotLabel (B.toElement slotBuilder))) builder_


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
withWithHint : Bool -> Builder { a | withHint : Available } slotCaps msg kind -> Builder { a | withHint : Used } slotCaps msg kind
withWithHint value_ =
    B.withAttribute (A.withHint value_)


{-| -}
withWithLabel : Bool -> Builder { a | withLabel : Available } slotCaps msg kind -> Builder { a | withLabel : Used } slotCaps msg kind
withWithLabel value_ =
    B.withAttribute (A.withLabel value_)
