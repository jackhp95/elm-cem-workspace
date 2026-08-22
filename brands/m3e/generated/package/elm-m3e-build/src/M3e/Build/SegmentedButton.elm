module M3e.Build.SegmentedButton exposing (SegmentedButtonBuilder, SegmentedButtonAttrCaps, SegmentedButtonSlotCaps, SegmentedButtonIs, SegmentedButtonContent, SegmentedButtonChildAdmittedBy, segmentedButtonBuild, segmentedButtonToElement, segmentedButtonWithClass, segmentedButtonWithDisabled, segmentedButtonWithHideSelectionIndicator, segmentedButtonWithId, segmentedButtonWithMulti, segmentedButtonWithName, segmentedButtonWithOnBeforeinput, segmentedButtonWithOnChange, segmentedButtonWithOnInput, segmentedButtonWithSlot, segmentedButtonWithStyle, segmentedButtonWithChild, SegmentBuilder, SegmentAttrCaps, SegmentSlotCaps, SegmentIs, SegmentContent, SegmentIconSlot, SegmentChildAdmittedBy, segmentBuild, segmentToElement, segmentWithChecked, segmentWithClass, segmentWithDisabled, segmentWithId, segmentWithOnBeforeinput, segmentWithOnChange, segmentWithOnClick, segmentWithOnInput, segmentWithSlot, segmentWithStyle, segmentWithValue, segmentIcon, segmentWithIcon, segmentWithChild, GroupBuilder, GroupAttrCaps, GroupSlotCaps, GroupIs, GroupContent, GroupChildAdmittedBy, groupBuild, groupToElement, groupWithClass, groupWithId, groupWithMulti, groupWithSize, groupWithSlot, groupWithStyle, groupWithVariant, groupWithChild)

{-| The **SegmentedButton** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.SegmentedButton`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs SegmentedButtonBuilder, SegmentedButtonAttrCaps, SegmentedButtonSlotCaps, SegmentedButtonIs, SegmentedButtonContent, SegmentedButtonChildAdmittedBy, segmentedButtonBuild, segmentedButtonToElement, segmentedButtonWithClass, segmentedButtonWithDisabled, segmentedButtonWithHideSelectionIndicator, segmentedButtonWithId, segmentedButtonWithMulti, segmentedButtonWithName, segmentedButtonWithOnBeforeinput, segmentedButtonWithOnChange, segmentedButtonWithOnInput, segmentedButtonWithSlot, segmentedButtonWithStyle, segmentedButtonWithChild, SegmentBuilder, SegmentAttrCaps, SegmentSlotCaps, SegmentIs, SegmentContent, SegmentIconSlot, SegmentChildAdmittedBy, segmentBuild, segmentToElement, segmentWithChecked, segmentWithClass, segmentWithDisabled, segmentWithId, segmentWithOnBeforeinput, segmentWithOnChange, segmentWithOnClick, segmentWithOnInput, segmentWithSlot, segmentWithStyle, segmentWithValue, segmentIcon, segmentWithIcon, segmentWithChild, GroupBuilder, GroupAttrCaps, GroupSlotCaps, GroupIs, GroupContent, GroupChildAdmittedBy, groupBuild, groupToElement, groupWithClass, groupWithId, groupWithMulti, groupWithSize, groupWithSlot, groupWithStyle, groupWithVariant, groupWithChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Component.SegmentedButton as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias SegmentedButtonIs s =
    Component.SegmentedButtonIs s


{-| -}
type alias SegmentedButtonBuilder attrCaps slotCaps msg kind =
    Component.SegmentedButtonBuilder attrCaps slotCaps msg kind


{-| -}
type alias SegmentedButtonAttrCaps =
    Component.SegmentedButtonAttrCaps


{-| -}
type alias SegmentedButtonSlotCaps =
    Component.SegmentedButtonSlotCaps


{-| -}
type alias SegmentedButtonChildAdmittedBy childAdm =
    Component.SegmentedButtonChildAdmittedBy childAdm


{-| -}
type alias SegmentedButtonContent =
    Component.SegmentedButtonContent


{-| -}
segmentedButtonBuild :
    { content : Element Component.SegmentedButtonContent (Component.SegmentedButtonChildAdmittedBy childAdm) msg }
    -> SegmentedButtonBuilder SegmentedButtonAttrCaps SegmentedButtonSlotCaps msg kind
segmentedButtonBuild required_ =
    B.init "m3e-segmented-button" [] [ El.toNode required_.content ]


{-| -}
segmentedButtonToElement : SegmentedButtonBuilder attrCaps slotCaps msg kind -> Element (Component.SegmentedButtonIs kind) admittedBy msg
segmentedButtonToElement =
    B.toElement


{-| -}
segmentedButtonWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> SegmentedButtonBuilder attrCaps slotCaps msg kind
    -> SegmentedButtonBuilder attrCaps slotCaps msg kind
segmentedButtonWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
segmentedButtonWithClass : String -> SegmentedButtonBuilder { a | class : Available } slotCaps msg kind -> SegmentedButtonBuilder { a | class : Used } slotCaps msg kind
segmentedButtonWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
segmentedButtonWithId : String -> SegmentedButtonBuilder { a | id : Available } slotCaps msg kind -> SegmentedButtonBuilder { a | id : Used } slotCaps msg kind
segmentedButtonWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
segmentedButtonWithSlot : String -> SegmentedButtonBuilder { a | slot : Available } slotCaps msg kind -> SegmentedButtonBuilder { a | slot : Used } slotCaps msg kind
segmentedButtonWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
segmentedButtonWithStyle : String -> String -> SegmentedButtonBuilder { a | style : Available } slotCaps msg kind -> SegmentedButtonBuilder { a | style : Used } slotCaps msg kind
segmentedButtonWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
segmentedButtonWithDisabled : Bool -> SegmentedButtonBuilder { a | disabled : Available } slotCaps msg kind -> SegmentedButtonBuilder { a | disabled : Used } slotCaps msg kind
segmentedButtonWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
segmentedButtonWithHideSelectionIndicator : Bool -> SegmentedButtonBuilder { a | hideSelectionIndicator : Available } slotCaps msg kind -> SegmentedButtonBuilder { a | hideSelectionIndicator : Used } slotCaps msg kind
segmentedButtonWithHideSelectionIndicator value_ =
    B.withAttribute (A.hideSelectionIndicator value_)


{-| -}
segmentedButtonWithMulti : Bool -> SegmentedButtonBuilder { a | multi : Available } slotCaps msg kind -> SegmentedButtonBuilder { a | multi : Used } slotCaps msg kind
segmentedButtonWithMulti value_ =
    B.withAttribute (A.multi value_)


{-| -}
segmentedButtonWithName : String -> SegmentedButtonBuilder { a | name : Available } slotCaps msg kind -> SegmentedButtonBuilder { a | name : Used } slotCaps msg kind
segmentedButtonWithName value_ =
    B.withAttribute (Ir.attribute "name" value_)


{-| -}
segmentedButtonWithOnChange : msg -> SegmentedButtonBuilder { a | onChange : Available } slotCaps msg kind -> SegmentedButtonBuilder { a | onChange : Used } slotCaps msg kind
segmentedButtonWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
segmentedButtonWithOnBeforeinput : msg -> SegmentedButtonBuilder { a | onBeforeinput : Available } slotCaps msg kind -> SegmentedButtonBuilder { a | onBeforeinput : Used } slotCaps msg kind
segmentedButtonWithOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
segmentedButtonWithOnInput : msg -> SegmentedButtonBuilder { a | onInput : Available } slotCaps msg kind -> SegmentedButtonBuilder { a | onInput : Used } slotCaps msg kind
segmentedButtonWithOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
type alias SegmentIs s =
    Component.SegmentIs s


{-| -}
type alias SegmentBuilder attrCaps slotCaps msg kind =
    Component.SegmentBuilder attrCaps slotCaps msg kind


{-| -}
type alias SegmentAttrCaps =
    Component.SegmentAttrCaps


{-| -}
type alias SegmentSlotCaps =
    Component.SegmentSlotCaps


{-| -}
type alias SegmentChildAdmittedBy childAdm =
    Component.SegmentChildAdmittedBy childAdm


{-| -}
type alias SegmentContent =
    Component.SegmentContent


{-| -}
type alias SegmentIconSlot =
    Component.SegmentIconSlot


{-| -}
segmentBuild : SegmentBuilder SegmentAttrCaps SegmentSlotCaps msg kind
segmentBuild =
    B.init "m3e-button-segment" [] []


{-| -}
segmentToElement : SegmentBuilder attrCaps slotCaps msg kind -> Element (Component.SegmentIs kind) admittedBy msg
segmentToElement =
    B.toElement


{-| -}
segmentIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SegmentIconSlot msg
    -> Element free freeAdmittedBy msg
segmentIcon builder =
    Component.segmentIcon (B.toElement builder)


{-| -}
segmentWithIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SegmentIconSlot msg
    -> SegmentBuilder attrCaps { s | icon : Available } msg kind
    -> SegmentBuilder attrCaps { s | icon : Used } msg kind
segmentWithIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.segmentIcon (B.toElement slotBuilder))) builder_


{-| -}
segmentWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> SegmentBuilder attrCaps slotCaps msg kind
    -> SegmentBuilder attrCaps slotCaps msg kind
segmentWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
segmentWithClass : String -> SegmentBuilder { a | class : Available } slotCaps msg kind -> SegmentBuilder { a | class : Used } slotCaps msg kind
segmentWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
segmentWithId : String -> SegmentBuilder { a | id : Available } slotCaps msg kind -> SegmentBuilder { a | id : Used } slotCaps msg kind
segmentWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
segmentWithSlot : String -> SegmentBuilder { a | slot : Available } slotCaps msg kind -> SegmentBuilder { a | slot : Used } slotCaps msg kind
segmentWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
segmentWithStyle : String -> String -> SegmentBuilder { a | style : Available } slotCaps msg kind -> SegmentBuilder { a | style : Used } slotCaps msg kind
segmentWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
segmentWithChecked : Bool -> SegmentBuilder { a | checked : Available } slotCaps msg kind -> SegmentBuilder { a | checked : Used } slotCaps msg kind
segmentWithChecked value_ =
    B.withAttribute (A.checked value_)


{-| -}
segmentWithDisabled : Bool -> SegmentBuilder { a | disabled : Available } slotCaps msg kind -> SegmentBuilder { a | disabled : Used } slotCaps msg kind
segmentWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
segmentWithValue : String -> SegmentBuilder { a | value : Available } slotCaps msg kind -> SegmentBuilder { a | value : Used } slotCaps msg kind
segmentWithValue value_ =
    B.withAttribute (A.value value_)


{-| -}
segmentWithOnBeforeinput : msg -> SegmentBuilder { a | onBeforeinput : Available } slotCaps msg kind -> SegmentBuilder { a | onBeforeinput : Used } slotCaps msg kind
segmentWithOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
segmentWithOnInput : msg -> SegmentBuilder { a | onInput : Available } slotCaps msg kind -> SegmentBuilder { a | onInput : Used } slotCaps msg kind
segmentWithOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
segmentWithOnChange : msg -> SegmentBuilder { a | onChange : Available } slotCaps msg kind -> SegmentBuilder { a | onChange : Used } slotCaps msg kind
segmentWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
segmentWithOnClick : msg -> SegmentBuilder { a | onClick : Available } slotCaps msg kind -> SegmentBuilder { a | onClick : Used } slotCaps msg kind
segmentWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)


{-| -}
type alias GroupIs s =
    Component.GroupIs s


{-| -}
type alias GroupBuilder attrCaps slotCaps msg kind =
    Component.GroupBuilder attrCaps slotCaps msg kind


{-| -}
type alias GroupAttrCaps =
    Component.GroupAttrCaps


{-| -}
type alias GroupSlotCaps =
    Component.GroupSlotCaps


{-| -}
type alias GroupChildAdmittedBy childAdm =
    Component.GroupChildAdmittedBy childAdm


{-| -}
type alias GroupContent =
    Component.GroupContent


{-| -}
groupBuild : GroupBuilder GroupAttrCaps GroupSlotCaps msg kind
groupBuild =
    B.init "m3e-button-group" [] []


{-| -}
groupToElement : GroupBuilder attrCaps slotCaps msg kind -> Element (Component.GroupIs kind) admittedBy msg
groupToElement =
    B.toElement


{-| -}
groupWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> GroupBuilder attrCaps slotCaps msg kind
    -> GroupBuilder attrCaps slotCaps msg kind
groupWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
groupWithClass : String -> GroupBuilder { a | class : Available } slotCaps msg kind -> GroupBuilder { a | class : Used } slotCaps msg kind
groupWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
groupWithId : String -> GroupBuilder { a | id : Available } slotCaps msg kind -> GroupBuilder { a | id : Used } slotCaps msg kind
groupWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
groupWithSlot : String -> GroupBuilder { a | slot : Available } slotCaps msg kind -> GroupBuilder { a | slot : Used } slotCaps msg kind
groupWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
groupWithStyle : String -> String -> GroupBuilder { a | style : Available } slotCaps msg kind -> GroupBuilder { a | style : Used } slotCaps msg kind
groupWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
groupWithMulti : Bool -> GroupBuilder { a | multi : Available } slotCaps msg kind -> GroupBuilder { a | multi : Used } slotCaps msg kind
groupWithMulti value_ =
    B.withAttribute (A.multi value_)


{-| -}
groupWithSize : Value Component.GroupSize -> GroupBuilder { a | size : Available } slotCaps msg kind -> GroupBuilder { a | size : Used } slotCaps msg kind
groupWithSize value_ =
    B.withAttribute (Component.groupSize value_)


{-| -}
groupWithVariant : Value Component.GroupVariant -> GroupBuilder { a | variant : Available } slotCaps msg kind -> GroupBuilder { a | variant : Used } slotCaps msg kind
groupWithVariant value_ =
    B.withAttribute (Component.groupVariant value_)
