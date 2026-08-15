module Hz.Build.AttrSlot exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, HintSlot, LabelSlot, ChildAdmittedBy
    , withClass, withId, withSlot, withStyle, withWithHint, withWithLabel
    , hint, label
    , withHintSlot, withLabelSlot
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, HintSlot, LabelSlot, ChildAdmittedBy
@docs withClass, withId, withSlot, withStyle, withWithHint, withWithLabel
@docs hint, label
@docs withHintSlot, withLabelSlot

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Hz.Attributes as A
import Hz.Component.AttrSlot as Component
import Hz.Forge.Internal as B
import Hz.Kind exposing (Available, Brand, Ctx, Used)


{-| -}
type alias Is s =
    Component.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.AttrCaps


{-| -}
type alias SlotCaps =
    Component.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ChildAdmittedBy childAdm


{-| -}
type alias HintSlot =
    Component.HintSlot


{-| -}
type alias LabelSlot =
    Component.LabelSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "hz-attr-slot" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
hint :
    B.Builder childRow childAttrCaps childSlotCaps Component.HintSlot msg
    -> Element free freeAdmittedBy msg
hint builder =
    Component.hint (B.toElement builder)


{-| -}
label :
    B.Builder childRow childAttrCaps childSlotCaps Component.LabelSlot msg
    -> Element free freeAdmittedBy msg
label builder =
    Component.label (B.toElement builder)


{-| -}
withHintSlot :
    B.Builder childRow childAttrCaps childSlotCaps Component.HintSlot msg
    -> Builder attrCaps { s | hint : Available } msg kind
    -> Builder attrCaps { s | hint : Used } msg kind
withHintSlot slotBuilder builder_ =
    B.withChild (El.toNode (Component.hint (B.toElement slotBuilder))) builder_


{-| -}
withLabelSlot :
    B.Builder childRow childAttrCaps childSlotCaps Component.LabelSlot msg
    -> Builder attrCaps { s | label : Available } msg kind
    -> Builder attrCaps { s | label : Used } msg kind
withLabelSlot slotBuilder builder_ =
    B.withChild (El.toNode (Component.label (B.toElement slotBuilder))) builder_


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
