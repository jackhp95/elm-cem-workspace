module M3e.Family.List exposing (ListIs, ListAttrs, ListBuilder, ListAttrCaps, ListSlotCaps, ListContent, ListChildAdmittedBy, ListVariant, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemLeadingSlot, ItemOverlineSlot, ItemSupportingTextSlot, ItemTrailingSlot, ItemChildAdmittedBy, ActionIs, ActionAttrs, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionContent, ActionLeadingSlot, ActionOverlineSlot, ActionSupportingTextSlot, ActionTrailingSlot, ActionChildAdmittedBy, OptionIs, OptionAttrs, OptionBuilder, OptionAttrCaps, OptionSlotCaps, OptionContent, OptionLeadingSlot, OptionOverlineSlot, OptionSupportingTextSlot, OptionTrailingSlot, OptionChildAdmittedBy, list, listVariant, listChild, item, itemLeading, itemOverline, itemSupportingText, itemTrailing, itemChild, action, actionDisabled, actionDownload, actionHref, actionRel, actionTarget, actionOnClick, actionLeading, actionOverline, actionSupportingText, actionTrailing, actionChild, option, optionDisabled, optionSelected, optionValue, optionDefaultSelected, optionDefaultValue, optionOnBeforeinput, optionOnInput, optionOnChange, optionOnClick, optionLeading, optionOverline, optionSupportingText, optionTrailing, optionChild)

{-| The **List** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.List`](M3e.Component.List) as `list`, [`M3e.Component.ListItem`](M3e.Component.ListItem) as `item`, [`M3e.Component.ListAction`](M3e.Component.ListAction) as `action`, [`M3e.Component.ListOption`](M3e.Component.ListOption) as `option`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs ListIs, ListAttrs, ListBuilder, ListAttrCaps, ListSlotCaps, ListContent, ListChildAdmittedBy, ListVariant, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemLeadingSlot, ItemOverlineSlot, ItemSupportingTextSlot, ItemTrailingSlot, ItemChildAdmittedBy, ActionIs, ActionAttrs, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionContent, ActionLeadingSlot, ActionOverlineSlot, ActionSupportingTextSlot, ActionTrailingSlot, ActionChildAdmittedBy, OptionIs, OptionAttrs, OptionBuilder, OptionAttrCaps, OptionSlotCaps, OptionContent, OptionLeadingSlot, OptionOverlineSlot, OptionSupportingTextSlot, OptionTrailingSlot, OptionChildAdmittedBy, list, listVariant, listChild, item, itemLeading, itemOverline, itemSupportingText, itemTrailing, itemChild, action, actionDisabled, actionDownload, actionHref, actionRel, actionTarget, actionOnClick, actionLeading, actionOverline, actionSupportingText, actionTrailing, actionChild, option, optionDisabled, optionSelected, optionValue, optionDefaultSelected, optionDefaultValue, optionOnBeforeinput, optionOnInput, optionOnChange, optionOnClick, optionLeading, optionOverline, optionSupportingText, optionTrailing, optionChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Component.List as List_
import M3e.Component.ListAction as Action_
import M3e.Component.ListItem as Item_
import M3e.Component.ListOption as Option_


{-| The `list` element of this family — delegates to [`M3e.Component.List.component`](M3e.Component.List#component).
-}
list :
    List (Attr ListAttrs msg)
    -> List (Element ListContent (ListChildAdmittedBy childAdm) msg)
    -> Element (ListIs s) admittedBy msg
list =
    List_.component


{-| See [`M3e.Component.List.Is`](M3e.Component.List#Is).
-}
type alias ListIs s =
    List_.Is s


{-| See [`M3e.Component.List.Attrs`](M3e.Component.List#Attrs).
-}
type alias ListAttrs =
    List_.Attrs


{-| See [`M3e.Component.List.Builder`](M3e.Component.List#Builder).
-}
type alias ListBuilder attrCaps slotCaps msg kind =
    List_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.List.AttrCaps`](M3e.Component.List#AttrCaps).
-}
type alias ListAttrCaps =
    List_.AttrCaps


{-| See [`M3e.Component.List.SlotCaps`](M3e.Component.List#SlotCaps).
-}
type alias ListSlotCaps =
    List_.SlotCaps


{-| See [`M3e.Component.List.Content`](M3e.Component.List#Content).
-}
type alias ListContent =
    List_.Content


{-| See [`M3e.Component.List.ChildAdmittedBy`](M3e.Component.List#ChildAdmittedBy).
-}
type alias ListChildAdmittedBy childAdm =
    List_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.List.Variant`](M3e.Component.List#Variant).
-}
type alias ListVariant =
    List_.Variant


{-| See [`M3e.Component.List.variant`](M3e.Component.List#variant).
-}
listVariant : Value ListVariant -> Attr { c | variant : Supported } msg
listVariant =
    List_.variant


{-| See [`M3e.Component.List.child`](M3e.Component.List#child).
-}
listChild : Element ListContent admittedBy msg -> Element free freeAdmittedBy msg
listChild =
    List_.child


{-| The `item` element of this family — delegates to [`M3e.Component.ListItem.component`](M3e.Component.ListItem#component).
-}
item :
    List (Attr ItemAttrs msg)
    -> List (Element ItemContent (ItemChildAdmittedBy childAdm) msg)
    -> Element (ItemIs s) admittedBy msg
item =
    Item_.component


{-| See [`M3e.Component.ListItem.Is`](M3e.Component.ListItem#Is).
-}
type alias ItemIs s =
    Item_.Is s


{-| See [`M3e.Component.ListItem.Attrs`](M3e.Component.ListItem#Attrs).
-}
type alias ItemAttrs =
    Item_.Attrs


{-| See [`M3e.Component.ListItem.Builder`](M3e.Component.ListItem#Builder).
-}
type alias ItemBuilder attrCaps slotCaps msg kind =
    Item_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.ListItem.AttrCaps`](M3e.Component.ListItem#AttrCaps).
-}
type alias ItemAttrCaps =
    Item_.AttrCaps


{-| See [`M3e.Component.ListItem.SlotCaps`](M3e.Component.ListItem#SlotCaps).
-}
type alias ItemSlotCaps =
    Item_.SlotCaps


{-| See [`M3e.Component.ListItem.Content`](M3e.Component.ListItem#Content).
-}
type alias ItemContent =
    Item_.Content


{-| See [`M3e.Component.ListItem.LeadingSlot`](M3e.Component.ListItem#LeadingSlot).
-}
type alias ItemLeadingSlot =
    Item_.LeadingSlot


{-| See [`M3e.Component.ListItem.OverlineSlot`](M3e.Component.ListItem#OverlineSlot).
-}
type alias ItemOverlineSlot =
    Item_.OverlineSlot


{-| See [`M3e.Component.ListItem.SupportingTextSlot`](M3e.Component.ListItem#SupportingTextSlot).
-}
type alias ItemSupportingTextSlot =
    Item_.SupportingTextSlot


{-| See [`M3e.Component.ListItem.TrailingSlot`](M3e.Component.ListItem#TrailingSlot).
-}
type alias ItemTrailingSlot =
    Item_.TrailingSlot


{-| See [`M3e.Component.ListItem.ChildAdmittedBy`](M3e.Component.ListItem#ChildAdmittedBy).
-}
type alias ItemChildAdmittedBy childAdm =
    Item_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.ListItem.leading`](M3e.Component.ListItem#leading).
-}
itemLeading : Element ItemLeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
itemLeading =
    Item_.leading


{-| See [`M3e.Component.ListItem.overline`](M3e.Component.ListItem#overline).
-}
itemOverline : Element ItemOverlineSlot admittedBy msg -> Element free freeAdmittedBy msg
itemOverline =
    Item_.overline


{-| See [`M3e.Component.ListItem.supportingText`](M3e.Component.ListItem#supportingText).
-}
itemSupportingText : Element ItemSupportingTextSlot admittedBy msg -> Element free freeAdmittedBy msg
itemSupportingText =
    Item_.supportingText


{-| See [`M3e.Component.ListItem.trailing`](M3e.Component.ListItem#trailing).
-}
itemTrailing : Element ItemTrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
itemTrailing =
    Item_.trailing


{-| See [`M3e.Component.ListItem.child`](M3e.Component.ListItem#child).
-}
itemChild : Element ItemContent admittedBy msg -> Element free freeAdmittedBy msg
itemChild =
    Item_.child


{-| The `action` element of this family — delegates to [`M3e.Component.ListAction.component`](M3e.Component.ListAction#component).
-}
action :
    List (Attr ActionAttrs msg)
    -> List (Element ActionContent (ActionChildAdmittedBy childAdm) msg)
    -> Element (ActionIs s) admittedBy msg
action =
    Action_.component


{-| See [`M3e.Component.ListAction.Is`](M3e.Component.ListAction#Is).
-}
type alias ActionIs s =
    Action_.Is s


{-| See [`M3e.Component.ListAction.Attrs`](M3e.Component.ListAction#Attrs).
-}
type alias ActionAttrs =
    Action_.Attrs


{-| See [`M3e.Component.ListAction.Builder`](M3e.Component.ListAction#Builder).
-}
type alias ActionBuilder attrCaps slotCaps msg kind =
    Action_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.ListAction.AttrCaps`](M3e.Component.ListAction#AttrCaps).
-}
type alias ActionAttrCaps =
    Action_.AttrCaps


{-| See [`M3e.Component.ListAction.SlotCaps`](M3e.Component.ListAction#SlotCaps).
-}
type alias ActionSlotCaps =
    Action_.SlotCaps


{-| See [`M3e.Component.ListAction.Content`](M3e.Component.ListAction#Content).
-}
type alias ActionContent =
    Action_.Content


{-| See [`M3e.Component.ListAction.LeadingSlot`](M3e.Component.ListAction#LeadingSlot).
-}
type alias ActionLeadingSlot =
    Action_.LeadingSlot


{-| See [`M3e.Component.ListAction.OverlineSlot`](M3e.Component.ListAction#OverlineSlot).
-}
type alias ActionOverlineSlot =
    Action_.OverlineSlot


{-| See [`M3e.Component.ListAction.SupportingTextSlot`](M3e.Component.ListAction#SupportingTextSlot).
-}
type alias ActionSupportingTextSlot =
    Action_.SupportingTextSlot


{-| See [`M3e.Component.ListAction.TrailingSlot`](M3e.Component.ListAction#TrailingSlot).
-}
type alias ActionTrailingSlot =
    Action_.TrailingSlot


{-| See [`M3e.Component.ListAction.ChildAdmittedBy`](M3e.Component.ListAction#ChildAdmittedBy).
-}
type alias ActionChildAdmittedBy childAdm =
    Action_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.ListAction.disabled`](M3e.Component.ListAction#disabled).
-}
actionDisabled : Bool -> Attr { c | disabled : Supported } msg
actionDisabled =
    Action_.disabled


{-| See [`M3e.Component.ListAction.download`](M3e.Component.ListAction#download).
-}
actionDownload : String -> Attr { c | download : Supported } msg
actionDownload =
    Action_.download


{-| See [`M3e.Component.ListAction.href`](M3e.Component.ListAction#href).
-}
actionHref : String -> Attr { c | href : Supported } msg
actionHref =
    Action_.href


{-| See [`M3e.Component.ListAction.rel`](M3e.Component.ListAction#rel).
-}
actionRel : String -> Attr { c | rel : Supported } msg
actionRel =
    Action_.rel


{-| See [`M3e.Component.ListAction.target`](M3e.Component.ListAction#target).
-}
actionTarget : String -> Attr { c | target : Supported } msg
actionTarget =
    Action_.target


{-| See [`M3e.Component.ListAction.onClick`](M3e.Component.ListAction#onClick).
-}
actionOnClick : msg -> Attr { c | onClick : Supported } msg
actionOnClick =
    Action_.onClick


{-| See [`M3e.Component.ListAction.leading`](M3e.Component.ListAction#leading).
-}
actionLeading : Element ActionLeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
actionLeading =
    Action_.leading


{-| See [`M3e.Component.ListAction.overline`](M3e.Component.ListAction#overline).
-}
actionOverline : Element ActionOverlineSlot admittedBy msg -> Element free freeAdmittedBy msg
actionOverline =
    Action_.overline


{-| See [`M3e.Component.ListAction.supportingText`](M3e.Component.ListAction#supportingText).
-}
actionSupportingText : Element ActionSupportingTextSlot admittedBy msg -> Element free freeAdmittedBy msg
actionSupportingText =
    Action_.supportingText


{-| See [`M3e.Component.ListAction.trailing`](M3e.Component.ListAction#trailing).
-}
actionTrailing : Element ActionTrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
actionTrailing =
    Action_.trailing


{-| See [`M3e.Component.ListAction.child`](M3e.Component.ListAction#child).
-}
actionChild : Element ActionContent admittedBy msg -> Element free freeAdmittedBy msg
actionChild =
    Action_.child


{-| The `option` element of this family — delegates to [`M3e.Component.ListOption.component`](M3e.Component.ListOption#component).
-}
option :
    List (Attr OptionAttrs msg)
    -> List (Element OptionContent (OptionChildAdmittedBy childAdm) msg)
    -> Element (OptionIs s) admittedBy msg
option =
    Option_.component


{-| See [`M3e.Component.ListOption.Is`](M3e.Component.ListOption#Is).
-}
type alias OptionIs s =
    Option_.Is s


{-| See [`M3e.Component.ListOption.Attrs`](M3e.Component.ListOption#Attrs).
-}
type alias OptionAttrs =
    Option_.Attrs


{-| See [`M3e.Component.ListOption.Builder`](M3e.Component.ListOption#Builder).
-}
type alias OptionBuilder attrCaps slotCaps msg kind =
    Option_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.ListOption.AttrCaps`](M3e.Component.ListOption#AttrCaps).
-}
type alias OptionAttrCaps =
    Option_.AttrCaps


{-| See [`M3e.Component.ListOption.SlotCaps`](M3e.Component.ListOption#SlotCaps).
-}
type alias OptionSlotCaps =
    Option_.SlotCaps


{-| See [`M3e.Component.ListOption.Content`](M3e.Component.ListOption#Content).
-}
type alias OptionContent =
    Option_.Content


{-| See [`M3e.Component.ListOption.LeadingSlot`](M3e.Component.ListOption#LeadingSlot).
-}
type alias OptionLeadingSlot =
    Option_.LeadingSlot


{-| See [`M3e.Component.ListOption.OverlineSlot`](M3e.Component.ListOption#OverlineSlot).
-}
type alias OptionOverlineSlot =
    Option_.OverlineSlot


{-| See [`M3e.Component.ListOption.SupportingTextSlot`](M3e.Component.ListOption#SupportingTextSlot).
-}
type alias OptionSupportingTextSlot =
    Option_.SupportingTextSlot


{-| See [`M3e.Component.ListOption.TrailingSlot`](M3e.Component.ListOption#TrailingSlot).
-}
type alias OptionTrailingSlot =
    Option_.TrailingSlot


{-| See [`M3e.Component.ListOption.ChildAdmittedBy`](M3e.Component.ListOption#ChildAdmittedBy).
-}
type alias OptionChildAdmittedBy childAdm =
    Option_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.ListOption.disabled`](M3e.Component.ListOption#disabled).
-}
optionDisabled : Bool -> Attr { c | disabled : Supported } msg
optionDisabled =
    Option_.disabled


{-| See [`M3e.Component.ListOption.selected`](M3e.Component.ListOption#selected).
-}
optionSelected : Bool -> Attr { c | selected : Supported } msg
optionSelected =
    Option_.selected


{-| See [`M3e.Component.ListOption.value`](M3e.Component.ListOption#value).
-}
optionValue : String -> Attr { c | value : Supported } msg
optionValue =
    Option_.value


{-| See [`M3e.Component.ListOption.defaultSelected`](M3e.Component.ListOption#defaultSelected).
-}
optionDefaultSelected : Bool -> Attr { c | selected : Supported } msg
optionDefaultSelected =
    Option_.defaultSelected


{-| See [`M3e.Component.ListOption.defaultValue`](M3e.Component.ListOption#defaultValue).
-}
optionDefaultValue : String -> Attr { c | value : Supported } msg
optionDefaultValue =
    Option_.defaultValue


{-| See [`M3e.Component.ListOption.onBeforeinput`](M3e.Component.ListOption#onBeforeinput).
-}
optionOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
optionOnBeforeinput =
    Option_.onBeforeinput


{-| See [`M3e.Component.ListOption.onInput`](M3e.Component.ListOption#onInput).
-}
optionOnInput : msg -> Attr { c | onInput : Supported } msg
optionOnInput =
    Option_.onInput


{-| See [`M3e.Component.ListOption.onChange`](M3e.Component.ListOption#onChange).
-}
optionOnChange : msg -> Attr { c | onChange : Supported } msg
optionOnChange =
    Option_.onChange


{-| See [`M3e.Component.ListOption.onClick`](M3e.Component.ListOption#onClick).
-}
optionOnClick : msg -> Attr { c | onClick : Supported } msg
optionOnClick =
    Option_.onClick


{-| See [`M3e.Component.ListOption.leading`](M3e.Component.ListOption#leading).
-}
optionLeading : Element OptionLeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
optionLeading =
    Option_.leading


{-| See [`M3e.Component.ListOption.overline`](M3e.Component.ListOption#overline).
-}
optionOverline : Element OptionOverlineSlot admittedBy msg -> Element free freeAdmittedBy msg
optionOverline =
    Option_.overline


{-| See [`M3e.Component.ListOption.supportingText`](M3e.Component.ListOption#supportingText).
-}
optionSupportingText : Element OptionSupportingTextSlot admittedBy msg -> Element free freeAdmittedBy msg
optionSupportingText =
    Option_.supportingText


{-| See [`M3e.Component.ListOption.trailing`](M3e.Component.ListOption#trailing).
-}
optionTrailing : Element OptionTrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
optionTrailing =
    Option_.trailing


{-| See [`M3e.Component.ListOption.child`](M3e.Component.ListOption#child).
-}
optionChild : Element OptionContent admittedBy msg -> Element free freeAdmittedBy msg
optionChild =
    Option_.child
