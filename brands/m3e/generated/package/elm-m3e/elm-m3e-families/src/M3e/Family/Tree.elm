module M3e.Family.Tree exposing (TreeIs, TreeAttrs, TreeBuilder, TreeAttrCaps, TreeSlotCaps, TreeContent, TreeChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemIconSlot, ItemLabelSlot, ItemOpenToggleIconSlot, ItemSelectedIconSlot, ItemToggleIconSlot, ItemChildAdmittedBy, tree, treeCascade, treeMulti, treeOnChange, treeChild, item, itemDisabled, itemIndeterminate, itemOpen, itemSelected, itemDefaultSelected, itemOnOpening, itemOnOpened, itemOnClosing, itemOnClosed, itemOnClick, itemIcon, itemLabel, itemOpenToggleIcon, itemSelectedIcon, itemToggleIcon, itemChild)

{-| The **Tree** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.Tree`](M3e.Component.Tree) as `tree`, [`M3e.Component.TreeItem`](M3e.Component.TreeItem) as `item`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs TreeIs, TreeAttrs, TreeBuilder, TreeAttrCaps, TreeSlotCaps, TreeContent, TreeChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemIconSlot, ItemLabelSlot, ItemOpenToggleIconSlot, ItemSelectedIconSlot, ItemToggleIconSlot, ItemChildAdmittedBy, tree, treeCascade, treeMulti, treeOnChange, treeChild, item, itemDisabled, itemIndeterminate, itemOpen, itemSelected, itemDefaultSelected, itemOnOpening, itemOnOpened, itemOnClosing, itemOnClosed, itemOnClick, itemIcon, itemLabel, itemOpenToggleIcon, itemSelectedIcon, itemToggleIcon, itemChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Component.Tree as Tree_
import M3e.Component.TreeItem as Item_


{-| The `tree` element of this family — delegates to [`M3e.Component.Tree.component`](M3e.Component.Tree#component).
-}
tree :
    List (Attr TreeAttrs msg)
    -> List (Element TreeContent (TreeChildAdmittedBy childAdm) msg)
    -> Element (TreeIs s) admittedBy msg
tree =
    Tree_.component


{-| See [`M3e.Component.Tree.Is`](M3e.Component.Tree#Is).
-}
type alias TreeIs s =
    Tree_.Is s


{-| See [`M3e.Component.Tree.Attrs`](M3e.Component.Tree#Attrs).
-}
type alias TreeAttrs =
    Tree_.Attrs


{-| See [`M3e.Component.Tree.Builder`](M3e.Component.Tree#Builder).
-}
type alias TreeBuilder attrCaps slotCaps msg kind =
    Tree_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.Tree.AttrCaps`](M3e.Component.Tree#AttrCaps).
-}
type alias TreeAttrCaps =
    Tree_.AttrCaps


{-| See [`M3e.Component.Tree.SlotCaps`](M3e.Component.Tree#SlotCaps).
-}
type alias TreeSlotCaps =
    Tree_.SlotCaps


{-| See [`M3e.Component.Tree.Content`](M3e.Component.Tree#Content).
-}
type alias TreeContent =
    Tree_.Content


{-| See [`M3e.Component.Tree.ChildAdmittedBy`](M3e.Component.Tree#ChildAdmittedBy).
-}
type alias TreeChildAdmittedBy childAdm =
    Tree_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.Tree.cascade`](M3e.Component.Tree#cascade).
-}
treeCascade : Bool -> Attr { c | cascade : Supported } msg
treeCascade =
    Tree_.cascade


{-| See [`M3e.Component.Tree.multi`](M3e.Component.Tree#multi).
-}
treeMulti : Bool -> Attr { c | multi : Supported } msg
treeMulti =
    Tree_.multi


{-| See [`M3e.Component.Tree.onChange`](M3e.Component.Tree#onChange).
-}
treeOnChange : msg -> Attr { c | onChange : Supported } msg
treeOnChange =
    Tree_.onChange


{-| See [`M3e.Component.Tree.child`](M3e.Component.Tree#child).
-}
treeChild : Element TreeContent admittedBy msg -> Element free freeAdmittedBy msg
treeChild =
    Tree_.child


{-| The `item` element of this family — delegates to [`M3e.Component.TreeItem.component`](M3e.Component.TreeItem#component).
-}
item :
    { label : Element ItemLabelSlot (ItemChildAdmittedBy childAdm) msg }
    -> List (Attr ItemAttrs msg)
    -> List (Element ItemContent (ItemChildAdmittedBy childAdm) msg)
    -> Element (ItemIs s) admittedBy msg
item =
    Item_.component


{-| See [`M3e.Component.TreeItem.Is`](M3e.Component.TreeItem#Is).
-}
type alias ItemIs s =
    Item_.Is s


{-| See [`M3e.Component.TreeItem.Attrs`](M3e.Component.TreeItem#Attrs).
-}
type alias ItemAttrs =
    Item_.Attrs


{-| See [`M3e.Component.TreeItem.Builder`](M3e.Component.TreeItem#Builder).
-}
type alias ItemBuilder attrCaps slotCaps msg kind =
    Item_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.TreeItem.AttrCaps`](M3e.Component.TreeItem#AttrCaps).
-}
type alias ItemAttrCaps =
    Item_.AttrCaps


{-| See [`M3e.Component.TreeItem.SlotCaps`](M3e.Component.TreeItem#SlotCaps).
-}
type alias ItemSlotCaps =
    Item_.SlotCaps


{-| See [`M3e.Component.TreeItem.Content`](M3e.Component.TreeItem#Content).
-}
type alias ItemContent =
    Item_.Content


{-| See [`M3e.Component.TreeItem.IconSlot`](M3e.Component.TreeItem#IconSlot).
-}
type alias ItemIconSlot =
    Item_.IconSlot


{-| See [`M3e.Component.TreeItem.LabelSlot`](M3e.Component.TreeItem#LabelSlot).
-}
type alias ItemLabelSlot =
    Item_.LabelSlot


{-| See [`M3e.Component.TreeItem.OpenToggleIconSlot`](M3e.Component.TreeItem#OpenToggleIconSlot).
-}
type alias ItemOpenToggleIconSlot =
    Item_.OpenToggleIconSlot


{-| See [`M3e.Component.TreeItem.SelectedIconSlot`](M3e.Component.TreeItem#SelectedIconSlot).
-}
type alias ItemSelectedIconSlot =
    Item_.SelectedIconSlot


{-| See [`M3e.Component.TreeItem.ToggleIconSlot`](M3e.Component.TreeItem#ToggleIconSlot).
-}
type alias ItemToggleIconSlot =
    Item_.ToggleIconSlot


{-| See [`M3e.Component.TreeItem.ChildAdmittedBy`](M3e.Component.TreeItem#ChildAdmittedBy).
-}
type alias ItemChildAdmittedBy childAdm =
    Item_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.TreeItem.disabled`](M3e.Component.TreeItem#disabled).
-}
itemDisabled : Bool -> Attr { c | disabled : Supported } msg
itemDisabled =
    Item_.disabled


{-| See [`M3e.Component.TreeItem.indeterminate`](M3e.Component.TreeItem#indeterminate).
-}
itemIndeterminate : Bool -> Attr { c | indeterminate : Supported } msg
itemIndeterminate =
    Item_.indeterminate


{-| See [`M3e.Component.TreeItem.open`](M3e.Component.TreeItem#open).
-}
itemOpen : Bool -> Attr { c | open : Supported } msg
itemOpen =
    Item_.open


{-| See [`M3e.Component.TreeItem.selected`](M3e.Component.TreeItem#selected).
-}
itemSelected : Bool -> Attr { c | selected : Supported } msg
itemSelected =
    Item_.selected


{-| See [`M3e.Component.TreeItem.defaultSelected`](M3e.Component.TreeItem#defaultSelected).
-}
itemDefaultSelected : Bool -> Attr { c | selected : Supported } msg
itemDefaultSelected =
    Item_.defaultSelected


{-| See [`M3e.Component.TreeItem.onOpening`](M3e.Component.TreeItem#onOpening).
-}
itemOnOpening : msg -> Attr { c | onOpening : Supported } msg
itemOnOpening =
    Item_.onOpening


{-| See [`M3e.Component.TreeItem.onOpened`](M3e.Component.TreeItem#onOpened).
-}
itemOnOpened : msg -> Attr { c | onOpened : Supported } msg
itemOnOpened =
    Item_.onOpened


{-| See [`M3e.Component.TreeItem.onClosing`](M3e.Component.TreeItem#onClosing).
-}
itemOnClosing : msg -> Attr { c | onClosing : Supported } msg
itemOnClosing =
    Item_.onClosing


{-| See [`M3e.Component.TreeItem.onClosed`](M3e.Component.TreeItem#onClosed).
-}
itemOnClosed : msg -> Attr { c | onClosed : Supported } msg
itemOnClosed =
    Item_.onClosed


{-| See [`M3e.Component.TreeItem.onClick`](M3e.Component.TreeItem#onClick).
-}
itemOnClick : msg -> Attr { c | onClick : Supported } msg
itemOnClick =
    Item_.onClick


{-| See [`M3e.Component.TreeItem.icon`](M3e.Component.TreeItem#icon).
-}
itemIcon : Element ItemIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemIcon =
    Item_.icon


{-| See [`M3e.Component.TreeItem.label`](M3e.Component.TreeItem#label).
-}
itemLabel : Element ItemLabelSlot admittedBy msg -> Element free freeAdmittedBy msg
itemLabel =
    Item_.label


{-| See [`M3e.Component.TreeItem.openToggleIcon`](M3e.Component.TreeItem#openToggleIcon).
-}
itemOpenToggleIcon : Element ItemOpenToggleIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemOpenToggleIcon =
    Item_.openToggleIcon


{-| See [`M3e.Component.TreeItem.selectedIcon`](M3e.Component.TreeItem#selectedIcon).
-}
itemSelectedIcon : Element ItemSelectedIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemSelectedIcon =
    Item_.selectedIcon


{-| See [`M3e.Component.TreeItem.toggleIcon`](M3e.Component.TreeItem#toggleIcon).
-}
itemToggleIcon : Element ItemToggleIconSlot admittedBy msg -> Element free freeAdmittedBy msg
itemToggleIcon =
    Item_.toggleIcon


{-| See [`M3e.Component.TreeItem.child`](M3e.Component.TreeItem#child).
-}
itemChild : Element ItemContent admittedBy msg -> Element free freeAdmittedBy msg
itemChild =
    Item_.child
