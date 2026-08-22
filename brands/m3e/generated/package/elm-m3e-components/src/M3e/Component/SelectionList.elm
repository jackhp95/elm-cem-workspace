module M3e.Component.SelectionList exposing (SelectionListIs, SelectionListAttrs, SelectionListBuilder, SelectionListAttrCaps, SelectionListSlotCaps, SelectionListContent, SelectionListChildAdmittedBy, SelectionListVariant, selectionList, selectionListVariant, selectionListDisabled, selectionListHideSelectionIndicator, selectionListMulti, selectionListName, selectionListOnChange, selectionListOnBeforeinput, selectionListOnInput, selectionListChild)

{-| The **SelectionList** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.SelectionList`](M3e.Element.SelectionList) as `selectionList`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SelectionListIs, SelectionListAttrs, SelectionListBuilder, SelectionListAttrCaps, SelectionListSlotCaps, SelectionListContent, SelectionListChildAdmittedBy, SelectionListVariant, selectionList, selectionListVariant, selectionListDisabled, selectionListHideSelectionIndicator, selectionListMulti, selectionListName, selectionListOnChange, selectionListOnBeforeinput, selectionListOnInput, selectionListChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.SelectionList as SelectionList_


{-| The `selectionList` element of this family — delegates to [`M3e.Element.SelectionList.component`](M3e.Element.SelectionList#component).
-}
selectionList :
    List (Attr SelectionListAttrs msg)
    -> List (Element SelectionListContent (SelectionListChildAdmittedBy childAdm) msg)
    -> Element (SelectionListIs s) admittedBy msg
selectionList =
    SelectionList_.component


{-| See [`M3e.Element.SelectionList.Is`](M3e.Element.SelectionList#Is).
-}
type alias SelectionListIs s =
    SelectionList_.Is s


{-| See [`M3e.Element.SelectionList.Attrs`](M3e.Element.SelectionList#Attrs).
-}
type alias SelectionListAttrs =
    SelectionList_.Attrs


{-| See [`M3e.Element.SelectionList.Builder`](M3e.Element.SelectionList#Builder).
-}
type alias SelectionListBuilder attrCaps slotCaps msg kind =
    SelectionList_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.SelectionList.AttrCaps`](M3e.Element.SelectionList#AttrCaps).
-}
type alias SelectionListAttrCaps =
    SelectionList_.AttrCaps


{-| See [`M3e.Element.SelectionList.SlotCaps`](M3e.Element.SelectionList#SlotCaps).
-}
type alias SelectionListSlotCaps =
    SelectionList_.SlotCaps


{-| See [`M3e.Element.SelectionList.Content`](M3e.Element.SelectionList#Content).
-}
type alias SelectionListContent =
    SelectionList_.Content


{-| See [`M3e.Element.SelectionList.ChildAdmittedBy`](M3e.Element.SelectionList#ChildAdmittedBy).
-}
type alias SelectionListChildAdmittedBy childAdm =
    SelectionList_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.SelectionList.Variant`](M3e.Element.SelectionList#Variant).
-}
type alias SelectionListVariant =
    SelectionList_.Variant


{-| See [`M3e.Element.SelectionList.variant`](M3e.Element.SelectionList#variant).
-}
selectionListVariant : Value SelectionListVariant -> Attr { c | variant : Supported } msg
selectionListVariant =
    SelectionList_.variant


{-| See [`M3e.Element.SelectionList.disabled`](M3e.Element.SelectionList#disabled).
-}
selectionListDisabled : Bool -> Attr { c | disabled : Supported } msg
selectionListDisabled =
    SelectionList_.disabled


{-| See [`M3e.Element.SelectionList.hideSelectionIndicator`](M3e.Element.SelectionList#hideSelectionIndicator).
-}
selectionListHideSelectionIndicator : Bool -> Attr { c | hideSelectionIndicator : Supported } msg
selectionListHideSelectionIndicator =
    SelectionList_.hideSelectionIndicator


{-| See [`M3e.Element.SelectionList.multi`](M3e.Element.SelectionList#multi).
-}
selectionListMulti : Bool -> Attr { c | multi : Supported } msg
selectionListMulti =
    SelectionList_.multi


{-| See [`M3e.Element.SelectionList.name`](M3e.Element.SelectionList#name).
-}
selectionListName : String -> Attr { c | name : Supported } msg
selectionListName =
    SelectionList_.name


{-| See [`M3e.Element.SelectionList.onChange`](M3e.Element.SelectionList#onChange).
-}
selectionListOnChange : msg -> Attr { c | onChange : Supported } msg
selectionListOnChange =
    SelectionList_.onChange


{-| See [`M3e.Element.SelectionList.onBeforeinput`](M3e.Element.SelectionList#onBeforeinput).
-}
selectionListOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
selectionListOnBeforeinput =
    SelectionList_.onBeforeinput


{-| See [`M3e.Element.SelectionList.onInput`](M3e.Element.SelectionList#onInput).
-}
selectionListOnInput : msg -> Attr { c | onInput : Supported } msg
selectionListOnInput =
    SelectionList_.onInput


{-| See [`M3e.Element.SelectionList.child`](M3e.Element.SelectionList#child).
-}
selectionListChild : Element SelectionListContent admittedBy msg -> Element free freeAdmittedBy msg
selectionListChild =
    SelectionList_.child
