module M3e.Component.SegmentedButton exposing (SegmentedButtonIs, SegmentedButtonAttrs, SegmentedButtonBuilder, SegmentedButtonAttrCaps, SegmentedButtonSlotCaps, SegmentedButtonContent, SegmentedButtonChildAdmittedBy, SegmentIs, SegmentAttrs, SegmentBuilder, SegmentAttrCaps, SegmentSlotCaps, SegmentContent, SegmentIconSlot, SegmentChildAdmittedBy, GroupIs, GroupAttrs, GroupBuilder, GroupAttrCaps, GroupSlotCaps, GroupContent, GroupChildAdmittedBy, GroupSize, GroupVariant, segmentedButton, segmentedButtonDisabled, segmentedButtonHideSelectionIndicator, segmentedButtonMulti, segmentedButtonName, segmentedButtonOnChange, segmentedButtonOnBeforeinput, segmentedButtonOnInput, segmentedButtonChild, segment, segmentChecked, segmentDisabled, segmentValue, segmentDefaultChecked, segmentDefaultValue, segmentOnBeforeinput, segmentOnInput, segmentOnChange, segmentOnClick, segmentIcon, segmentChild, group, groupSize, groupVariant, groupMulti, groupChild)

{-| The **SegmentedButton** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.SegmentedButton`](M3e.Element.SegmentedButton) as `segmentedButton`, [`M3e.Element.ButtonSegment`](M3e.Element.ButtonSegment) as `segment`, [`M3e.Element.ButtonGroup`](M3e.Element.ButtonGroup) as `group`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SegmentedButtonIs, SegmentedButtonAttrs, SegmentedButtonBuilder, SegmentedButtonAttrCaps, SegmentedButtonSlotCaps, SegmentedButtonContent, SegmentedButtonChildAdmittedBy, SegmentIs, SegmentAttrs, SegmentBuilder, SegmentAttrCaps, SegmentSlotCaps, SegmentContent, SegmentIconSlot, SegmentChildAdmittedBy, GroupIs, GroupAttrs, GroupBuilder, GroupAttrCaps, GroupSlotCaps, GroupContent, GroupChildAdmittedBy, GroupSize, GroupVariant, segmentedButton, segmentedButtonDisabled, segmentedButtonHideSelectionIndicator, segmentedButtonMulti, segmentedButtonName, segmentedButtonOnChange, segmentedButtonOnBeforeinput, segmentedButtonOnInput, segmentedButtonChild, segment, segmentChecked, segmentDisabled, segmentValue, segmentDefaultChecked, segmentDefaultValue, segmentOnBeforeinput, segmentOnInput, segmentOnChange, segmentOnClick, segmentIcon, segmentChild, group, groupSize, groupVariant, groupMulti, groupChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.ButtonGroup as Group_
import M3e.Element.ButtonSegment as Segment_
import M3e.Element.SegmentedButton as SegmentedButton_


{-| The `segmentedButton` element of this family — delegates to [`M3e.Element.SegmentedButton.component`](M3e.Element.SegmentedButton#component).
-}
segmentedButton :
    { content : Element SegmentedButtonContent (SegmentedButtonChildAdmittedBy childAdm) msg }
    -> List (Attr SegmentedButtonAttrs msg)
    -> List (Element SegmentedButtonContent (SegmentedButtonChildAdmittedBy childAdm) msg)
    -> Element (SegmentedButtonIs s) admittedBy msg
segmentedButton =
    SegmentedButton_.component


{-| See [`M3e.Element.SegmentedButton.Is`](M3e.Element.SegmentedButton#Is).
-}
type alias SegmentedButtonIs s =
    SegmentedButton_.Is s


{-| See [`M3e.Element.SegmentedButton.Attrs`](M3e.Element.SegmentedButton#Attrs).
-}
type alias SegmentedButtonAttrs =
    SegmentedButton_.Attrs


{-| See [`M3e.Element.SegmentedButton.Builder`](M3e.Element.SegmentedButton#Builder).
-}
type alias SegmentedButtonBuilder attrCaps slotCaps msg kind =
    SegmentedButton_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.SegmentedButton.AttrCaps`](M3e.Element.SegmentedButton#AttrCaps).
-}
type alias SegmentedButtonAttrCaps =
    SegmentedButton_.AttrCaps


{-| See [`M3e.Element.SegmentedButton.SlotCaps`](M3e.Element.SegmentedButton#SlotCaps).
-}
type alias SegmentedButtonSlotCaps =
    SegmentedButton_.SlotCaps


{-| See [`M3e.Element.SegmentedButton.Content`](M3e.Element.SegmentedButton#Content).
-}
type alias SegmentedButtonContent =
    SegmentedButton_.Content


{-| See [`M3e.Element.SegmentedButton.ChildAdmittedBy`](M3e.Element.SegmentedButton#ChildAdmittedBy).
-}
type alias SegmentedButtonChildAdmittedBy childAdm =
    SegmentedButton_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.SegmentedButton.disabled`](M3e.Element.SegmentedButton#disabled).
-}
segmentedButtonDisabled : Bool -> Attr { c | disabled : Supported } msg
segmentedButtonDisabled =
    SegmentedButton_.disabled


{-| See [`M3e.Element.SegmentedButton.hideSelectionIndicator`](M3e.Element.SegmentedButton#hideSelectionIndicator).
-}
segmentedButtonHideSelectionIndicator : Bool -> Attr { c | hideSelectionIndicator : Supported } msg
segmentedButtonHideSelectionIndicator =
    SegmentedButton_.hideSelectionIndicator


{-| See [`M3e.Element.SegmentedButton.multi`](M3e.Element.SegmentedButton#multi).
-}
segmentedButtonMulti : Bool -> Attr { c | multi : Supported } msg
segmentedButtonMulti =
    SegmentedButton_.multi


{-| See [`M3e.Element.SegmentedButton.name`](M3e.Element.SegmentedButton#name).
-}
segmentedButtonName : String -> Attr { c | name : Supported } msg
segmentedButtonName =
    SegmentedButton_.name


{-| See [`M3e.Element.SegmentedButton.onChange`](M3e.Element.SegmentedButton#onChange).
-}
segmentedButtonOnChange : msg -> Attr { c | onChange : Supported } msg
segmentedButtonOnChange =
    SegmentedButton_.onChange


{-| See [`M3e.Element.SegmentedButton.onBeforeinput`](M3e.Element.SegmentedButton#onBeforeinput).
-}
segmentedButtonOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
segmentedButtonOnBeforeinput =
    SegmentedButton_.onBeforeinput


{-| See [`M3e.Element.SegmentedButton.onInput`](M3e.Element.SegmentedButton#onInput).
-}
segmentedButtonOnInput : msg -> Attr { c | onInput : Supported } msg
segmentedButtonOnInput =
    SegmentedButton_.onInput


{-| See [`M3e.Element.SegmentedButton.child`](M3e.Element.SegmentedButton#child).
-}
segmentedButtonChild : Element SegmentedButtonContent admittedBy msg -> Element free freeAdmittedBy msg
segmentedButtonChild =
    SegmentedButton_.child


{-| The `segment` element of this family — delegates to [`M3e.Element.ButtonSegment.component`](M3e.Element.ButtonSegment#component).
-}
segment :
    List (Attr SegmentAttrs msg)
    -> List (Element SegmentContent (SegmentChildAdmittedBy childAdm) msg)
    -> Element (SegmentIs s) admittedBy msg
segment =
    Segment_.component


{-| See [`M3e.Element.ButtonSegment.Is`](M3e.Element.ButtonSegment#Is).
-}
type alias SegmentIs s =
    Segment_.Is s


{-| See [`M3e.Element.ButtonSegment.Attrs`](M3e.Element.ButtonSegment#Attrs).
-}
type alias SegmentAttrs =
    Segment_.Attrs


{-| See [`M3e.Element.ButtonSegment.Builder`](M3e.Element.ButtonSegment#Builder).
-}
type alias SegmentBuilder attrCaps slotCaps msg kind =
    Segment_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.ButtonSegment.AttrCaps`](M3e.Element.ButtonSegment#AttrCaps).
-}
type alias SegmentAttrCaps =
    Segment_.AttrCaps


{-| See [`M3e.Element.ButtonSegment.SlotCaps`](M3e.Element.ButtonSegment#SlotCaps).
-}
type alias SegmentSlotCaps =
    Segment_.SlotCaps


{-| See [`M3e.Element.ButtonSegment.Content`](M3e.Element.ButtonSegment#Content).
-}
type alias SegmentContent =
    Segment_.Content


{-| See [`M3e.Element.ButtonSegment.IconSlot`](M3e.Element.ButtonSegment#IconSlot).
-}
type alias SegmentIconSlot =
    Segment_.IconSlot


{-| See [`M3e.Element.ButtonSegment.ChildAdmittedBy`](M3e.Element.ButtonSegment#ChildAdmittedBy).
-}
type alias SegmentChildAdmittedBy childAdm =
    Segment_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.ButtonSegment.checked`](M3e.Element.ButtonSegment#checked).
-}
segmentChecked : Bool -> Attr { c | checked : Supported } msg
segmentChecked =
    Segment_.checked


{-| See [`M3e.Element.ButtonSegment.disabled`](M3e.Element.ButtonSegment#disabled).
-}
segmentDisabled : Bool -> Attr { c | disabled : Supported } msg
segmentDisabled =
    Segment_.disabled


{-| See [`M3e.Element.ButtonSegment.value`](M3e.Element.ButtonSegment#value).
-}
segmentValue : String -> Attr { c | value : Supported } msg
segmentValue =
    Segment_.value


{-| See [`M3e.Element.ButtonSegment.defaultChecked`](M3e.Element.ButtonSegment#defaultChecked).
-}
segmentDefaultChecked : Bool -> Attr { c | checked : Supported } msg
segmentDefaultChecked =
    Segment_.defaultChecked


{-| See [`M3e.Element.ButtonSegment.defaultValue`](M3e.Element.ButtonSegment#defaultValue).
-}
segmentDefaultValue : String -> Attr { c | value : Supported } msg
segmentDefaultValue =
    Segment_.defaultValue


{-| See [`M3e.Element.ButtonSegment.onBeforeinput`](M3e.Element.ButtonSegment#onBeforeinput).
-}
segmentOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
segmentOnBeforeinput =
    Segment_.onBeforeinput


{-| See [`M3e.Element.ButtonSegment.onInput`](M3e.Element.ButtonSegment#onInput).
-}
segmentOnInput : msg -> Attr { c | onInput : Supported } msg
segmentOnInput =
    Segment_.onInput


{-| See [`M3e.Element.ButtonSegment.onChange`](M3e.Element.ButtonSegment#onChange).
-}
segmentOnChange : msg -> Attr { c | onChange : Supported } msg
segmentOnChange =
    Segment_.onChange


{-| See [`M3e.Element.ButtonSegment.onClick`](M3e.Element.ButtonSegment#onClick).
-}
segmentOnClick : msg -> Attr { c | onClick : Supported } msg
segmentOnClick =
    Segment_.onClick


{-| See [`M3e.Element.ButtonSegment.icon`](M3e.Element.ButtonSegment#icon).
-}
segmentIcon : Element SegmentIconSlot admittedBy msg -> Element free freeAdmittedBy msg
segmentIcon =
    Segment_.icon


{-| See [`M3e.Element.ButtonSegment.child`](M3e.Element.ButtonSegment#child).
-}
segmentChild : Element SegmentContent admittedBy msg -> Element free freeAdmittedBy msg
segmentChild =
    Segment_.child


{-| The `group` element of this family — delegates to [`M3e.Element.ButtonGroup.component`](M3e.Element.ButtonGroup#component).
-}
group :
    List (Attr GroupAttrs msg)
    -> List (Element GroupContent (GroupChildAdmittedBy childAdm) msg)
    -> Element (GroupIs s) admittedBy msg
group =
    Group_.component


{-| See [`M3e.Element.ButtonGroup.Is`](M3e.Element.ButtonGroup#Is).
-}
type alias GroupIs s =
    Group_.Is s


{-| See [`M3e.Element.ButtonGroup.Attrs`](M3e.Element.ButtonGroup#Attrs).
-}
type alias GroupAttrs =
    Group_.Attrs


{-| See [`M3e.Element.ButtonGroup.Builder`](M3e.Element.ButtonGroup#Builder).
-}
type alias GroupBuilder attrCaps slotCaps msg kind =
    Group_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.ButtonGroup.AttrCaps`](M3e.Element.ButtonGroup#AttrCaps).
-}
type alias GroupAttrCaps =
    Group_.AttrCaps


{-| See [`M3e.Element.ButtonGroup.SlotCaps`](M3e.Element.ButtonGroup#SlotCaps).
-}
type alias GroupSlotCaps =
    Group_.SlotCaps


{-| See [`M3e.Element.ButtonGroup.Content`](M3e.Element.ButtonGroup#Content).
-}
type alias GroupContent =
    Group_.Content


{-| See [`M3e.Element.ButtonGroup.ChildAdmittedBy`](M3e.Element.ButtonGroup#ChildAdmittedBy).
-}
type alias GroupChildAdmittedBy childAdm =
    Group_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.ButtonGroup.Size`](M3e.Element.ButtonGroup#Size).
-}
type alias GroupSize =
    Group_.Size


{-| See [`M3e.Element.ButtonGroup.size`](M3e.Element.ButtonGroup#size).
-}
groupSize : Value GroupSize -> Attr { c | size : Supported } msg
groupSize =
    Group_.size


{-| See [`M3e.Element.ButtonGroup.Variant`](M3e.Element.ButtonGroup#Variant).
-}
type alias GroupVariant =
    Group_.Variant


{-| See [`M3e.Element.ButtonGroup.variant`](M3e.Element.ButtonGroup#variant).
-}
groupVariant : Value GroupVariant -> Attr { c | variant : Supported } msg
groupVariant =
    Group_.variant


{-| See [`M3e.Element.ButtonGroup.multi`](M3e.Element.ButtonGroup#multi).
-}
groupMulti : Bool -> Attr { c | multi : Supported } msg
groupMulti =
    Group_.multi


{-| See [`M3e.Element.ButtonGroup.child`](M3e.Element.ButtonGroup#child).
-}
groupChild : Element GroupContent admittedBy msg -> Element free freeAdmittedBy msg
groupChild =
    Group_.child
