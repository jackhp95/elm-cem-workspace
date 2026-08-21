module M3e.Component.Tree exposing (TreeIs, TreeAttrs, TreeBuilder, TreeAttrCaps, TreeSlotCaps, TreeContent, TreeChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemIconSlot, ItemLabelSlot, ItemOpenToggleIconSlot, ItemSelectedIconSlot, ItemToggleIconSlot, ItemChildAdmittedBy, tree, treeCascade, treeMulti, treeOnChange, treeChild, item, itemDisabled, itemIndeterminate, itemOpen, itemSelected, itemDefaultSelected, itemOnOpening, itemOnOpened, itemOnClosing, itemOnClosed, itemOnClick, itemIcon, itemLabel, itemOpenToggleIcon, itemSelectedIcon, itemToggleIcon, itemChild)

{-| The **Tree** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Tree`](M3e.Element.Tree) as `tree`, [`M3e.Element.TreeItem`](M3e.Element.TreeItem) as `item`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs TreeIs, TreeAttrs, TreeBuilder, TreeAttrCaps, TreeSlotCaps, TreeContent, TreeChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemIconSlot, ItemLabelSlot, ItemOpenToggleIconSlot, ItemSelectedIconSlot, ItemToggleIconSlot, ItemChildAdmittedBy, tree, treeCascade, treeMulti, treeOnChange, treeChild, item, itemDisabled, itemIndeterminate, itemOpen, itemSelected, itemDefaultSelected, itemOnOpening, itemOnOpened, itemOnClosing, itemOnClosed, itemOnClick, itemIcon, itemLabel, itemOpenToggleIcon, itemSelectedIcon, itemToggleIcon, itemChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.Tree as Tree_
import M3e.Element.TreeItem as Item_


{-| The `tree` element of this family — delegates to [`M3e.Element.Tree.component`](M3e.Element.Tree#component).
-}
tree :
    List (Attr TreeAttrs msg)
    -> List (Element TreeContent (TreeChildAdmittedBy childAdm) msg)
    -> Element (TreeIs s) admittedBy msg
tree =
    Tree_.component


{-| See [`M3e.Element.Tree.Is`](M3e.Element.Tree#Is).
-}
type alias TreeIs s =
    Tree_.Is s


{-| See [`M3e.Element.Tree.Attrs`](M3e.Element.Tree#Attrs).
-}
type alias TreeAttrs =
    Tree_.Attrs


{-| See [`M3e.Element.Tree.Builder`](M3e.Element.Tree#Builder).
-}
type alias TreeBuilder attrCaps slotCaps msg kind =
    Tree_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Tree.AttrCaps`](M3e.Element.Tree#AttrCaps).
-}
type alias TreeAttrCaps =
    Tree_.AttrCaps


{-| See [`M3e.Element.Tree.SlotCaps`](M3e.Element.Tree#SlotCaps).
-}
type alias TreeSlotCaps =
    Tree_.SlotCaps


{-| See [`M3e.Element.Tree.Content`](M3e.Element.Tree#Content).
-}
type alias TreeContent =
    Tree_.Content


{-| See [`M3e.Element.Tree.ChildAdmittedBy`](M3e.Element.Tree#ChildAdmittedBy).
-}
type alias TreeChildAdmittedBy childAdm =
    Tree_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Tree.cascade`](M3e.Element.Tree#cascade).
-}
treeCascade : Bool -> Attr { c | cascade : Supported } msg
treeCascade =
    Tree_.cascade


{-| See [`M3e.Element.Tree.multi`](M3e.Element.Tree#multi).
-}
treeMulti : Bool -> Attr { c | multi : Supported } msg
treeMulti =
    Tree_.multi


{-| See [`M3e.Element.Tree.onChange`](M3e.Element.Tree#onChange).
-}
treeOnChange : msg -> Attr { c | onChange : Supported } msg
treeOnChange =
    Tree_.onChange


{-| See [`M3e.Element.Tree.child`](M3e.Element.Tree#child).
-}
treeChild : Element TreeContent admittedBy msg -> Element free freeAdmittedBy msg
treeChild =
    Tree_.child


{-| The `item` element of this family — delegates to [`M3e.Element.TreeItem.component`](M3e.Element.TreeItem#component).
-}
item :
    { label : Element ItemLabelSlot (ItemChildAdmittedBy childAdm) msg }
    -> List (Attr ItemAttrs msg)
    -> List (Element ItemContent (ItemChildAdmittedBy childAdm) msg)
    -> Element (ItemIs s) admittedBy msg
item =
    Item_.component


{-| See [`M3e.Element.TreeItem.Is`](M3e.Element.TreeItem#Is).
-}
type alias ItemIs s =
    Item_.Is s


{-| See [`M3e.Element.TreeItem.Attrs`](M3e.Element.TreeItem#Attrs).
-}
type alias ItemAttrs =
    Item_.Attrs


{-| See [`M3e.Element.TreeItem.Builder`](M3e.Element.TreeItem#Builder).
-}
type alias ItemBuilder attrCaps slotCaps msg kind =
    Item_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.TreeItem.AttrCaps`](M3e.Element.TreeItem#AttrCaps).
-}
type alias ItemAttrCaps =
    Item_.AttrCaps


{-| See [`M3e.Element.TreeItem.SlotCaps`](M3e.Element.TreeItem#SlotCaps).
-}
type alias ItemSlotCaps =
    Item_.SlotCaps


{-| See [`M3e.Element.TreeItem.Content`](M3e.Element.TreeItem#Content).
-}
type alias ItemContent =
    Item_.Content


{-| See [`M3e.Element.TreeItem.IconSlot`](M3e.Element.TreeItem#IconSlot).
-}
type alias ItemIconSlot =
    Item_.IconSlot


{-| See [`M3e.Element.TreeItem.LabelSlot`](M3e.Element.TreeItem#LabelSlot).
-}
type alias ItemLabelSlot =
    Item_.LabelSlot


{-| See [`M3e.Element.TreeItem.OpenToggleIconSlot`](M3e.Element.TreeItem#OpenToggleIconSlot).
-}
type alias ItemOpenToggleIconSlot =
    Item_.OpenToggleIconSlot


{-| See [`M3e.Element.TreeItem.SelectedIconSlot`](M3e.Element.TreeItem#SelectedIconSlot).
-}
type alias ItemSelectedIconSlot =
    Item_.SelectedIconSlot


{-| See [`M3e.Element.TreeItem.ToggleIconSlot`](M3e.Element.TreeItem#ToggleIconSlot).
-}
type alias ItemToggleIconSlot =
    Item_.ToggleIconSlot


{-| See [`M3e.Element.TreeItem.ChildAdmittedBy`](M3e.Element.TreeItem#ChildAdmittedBy).
-}
type alias ItemChildAdmittedBy childAdm =
    Item_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.TreeItem.disabled`](M3e.Element.TreeItem#disabled).
-}
itemDisabled : Bool -> Attr { c | disabled : Supported } msg
itemDisabled =
    Item_.disabled


{-| See [`M3e.Element.TreeItem.indeterminate`](M3e.Element.TreeItem#indeterminate).
-}
itemIndeterminate : Bool -> Attr { c | indeterminate : Supported } msg
itemIndeterminate =
    Item_.indeterminate


{-| See [`M3e.Element.TreeItem.open`](M3e.Element.TreeItem#open).
-}
itemOpen : Bool -> Attr { c | open : Supported } msg
itemOpen =
    Item_.open


{-| See [`M3e.Element.TreeItem.selected`](M3e.Element.TreeItem#selected).
-}
itemSelected : Bool -> Attr { c | selected : Supported } msg
itemSelected =
    Item_.selected


{-| See [`M3e.Element.TreeItem.defaultSelected`](M3e.Element.TreeItem#defaultSelected).
-}
itemDefaultSelected : Bool -> Attr { c | selected : Supported } msg
itemDefaultSelected =
    Item_.defaultSelected


{-| See [`M3e.Element.TreeItem.onOpening`](M3e.Element.TreeItem#onOpening).
-}
itemOnOpening : msg -> Attr { c | onOpening : Supported } msg
itemOnOpening =
    Item_.onOpening


{-| See [`M3e.Element.TreeItem.onOpened`](M3e.Element.TreeItem#onOpened).
-}
itemOnOpened : msg -> Attr { c | onOpened : Supported } msg
itemOnOpened =
    Item_.onOpened


{-| See [`M3e.Element.TreeItem.onClosing`](M3e.Element.TreeItem#onClosing).
-}
itemOnClosing : msg -> Attr { c | onClosing : Supported } msg
itemOnClosing =
    Item_.onClosing


{-| See [`M3e.Element.TreeItem.onClosed`](M3e.Element.TreeItem#onClosed).
-}
itemOnClosed : msg -> Attr { c | onClosed : Supported } msg
itemOnClosed =
    Item_.onClosed


{-| See [`M3e.Element.TreeItem.onClick`](M3e.Element.TreeItem#onClick).
-}
itemOnClick : msg -> Attr { c | onClick : Supported } msg
itemOnClick =
    Item_.onClick


{-| See [`M3e.Element.TreeItem.icon`](M3e.Element.TreeItem#icon).
-}
itemIcon : Element ItemIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemIcon =
    Item_.icon


{-| See [`M3e.Element.TreeItem.label`](M3e.Element.TreeItem#label).
-}
itemLabel : Element ItemLabelSlot admittedBy msg -> Element free freeAdmittedBy msg
itemLabel =
    Item_.label


{-| See [`M3e.Element.TreeItem.openToggleIcon`](M3e.Element.TreeItem#openToggleIcon).
-}
itemOpenToggleIcon : Element ItemOpenToggleIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemOpenToggleIcon =
    Item_.openToggleIcon


{-| See [`M3e.Element.TreeItem.selectedIcon`](M3e.Element.TreeItem#selectedIcon).
-}
itemSelectedIcon : Element ItemSelectedIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemSelectedIcon =
    Item_.selectedIcon


{-| See [`M3e.Element.TreeItem.toggleIcon`](M3e.Element.TreeItem#toggleIcon).
-}
itemToggleIcon : Element ItemToggleIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemToggleIcon =
    Item_.toggleIcon


{-| See [`M3e.Element.TreeItem.child`](M3e.Element.TreeItem#child).
-}
itemChild : Element ItemContent admittedBy msg -> Element free freeAdmittedBy msg
itemChild =
    Item_.child
