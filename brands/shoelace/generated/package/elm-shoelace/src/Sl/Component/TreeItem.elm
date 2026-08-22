module Sl.Component.TreeItem exposing (TreeItemIs, TreeItemAttrs, TreeItemBuilder, TreeItemAttrCaps, TreeItemSlotCaps, TreeItemChildAdmittedBy, treeItem, treeItemDisabled, treeItemExpanded, treeItemLazy, treeItemSelected, treeItemDefaultSelected, treeItemOnExpand, treeItemOnAfterExpand, treeItemOnCollapse, treeItemOnAfterCollapse, treeItemOnLazyChange, treeItemOnLazyLoad)

{-| The **TreeItem** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.TreeItem`](Sl.Element.TreeItem) as `treeItem`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs TreeItemIs, TreeItemAttrs, TreeItemBuilder, TreeItemAttrCaps, TreeItemSlotCaps, TreeItemChildAdmittedBy, treeItem, treeItemDisabled, treeItemExpanded, treeItemLazy, treeItemSelected, treeItemDefaultSelected, treeItemOnExpand, treeItemOnAfterExpand, treeItemOnCollapse, treeItemOnAfterCollapse, treeItemOnLazyChange, treeItemOnLazyLoad

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.TreeItem as TreeItem_


{-| The `treeItem` element of this family — delegates to [`Sl.Element.TreeItem.component`](Sl.Element.TreeItem#component).
-}
treeItem :
    List (Attr TreeItemAttrs msg)
    -> List (Element childAccepts (TreeItemChildAdmittedBy childAdm) msg)
    -> Element (TreeItemIs s) admittedBy msg
treeItem =
    TreeItem_.component


{-| See [`Sl.Element.TreeItem.Is`](Sl.Element.TreeItem#Is).
-}
type alias TreeItemIs s =
    TreeItem_.Is s


{-| See [`Sl.Element.TreeItem.Attrs`](Sl.Element.TreeItem#Attrs).
-}
type alias TreeItemAttrs =
    TreeItem_.Attrs


{-| See [`Sl.Element.TreeItem.Builder`](Sl.Element.TreeItem#Builder).
-}
type alias TreeItemBuilder attrCaps slotCaps msg kind =
    TreeItem_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.TreeItem.AttrCaps`](Sl.Element.TreeItem#AttrCaps).
-}
type alias TreeItemAttrCaps =
    TreeItem_.AttrCaps


{-| See [`Sl.Element.TreeItem.SlotCaps`](Sl.Element.TreeItem#SlotCaps).
-}
type alias TreeItemSlotCaps =
    TreeItem_.SlotCaps


{-| See [`Sl.Element.TreeItem.ChildAdmittedBy`](Sl.Element.TreeItem#ChildAdmittedBy).
-}
type alias TreeItemChildAdmittedBy childAdm =
    TreeItem_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.TreeItem.disabled`](Sl.Element.TreeItem#disabled).
-}
treeItemDisabled : Bool -> Attr { c | disabled : Supported } msg
treeItemDisabled =
    TreeItem_.disabled


{-| See [`Sl.Element.TreeItem.expanded`](Sl.Element.TreeItem#expanded).
-}
treeItemExpanded : Bool -> Attr { c | expanded : Supported } msg
treeItemExpanded =
    TreeItem_.expanded


{-| See [`Sl.Element.TreeItem.lazy`](Sl.Element.TreeItem#lazy).
-}
treeItemLazy : Bool -> Attr { c | lazy : Supported } msg
treeItemLazy =
    TreeItem_.lazy


{-| See [`Sl.Element.TreeItem.selected`](Sl.Element.TreeItem#selected).
-}
treeItemSelected : Bool -> Attr { c | selected : Supported } msg
treeItemSelected =
    TreeItem_.selected


{-| See [`Sl.Element.TreeItem.defaultSelected`](Sl.Element.TreeItem#defaultSelected).
-}
treeItemDefaultSelected : Bool -> Attr { c | selected : Supported } msg
treeItemDefaultSelected =
    TreeItem_.defaultSelected


{-| See [`Sl.Element.TreeItem.onExpand`](Sl.Element.TreeItem#onExpand).
-}
treeItemOnExpand : msg -> Attr { c | onExpand : Supported } msg
treeItemOnExpand =
    TreeItem_.onExpand


{-| See [`Sl.Element.TreeItem.onAfterExpand`](Sl.Element.TreeItem#onAfterExpand).
-}
treeItemOnAfterExpand : msg -> Attr { c | onAfterExpand : Supported } msg
treeItemOnAfterExpand =
    TreeItem_.onAfterExpand


{-| See [`Sl.Element.TreeItem.onCollapse`](Sl.Element.TreeItem#onCollapse).
-}
treeItemOnCollapse : msg -> Attr { c | onCollapse : Supported } msg
treeItemOnCollapse =
    TreeItem_.onCollapse


{-| See [`Sl.Element.TreeItem.onAfterCollapse`](Sl.Element.TreeItem#onAfterCollapse).
-}
treeItemOnAfterCollapse : msg -> Attr { c | onAfterCollapse : Supported } msg
treeItemOnAfterCollapse =
    TreeItem_.onAfterCollapse


{-| See [`Sl.Element.TreeItem.onLazyChange`](Sl.Element.TreeItem#onLazyChange).
-}
treeItemOnLazyChange : msg -> Attr { c | onLazyChange : Supported } msg
treeItemOnLazyChange =
    TreeItem_.onLazyChange


{-| See [`Sl.Element.TreeItem.onLazyLoad`](Sl.Element.TreeItem#onLazyLoad).
-}
treeItemOnLazyLoad : msg -> Attr { c | onLazyLoad : Supported } msg
treeItemOnLazyLoad =
    TreeItem_.onLazyLoad
