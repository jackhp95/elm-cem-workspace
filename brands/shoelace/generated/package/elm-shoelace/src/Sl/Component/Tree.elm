module Sl.Component.Tree exposing (TreeIs, TreeAttrs, TreeBuilder, TreeAttrCaps, TreeSlotCaps, TreeChildAdmittedBy, TreeSelection, tree, treeSelection, treeOnSelectionChange)

{-| The **Tree** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Tree`](Sl.Element.Tree) as `tree`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs TreeIs, TreeAttrs, TreeBuilder, TreeAttrCaps, TreeSlotCaps, TreeChildAdmittedBy, TreeSelection, tree, treeSelection, treeOnSelectionChange

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Tree as Tree_


{-| The `tree` element of this family — delegates to [`Sl.Element.Tree.component`](Sl.Element.Tree#component).
-}
tree :
    List (Attr TreeAttrs msg)
    -> List (Element childAccepts (TreeChildAdmittedBy childAdm) msg)
    -> Element (TreeIs s) admittedBy msg
tree =
    Tree_.component


{-| See [`Sl.Element.Tree.Is`](Sl.Element.Tree#Is).
-}
type alias TreeIs s =
    Tree_.Is s


{-| See [`Sl.Element.Tree.Attrs`](Sl.Element.Tree#Attrs).
-}
type alias TreeAttrs =
    Tree_.Attrs


{-| See [`Sl.Element.Tree.Builder`](Sl.Element.Tree#Builder).
-}
type alias TreeBuilder attrCaps slotCaps msg kind =
    Tree_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Tree.AttrCaps`](Sl.Element.Tree#AttrCaps).
-}
type alias TreeAttrCaps =
    Tree_.AttrCaps


{-| See [`Sl.Element.Tree.SlotCaps`](Sl.Element.Tree#SlotCaps).
-}
type alias TreeSlotCaps =
    Tree_.SlotCaps


{-| See [`Sl.Element.Tree.ChildAdmittedBy`](Sl.Element.Tree#ChildAdmittedBy).
-}
type alias TreeChildAdmittedBy childAdm =
    Tree_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Tree.Selection`](Sl.Element.Tree#Selection).
-}
type alias TreeSelection =
    Tree_.Selection


{-| See [`Sl.Element.Tree.selection`](Sl.Element.Tree#selection).
-}
treeSelection : Value TreeSelection -> Attr { c | selection : Supported } msg
treeSelection =
    Tree_.selection


{-| See [`Sl.Element.Tree.onSelectionChange`](Sl.Element.Tree#onSelectionChange).
-}
treeOnSelectionChange : msg -> Attr { c | onSelectionChange : Supported } msg
treeOnSelectionChange =
    Tree_.onSelectionChange
