module M3e.Build.ListOption exposing (Builder, AttrCaps, SlotCaps, Is, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, TrailingSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withId, withOnBeforeinput, withOnChange, withOnClick, withOnInput, withSelected, withSlot, withStyle, withValue, leading, overline, supportingText, trailing, withLeading, withOverline, withSupportingText, withTrailing, withChild)

{-| The **ListOption** element — the flat per-element builder surface,
sourced through the **List** family façade
(`M3e.Component.List`). This module and the aggregated
`M3e.Build.List` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, TrailingSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withId, withOnBeforeinput, withOnChange, withOnClick, withOnInput, withSelected, withSlot, withStyle, withValue, leading, overline, supportingText, trailing, withLeading, withOverline, withSupportingText, withTrailing, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.List as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.OptionIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.OptionBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.OptionAttrCaps


{-| -}
type alias SlotCaps =
    Component.OptionSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.OptionChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.OptionContent


{-| -}
type alias LeadingSlot =
    Component.OptionLeadingSlot


{-| -}
type alias OverlineSlot =
    Component.OptionOverlineSlot


{-| -}
type alias SupportingTextSlot =
    Component.OptionSupportingTextSlot


{-| -}
type alias TrailingSlot =
    Component.OptionTrailingSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-list-option" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.OptionIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
leading :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionLeadingSlot msg
    -> Element free freeAdmittedBy msg
leading builder =
    Component.optionLeading (B.toElement builder)


{-| -}
overline :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionOverlineSlot msg
    -> Element free freeAdmittedBy msg
overline builder =
    Component.optionOverline (B.toElement builder)


{-| -}
supportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionSupportingTextSlot msg
    -> Element free freeAdmittedBy msg
supportingText builder =
    Component.optionSupportingText (B.toElement builder)


{-| -}
trailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionTrailingSlot msg
    -> Element free freeAdmittedBy msg
trailing builder =
    Component.optionTrailing (B.toElement builder)


{-| -}
withLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionLeadingSlot msg
    -> Builder attrCaps { s | leading : Available } msg kind
    -> Builder attrCaps { s | leading : Used } msg kind
withLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.optionLeading (B.toElement slotBuilder))) builder_


{-| -}
withOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionOverlineSlot msg
    -> Builder attrCaps { s | overline : Available } msg kind
    -> Builder attrCaps { s | overline : Used } msg kind
withOverline slotBuilder builder_ =
    B.withChild (El.toNode (Component.optionOverline (B.toElement slotBuilder))) builder_


{-| -}
withSupportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionSupportingTextSlot msg
    -> Builder attrCaps { s | supportingText : Available } msg kind
    -> Builder attrCaps { s | supportingText : Used } msg kind
withSupportingText slotBuilder builder_ =
    B.withChild (El.toNode (Component.optionSupportingText (B.toElement slotBuilder))) builder_


{-| -}
withTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionTrailingSlot msg
    -> Builder attrCaps { s | trailing : Available } msg kind
    -> Builder attrCaps { s | trailing : Used } msg kind
withTrailing slotBuilder builder_ =
    B.withChild (El.toNode (Component.optionTrailing (B.toElement slotBuilder))) builder_


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
withSelected : Bool -> Builder { a | selected : Available } slotCaps msg kind -> Builder { a | selected : Used } slotCaps msg kind
withSelected value_ =
    B.withAttribute (A.selected value_)


{-| -}
withValue : String -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (A.value value_)


{-| -}
withOnBeforeinput : msg -> Builder { a | onBeforeinput : Available } slotCaps msg kind -> Builder { a | onBeforeinput : Used } slotCaps msg kind
withOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
withOnInput : msg -> Builder { a | onInput : Available } slotCaps msg kind -> Builder { a | onInput : Used } slotCaps msg kind
withOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
