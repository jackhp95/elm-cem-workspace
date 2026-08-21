module M3e.Component.List exposing (ListIs, ListAttrs, ListBuilder, ListAttrCaps, ListSlotCaps, ListContent, ListChildAdmittedBy, ListVariant, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemLeadingSlot, ItemOverlineSlot, ItemSupportingTextSlot, ItemTrailingSlot, ItemChildAdmittedBy, ActionIs, ActionAttrs, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionContent, ActionLeadingSlot, ActionOverlineSlot, ActionSupportingTextSlot, ActionTrailingSlot, ActionChildAdmittedBy, OptionIs, OptionAttrs, OptionBuilder, OptionAttrCaps, OptionSlotCaps, OptionContent, OptionLeadingSlot, OptionOverlineSlot, OptionSupportingTextSlot, OptionTrailingSlot, OptionChildAdmittedBy, list, listVariant, listChild, item, itemLeading, itemOverline, itemSupportingText, itemTrailing, itemChild, action, actionDisabled, actionDownload, actionHref, actionRel, actionTarget, actionOnClick, actionLeading, actionOverline, actionSupportingText, actionTrailing, actionChild, option, optionDisabled, optionSelected, optionValue, optionDefaultSelected, optionDefaultValue, optionOnBeforeinput, optionOnInput, optionOnChange, optionOnClick, optionLeading, optionOverline, optionSupportingText, optionTrailing, optionChild)

{-| The **List** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.List`](M3e.Element.List) as `list`, [`M3e.Element.ListItem`](M3e.Element.ListItem) as `item`, [`M3e.Element.ListAction`](M3e.Element.ListAction) as `action`, [`M3e.Element.ListOption`](M3e.Element.ListOption) as `option`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ListIs, ListAttrs, ListBuilder, ListAttrCaps, ListSlotCaps, ListContent, ListChildAdmittedBy, ListVariant, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemLeadingSlot, ItemOverlineSlot, ItemSupportingTextSlot, ItemTrailingSlot, ItemChildAdmittedBy, ActionIs, ActionAttrs, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionContent, ActionLeadingSlot, ActionOverlineSlot, ActionSupportingTextSlot, ActionTrailingSlot, ActionChildAdmittedBy, OptionIs, OptionAttrs, OptionBuilder, OptionAttrCaps, OptionSlotCaps, OptionContent, OptionLeadingSlot, OptionOverlineSlot, OptionSupportingTextSlot, OptionTrailingSlot, OptionChildAdmittedBy, list, listVariant, listChild, item, itemLeading, itemOverline, itemSupportingText, itemTrailing, itemChild, action, actionDisabled, actionDownload, actionHref, actionRel, actionTarget, actionOnClick, actionLeading, actionOverline, actionSupportingText, actionTrailing, actionChild, option, optionDisabled, optionSelected, optionValue, optionDefaultSelected, optionDefaultValue, optionOnBeforeinput, optionOnInput, optionOnChange, optionOnClick, optionLeading, optionOverline, optionSupportingText, optionTrailing, optionChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.List as List_
import M3e.Element.ListAction as Action_
import M3e.Element.ListItem as Item_
import M3e.Element.ListOption as Option_


{-| The `list` element of this family — delegates to [`M3e.Element.List.component`](M3e.Element.List#component).
-}
list :
    List (Attr ListAttrs msg)
    -> List (Element ListContent (ListChildAdmittedBy childAdm) msg)
    -> Element (ListIs s) admittedBy msg
list =
    List_.component


{-| See [`M3e.Element.List.Is`](M3e.Element.List#Is).
-}
type alias ListIs s =
    List_.Is s


{-| See [`M3e.Element.List.Attrs`](M3e.Element.List#Attrs).
-}
type alias ListAttrs =
    List_.Attrs


{-| See [`M3e.Element.List.Builder`](M3e.Element.List#Builder).
-}
type alias ListBuilder attrCaps slotCaps msg kind =
    List_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.List.AttrCaps`](M3e.Element.List#AttrCaps).
-}
type alias ListAttrCaps =
    List_.AttrCaps


{-| See [`M3e.Element.List.SlotCaps`](M3e.Element.List#SlotCaps).
-}
type alias ListSlotCaps =
    List_.SlotCaps


{-| See [`M3e.Element.List.Content`](M3e.Element.List#Content).
-}
type alias ListContent =
    List_.Content


{-| See [`M3e.Element.List.ChildAdmittedBy`](M3e.Element.List#ChildAdmittedBy).
-}
type alias ListChildAdmittedBy childAdm =
    List_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.List.Variant`](M3e.Element.List#Variant).
-}
type alias ListVariant =
    List_.Variant


{-| See [`M3e.Element.List.variant`](M3e.Element.List#variant).
-}
listVariant : Value ListVariant -> Attr { c | variant : Supported } msg
listVariant =
    List_.variant


{-| See [`M3e.Element.List.child`](M3e.Element.List#child).
-}
listChild : Element ListContent admittedBy msg -> Element free freeAdmittedBy msg
listChild =
    List_.child


{-| The `item` element of this family — delegates to [`M3e.Element.ListItem.component`](M3e.Element.ListItem#component).
-}
item :
    List (Attr ItemAttrs msg)
    -> List (Element ItemContent (ItemChildAdmittedBy childAdm) msg)
    -> Element (ItemIs s) admittedBy msg
item =
    Item_.component


{-| See [`M3e.Element.ListItem.Is`](M3e.Element.ListItem#Is).
-}
type alias ItemIs s =
    Item_.Is s


{-| See [`M3e.Element.ListItem.Attrs`](M3e.Element.ListItem#Attrs).
-}
type alias ItemAttrs =
    Item_.Attrs


{-| See [`M3e.Element.ListItem.Builder`](M3e.Element.ListItem#Builder).
-}
type alias ItemBuilder attrCaps slotCaps msg kind =
    Item_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.ListItem.AttrCaps`](M3e.Element.ListItem#AttrCaps).
-}
type alias ItemAttrCaps =
    Item_.AttrCaps


{-| See [`M3e.Element.ListItem.SlotCaps`](M3e.Element.ListItem#SlotCaps).
-}
type alias ItemSlotCaps =
    Item_.SlotCaps


{-| See [`M3e.Element.ListItem.Content`](M3e.Element.ListItem#Content).
-}
type alias ItemContent =
    Item_.Content


{-| See [`M3e.Element.ListItem.LeadingSlot`](M3e.Element.ListItem#LeadingSlot).
-}
type alias ItemLeadingSlot =
    Item_.LeadingSlot


{-| See [`M3e.Element.ListItem.OverlineSlot`](M3e.Element.ListItem#OverlineSlot).
-}
type alias ItemOverlineSlot =
    Item_.OverlineSlot


{-| See [`M3e.Element.ListItem.SupportingTextSlot`](M3e.Element.ListItem#SupportingTextSlot).
-}
type alias ItemSupportingTextSlot =
    Item_.SupportingTextSlot


{-| See [`M3e.Element.ListItem.TrailingSlot`](M3e.Element.ListItem#TrailingSlot).
-}
type alias ItemTrailingSlot =
    Item_.TrailingSlot


{-| See [`M3e.Element.ListItem.ChildAdmittedBy`](M3e.Element.ListItem#ChildAdmittedBy).
-}
type alias ItemChildAdmittedBy childAdm =
    Item_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.ListItem.leading`](M3e.Element.ListItem#leading).
-}
itemLeading : Element ItemLeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
itemLeading =
    Item_.leading


{-| See [`M3e.Element.ListItem.overline`](M3e.Element.ListItem#overline).
-}
itemOverline : Element ItemOverlineSlot admittedBy msg -> Element free freeAdmittedBy msg
itemOverline =
    Item_.overline


{-| See [`M3e.Element.ListItem.supportingText`](M3e.Element.ListItem#supportingText).
-}
itemSupportingText : Element ItemSupportingTextSlot admittedBy msg -> Element free freeAdmittedBy msg
itemSupportingText =
    Item_.supportingText


{-| See [`M3e.Element.ListItem.trailing`](M3e.Element.ListItem#trailing).
-}
itemTrailing : Element ItemTrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
itemTrailing =
    Item_.trailing


{-| See [`M3e.Element.ListItem.child`](M3e.Element.ListItem#child).
-}
itemChild : Element ItemContent admittedBy msg -> Element free freeAdmittedBy msg
itemChild =
    Item_.child


{-| The `action` element of this family — delegates to [`M3e.Element.ListAction.component`](M3e.Element.ListAction#component).
-}
action :
    List (Attr ActionAttrs msg)
    -> List (Element ActionContent (ActionChildAdmittedBy childAdm) msg)
    -> Element (ActionIs s) admittedBy msg
action =
    Action_.component


{-| See [`M3e.Element.ListAction.Is`](M3e.Element.ListAction#Is).
-}
type alias ActionIs s =
    Action_.Is s


{-| See [`M3e.Element.ListAction.Attrs`](M3e.Element.ListAction#Attrs).
-}
type alias ActionAttrs =
    Action_.Attrs


{-| See [`M3e.Element.ListAction.Builder`](M3e.Element.ListAction#Builder).
-}
type alias ActionBuilder attrCaps slotCaps msg kind =
    Action_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.ListAction.AttrCaps`](M3e.Element.ListAction#AttrCaps).
-}
type alias ActionAttrCaps =
    Action_.AttrCaps


{-| See [`M3e.Element.ListAction.SlotCaps`](M3e.Element.ListAction#SlotCaps).
-}
type alias ActionSlotCaps =
    Action_.SlotCaps


{-| See [`M3e.Element.ListAction.Content`](M3e.Element.ListAction#Content).
-}
type alias ActionContent =
    Action_.Content


{-| See [`M3e.Element.ListAction.LeadingSlot`](M3e.Element.ListAction#LeadingSlot).
-}
type alias ActionLeadingSlot =
    Action_.LeadingSlot


{-| See [`M3e.Element.ListAction.OverlineSlot`](M3e.Element.ListAction#OverlineSlot).
-}
type alias ActionOverlineSlot =
    Action_.OverlineSlot


{-| See [`M3e.Element.ListAction.SupportingTextSlot`](M3e.Element.ListAction#SupportingTextSlot).
-}
type alias ActionSupportingTextSlot =
    Action_.SupportingTextSlot


{-| See [`M3e.Element.ListAction.TrailingSlot`](M3e.Element.ListAction#TrailingSlot).
-}
type alias ActionTrailingSlot =
    Action_.TrailingSlot


{-| See [`M3e.Element.ListAction.ChildAdmittedBy`](M3e.Element.ListAction#ChildAdmittedBy).
-}
type alias ActionChildAdmittedBy childAdm =
    Action_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.ListAction.disabled`](M3e.Element.ListAction#disabled).
-}
actionDisabled : Bool -> Attr { c | disabled : Supported } msg
actionDisabled =
    Action_.disabled


{-| See [`M3e.Element.ListAction.download`](M3e.Element.ListAction#download).
-}
actionDownload : String -> Attr { c | download : Supported } msg
actionDownload =
    Action_.download


{-| See [`M3e.Element.ListAction.href`](M3e.Element.ListAction#href).
-}
actionHref : String -> Attr { c | href : Supported } msg
actionHref =
    Action_.href


{-| See [`M3e.Element.ListAction.rel`](M3e.Element.ListAction#rel).
-}
actionRel : String -> Attr { c | rel : Supported } msg
actionRel =
    Action_.rel


{-| See [`M3e.Element.ListAction.target`](M3e.Element.ListAction#target).
-}
actionTarget : String -> Attr { c | target : Supported } msg
actionTarget =
    Action_.target


{-| See [`M3e.Element.ListAction.onClick`](M3e.Element.ListAction#onClick).
-}
actionOnClick : msg -> Attr { c | onClick : Supported } msg
actionOnClick =
    Action_.onClick


{-| See [`M3e.Element.ListAction.leading`](M3e.Element.ListAction#leading).
-}
actionLeading : Element ActionLeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
actionLeading =
    Action_.leading


{-| See [`M3e.Element.ListAction.overline`](M3e.Element.ListAction#overline).
-}
actionOverline : Element ActionOverlineSlot admittedBy msg -> Element free freeAdmittedBy msg
actionOverline =
    Action_.overline


{-| See [`M3e.Element.ListAction.supportingText`](M3e.Element.ListAction#supportingText).
-}
actionSupportingText : Element ActionSupportingTextSlot admittedBy msg -> Element free freeAdmittedBy msg
actionSupportingText =
    Action_.supportingText


{-| See [`M3e.Element.ListAction.trailing`](M3e.Element.ListAction#trailing).
-}
actionTrailing : Element ActionTrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
actionTrailing =
    Action_.trailing


{-| See [`M3e.Element.ListAction.child`](M3e.Element.ListAction#child).
-}
actionChild : Element ActionContent admittedBy msg -> Element free freeAdmittedBy msg
actionChild =
    Action_.child


{-| The `option` element of this family — delegates to [`M3e.Element.ListOption.component`](M3e.Element.ListOption#component).
-}
option :
    List (Attr OptionAttrs msg)
    -> List (Element OptionContent (OptionChildAdmittedBy childAdm) msg)
    -> Element (OptionIs s) admittedBy msg
option =
    Option_.component


{-| See [`M3e.Element.ListOption.Is`](M3e.Element.ListOption#Is).
-}
type alias OptionIs s =
    Option_.Is s


{-| See [`M3e.Element.ListOption.Attrs`](M3e.Element.ListOption#Attrs).
-}
type alias OptionAttrs =
    Option_.Attrs


{-| See [`M3e.Element.ListOption.Builder`](M3e.Element.ListOption#Builder).
-}
type alias OptionBuilder attrCaps slotCaps msg kind =
    Option_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.ListOption.AttrCaps`](M3e.Element.ListOption#AttrCaps).
-}
type alias OptionAttrCaps =
    Option_.AttrCaps


{-| See [`M3e.Element.ListOption.SlotCaps`](M3e.Element.ListOption#SlotCaps).
-}
type alias OptionSlotCaps =
    Option_.SlotCaps


{-| See [`M3e.Element.ListOption.Content`](M3e.Element.ListOption#Content).
-}
type alias OptionContent =
    Option_.Content


{-| See [`M3e.Element.ListOption.LeadingSlot`](M3e.Element.ListOption#LeadingSlot).
-}
type alias OptionLeadingSlot =
    Option_.LeadingSlot


{-| See [`M3e.Element.ListOption.OverlineSlot`](M3e.Element.ListOption#OverlineSlot).
-}
type alias OptionOverlineSlot =
    Option_.OverlineSlot


{-| See [`M3e.Element.ListOption.SupportingTextSlot`](M3e.Element.ListOption#SupportingTextSlot).
-}
type alias OptionSupportingTextSlot =
    Option_.SupportingTextSlot


{-| See [`M3e.Element.ListOption.TrailingSlot`](M3e.Element.ListOption#TrailingSlot).
-}
type alias OptionTrailingSlot =
    Option_.TrailingSlot


{-| See [`M3e.Element.ListOption.ChildAdmittedBy`](M3e.Element.ListOption#ChildAdmittedBy).
-}
type alias OptionChildAdmittedBy childAdm =
    Option_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.ListOption.disabled`](M3e.Element.ListOption#disabled).
-}
optionDisabled : Bool -> Attr { c | disabled : Supported } msg
optionDisabled =
    Option_.disabled


{-| See [`M3e.Element.ListOption.selected`](M3e.Element.ListOption#selected).
-}
optionSelected : Bool -> Attr { c | selected : Supported } msg
optionSelected =
    Option_.selected


{-| See [`M3e.Element.ListOption.value`](M3e.Element.ListOption#value).
-}
optionValue : String -> Attr { c | value : Supported } msg
optionValue =
    Option_.value


{-| See [`M3e.Element.ListOption.defaultSelected`](M3e.Element.ListOption#defaultSelected).
-}
optionDefaultSelected : Bool -> Attr { c | selected : Supported } msg
optionDefaultSelected =
    Option_.defaultSelected


{-| See [`M3e.Element.ListOption.defaultValue`](M3e.Element.ListOption#defaultValue).
-}
optionDefaultValue : String -> Attr { c | value : Supported } msg
optionDefaultValue =
    Option_.defaultValue


{-| See [`M3e.Element.ListOption.onBeforeinput`](M3e.Element.ListOption#onBeforeinput).
-}
optionOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
optionOnBeforeinput =
    Option_.onBeforeinput


{-| See [`M3e.Element.ListOption.onInput`](M3e.Element.ListOption#onInput).
-}
optionOnInput : msg -> Attr { c | onInput : Supported } msg
optionOnInput =
    Option_.onInput


{-| See [`M3e.Element.ListOption.onChange`](M3e.Element.ListOption#onChange).
-}
optionOnChange : msg -> Attr { c | onChange : Supported } msg
optionOnChange =
    Option_.onChange


{-| See [`M3e.Element.ListOption.onClick`](M3e.Element.ListOption#onClick).
-}
optionOnClick : msg -> Attr { c | onClick : Supported } msg
optionOnClick =
    Option_.onClick


{-| See [`M3e.Element.ListOption.leading`](M3e.Element.ListOption#leading).
-}
optionLeading : Element OptionLeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
optionLeading =
    Option_.leading


{-| See [`M3e.Element.ListOption.overline`](M3e.Element.ListOption#overline).
-}
optionOverline : Element OptionOverlineSlot admittedBy msg -> Element free freeAdmittedBy msg
optionOverline =
    Option_.overline


{-| See [`M3e.Element.ListOption.supportingText`](M3e.Element.ListOption#supportingText).
-}
optionSupportingText : Element OptionSupportingTextSlot admittedBy msg -> Element free freeAdmittedBy msg
optionSupportingText =
    Option_.supportingText


{-| See [`M3e.Element.ListOption.trailing`](M3e.Element.ListOption#trailing).
-}
optionTrailing : Element OptionTrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
optionTrailing =
    Option_.trailing


{-| See [`M3e.Element.ListOption.child`](M3e.Element.ListOption#child).
-}
optionChild : Element OptionContent admittedBy msg -> Element free freeAdmittedBy msg
optionChild =
    Option_.child
