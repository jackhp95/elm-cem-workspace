module M3e.Family.Toc exposing (TocIs, TocAttrs, TocBuilder, TocAttrCaps, TocSlotCaps, TocOverlineSlot, TocTitleSlot, TocChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemChildAdmittedBy, toc, tocFor, tocMaxDepth, tocOverline, tocTitle, tocChild, item, itemDisabled, itemSelected, itemDefaultSelected, itemOnClick, itemChild)

{-| The **Toc** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.Toc`](M3e.Component.Toc) as `toc`, [`M3e.Component.TocItem`](M3e.Component.TocItem) as `item`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs TocIs, TocAttrs, TocBuilder, TocAttrCaps, TocSlotCaps, TocOverlineSlot, TocTitleSlot, TocChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemChildAdmittedBy, toc, tocFor, tocMaxDepth, tocOverline, tocTitle, tocChild, item, itemDisabled, itemSelected, itemDefaultSelected, itemOnClick, itemChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Component.Toc as Toc_
import M3e.Component.TocItem as Item_


{-| The `toc` element of this family — delegates to [`M3e.Component.Toc.component`](M3e.Component.Toc#component).
-}
toc :
    List (Attr TocAttrs msg)
    -> List (Element childAccepts (TocChildAdmittedBy childAdm) msg)
    -> Element (TocIs s) admittedBy msg
toc =
    Toc_.component


{-| See [`M3e.Component.Toc.Is`](M3e.Component.Toc#Is).
-}
type alias TocIs s =
    Toc_.Is s


{-| See [`M3e.Component.Toc.Attrs`](M3e.Component.Toc#Attrs).
-}
type alias TocAttrs =
    Toc_.Attrs


{-| See [`M3e.Component.Toc.Builder`](M3e.Component.Toc#Builder).
-}
type alias TocBuilder attrCaps slotCaps msg kind =
    Toc_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.Toc.AttrCaps`](M3e.Component.Toc#AttrCaps).
-}
type alias TocAttrCaps =
    Toc_.AttrCaps


{-| See [`M3e.Component.Toc.SlotCaps`](M3e.Component.Toc#SlotCaps).
-}
type alias TocSlotCaps =
    Toc_.SlotCaps


{-| See [`M3e.Component.Toc.OverlineSlot`](M3e.Component.Toc#OverlineSlot).
-}
type alias TocOverlineSlot =
    Toc_.OverlineSlot


{-| See [`M3e.Component.Toc.TitleSlot`](M3e.Component.Toc#TitleSlot).
-}
type alias TocTitleSlot =
    Toc_.TitleSlot


{-| See [`M3e.Component.Toc.ChildAdmittedBy`](M3e.Component.Toc#ChildAdmittedBy).
-}
type alias TocChildAdmittedBy childAdm =
    Toc_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.Toc.for`](M3e.Component.Toc#for).
-}
tocFor : String -> Attr { c | for : Supported } msg
tocFor =
    Toc_.for


{-| See [`M3e.Component.Toc.maxDepth`](M3e.Component.Toc#maxDepth).
-}
tocMaxDepth : Float -> Attr { c | maxDepth : Supported } msg
tocMaxDepth =
    Toc_.maxDepth


{-| See [`M3e.Component.Toc.overline`](M3e.Component.Toc#overline).
-}
tocOverline : Element TocOverlineSlot admittedBy msg -> Element free freeAdmittedBy msg
tocOverline =
    Toc_.overline


{-| See [`M3e.Component.Toc.title`](M3e.Component.Toc#title).
-}
tocTitle : Element TocTitleSlot admittedBy msg -> Element free freeAdmittedBy msg
tocTitle =
    Toc_.title


{-| See [`M3e.Component.Toc.child`](M3e.Component.Toc#child).
-}
tocChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
tocChild =
    Toc_.child


{-| The `item` element of this family — delegates to [`M3e.Component.TocItem.component`](M3e.Component.TocItem#component).
-}
item :
    { content : Element ItemContent (ItemChildAdmittedBy childAdm) msg }
    -> List (Attr ItemAttrs msg)
    -> List (Element ItemContent (ItemChildAdmittedBy childAdm) msg)
    -> Element (ItemIs s) admittedBy msg
item =
    Item_.component


{-| See [`M3e.Component.TocItem.Is`](M3e.Component.TocItem#Is).
-}
type alias ItemIs s =
    Item_.Is s


{-| See [`M3e.Component.TocItem.Attrs`](M3e.Component.TocItem#Attrs).
-}
type alias ItemAttrs =
    Item_.Attrs


{-| See [`M3e.Component.TocItem.Builder`](M3e.Component.TocItem#Builder).
-}
type alias ItemBuilder attrCaps slotCaps msg kind =
    Item_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.TocItem.AttrCaps`](M3e.Component.TocItem#AttrCaps).
-}
type alias ItemAttrCaps =
    Item_.AttrCaps


{-| See [`M3e.Component.TocItem.SlotCaps`](M3e.Component.TocItem#SlotCaps).
-}
type alias ItemSlotCaps =
    Item_.SlotCaps


{-| See [`M3e.Component.TocItem.Content`](M3e.Component.TocItem#Content).
-}
type alias ItemContent =
    Item_.Content


{-| See [`M3e.Component.TocItem.ChildAdmittedBy`](M3e.Component.TocItem#ChildAdmittedBy).
-}
type alias ItemChildAdmittedBy childAdm =
    Item_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.TocItem.disabled`](M3e.Component.TocItem#disabled).
-}
itemDisabled : Bool -> Attr { c | disabled : Supported } msg
itemDisabled =
    Item_.disabled


{-| See [`M3e.Component.TocItem.selected`](M3e.Component.TocItem#selected).
-}
itemSelected : Bool -> Attr { c | selected : Supported } msg
itemSelected =
    Item_.selected


{-| See [`M3e.Component.TocItem.defaultSelected`](M3e.Component.TocItem#defaultSelected).
-}
itemDefaultSelected : Bool -> Attr { c | selected : Supported } msg
itemDefaultSelected =
    Item_.defaultSelected


{-| See [`M3e.Component.TocItem.onClick`](M3e.Component.TocItem#onClick).
-}
itemOnClick : msg -> Attr { c | onClick : Supported } msg
itemOnClick =
    Item_.onClick


{-| See [`M3e.Component.TocItem.child`](M3e.Component.TocItem#child).
-}
itemChild : Element ItemContent admittedBy msg -> Element free freeAdmittedBy msg
itemChild =
    Item_.child
