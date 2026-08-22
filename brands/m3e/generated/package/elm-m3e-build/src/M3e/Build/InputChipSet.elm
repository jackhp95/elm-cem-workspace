module M3e.Build.InputChipSet exposing (Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withDisabled, withId, withMaxChips, withName, withOnChange, withRequired, withSlot, withStyle, withValidationmessages, withVertical, input, withInput, withChild)

{-| The **InputChipSet** element — the flat per-element builder surface,
sourced through the **Chip** family façade
(`M3e.Component.Chip`). This module and the aggregated
`M3e.Build.Chip` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withDisabled, withId, withMaxChips, withName, withOnChange, withRequired, withSlot, withStyle, withValidationmessages, withVertical, input, withInput, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Component.Chip as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.InputSetIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.InputSetBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.InputSetAttrCaps


{-| -}
type alias SlotCaps =
    Component.InputSetSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.InputSetChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.InputSetContent


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-input-chip-set" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.InputSetIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
input :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
input builder =
    Component.inputSetInput (B.toElement builder)


{-| -}
withInput :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | input : Available } msg kind
    -> Builder attrCaps { s | input : Used } msg kind
withInput slotBuilder builder_ =
    B.withChild (El.toNode (Component.inputSetInput (B.toElement slotBuilder))) builder_


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
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withMaxChips : Float -> Builder { a | maxChips : Available } slotCaps msg kind -> Builder { a | maxChips : Used } slotCaps msg kind
withMaxChips value_ =
    B.withAttribute (A.maxChips value_)


{-| -}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (Ir.attribute "name" value_)


{-| -}
withRequired : Bool -> Builder { a | required : Available } slotCaps msg kind -> Builder { a | required : Used } slotCaps msg kind
withRequired value_ =
    B.withAttribute (A.required value_)


{-| -}
withValidationmessages : String -> Builder { a | validationmessages : Available } slotCaps msg kind -> Builder { a | validationmessages : Used } slotCaps msg kind
withValidationmessages value_ =
    B.withAttribute (A.validationmessages value_)


{-| -}
withVertical : Bool -> Builder { a | vertical : Available } slotCaps msg kind -> Builder { a | vertical : Used } slotCaps msg kind
withVertical value_ =
    B.withAttribute (A.vertical value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)
