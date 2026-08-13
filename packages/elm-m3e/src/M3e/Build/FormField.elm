module M3e.Build.FormField exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withFloatLabel, withHideRequiredMarker, withHideSubscript, withId, withSlot, withStyle, withVariant
    , error, hint, label, prefix, prefixText, suffix, suffixText
    , withError, withHint, withLabel, withPrefix, withPrefixText, withSuffix, withSuffixText, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withFloatLabel, withHideRequiredMarker, withHideSubscript, withId, withSlot, withStyle, withVariant
@docs error, hint, label, prefix, prefixText, suffix, suffixText
@docs withError, withHint, withLabel, withPrefix, withPrefixText, withSuffix, withSuffixText, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.FormField as Component
import M3e.Internal.Types.FormField
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    M3e.Internal.Types.FormField.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.FormField.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.FormField.AttrCaps


{-| -}
type alias SlotCaps =
    M3e.Internal.Types.FormField.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.FormField.ChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-form-field" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
error :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
error builder =
    Component.error (B.toElement builder)


{-| -}
hint :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
hint builder =
    Component.hint (B.toElement builder)


{-| -}
label :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
label builder =
    Component.label (B.toElement builder)


{-| -}
prefix :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
prefix builder =
    Component.prefix (B.toElement builder)


{-| -}
prefixText :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
prefixText builder =
    Component.prefixText (B.toElement builder)


{-| -}
suffix :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
suffix builder =
    Component.suffix (B.toElement builder)


{-| -}
suffixText :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
suffixText builder =
    Component.suffixText (B.toElement builder)


{-| -}
withError :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | error : Available } msg kind
    -> Builder attrCaps { s | error : Used } msg kind
withError slotBuilder builder_ =
    B.withChild (El.toNode (Component.error (B.toElement slotBuilder))) builder_


{-| -}
withHint :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | hint : Available } msg kind
    -> Builder attrCaps { s | hint : Used } msg kind
withHint slotBuilder builder_ =
    B.withChild (El.toNode (Component.hint (B.toElement slotBuilder))) builder_


{-| -}
withLabel :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | label : Available } msg kind
    -> Builder attrCaps { s | label : Used } msg kind
withLabel slotBuilder builder_ =
    B.withChild (El.toNode (Component.label (B.toElement slotBuilder))) builder_


{-| -}
withPrefix :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | prefix : Available } msg kind
    -> Builder attrCaps { s | prefix : Used } msg kind
withPrefix slotBuilder builder_ =
    B.withChild (El.toNode (Component.prefix (B.toElement slotBuilder))) builder_


{-| -}
withPrefixText :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | prefixText : Available } msg kind
    -> Builder attrCaps { s | prefixText : Used } msg kind
withPrefixText slotBuilder builder_ =
    B.withChild (El.toNode (Component.prefixText (B.toElement slotBuilder))) builder_


{-| -}
withSuffix :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | suffix : Available } msg kind
    -> Builder attrCaps { s | suffix : Used } msg kind
withSuffix slotBuilder builder_ =
    B.withChild (El.toNode (Component.suffix (B.toElement slotBuilder))) builder_


{-| -}
withSuffixText :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | suffixText : Available } msg kind
    -> Builder attrCaps { s | suffixText : Used } msg kind
withSuffixText slotBuilder builder_ =
    B.withChild (El.toNode (Component.suffixText (B.toElement slotBuilder))) builder_


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
withFloatLabel : Value Component.FloatLabel -> Builder { a | floatLabel : Available } slotCaps msg kind -> Builder { a | floatLabel : Used } slotCaps msg kind
withFloatLabel value_ =
    B.withAttribute (Component.floatLabel value_)


{-| -}
withHideRequiredMarker : Bool -> Builder { a | hideRequiredMarker : Available } slotCaps msg kind -> Builder { a | hideRequiredMarker : Used } slotCaps msg kind
withHideRequiredMarker value_ =
    B.withAttribute (A.hideRequiredMarker value_)


{-| -}
withHideSubscript : Value Component.HideSubscript -> Builder { a | hideSubscript : Available } slotCaps msg kind -> Builder { a | hideSubscript : Used } slotCaps msg kind
withHideSubscript value_ =
    B.withAttribute (Component.hideSubscript value_)


{-| -}
withVariant : Value Component.Variant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.variant value_)
