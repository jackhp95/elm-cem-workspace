module M3e.Component.Toc exposing (TocIs, TocAttrs, TocBuilder, TocAttrCaps, TocSlotCaps, TocOverlineSlot, TocTitleSlot, TocChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemChildAdmittedBy, toc, tocFor, tocMaxDepth, tocOverline, tocTitle, tocChild, item, itemDisabled, itemSelected, itemDefaultSelected, itemOnClick, itemChild)

{-| The **Toc** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Toc`](M3e.Element.Toc) as `toc`, [`M3e.Element.TocItem`](M3e.Element.TocItem) as `item`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs TocIs, TocAttrs, TocBuilder, TocAttrCaps, TocSlotCaps, TocOverlineSlot, TocTitleSlot, TocChildAdmittedBy, ItemIs, ItemAttrs, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemContent, ItemChildAdmittedBy, toc, tocFor, tocMaxDepth, tocOverline, tocTitle, tocChild, item, itemDisabled, itemSelected, itemDefaultSelected, itemOnClick, itemChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.Toc as Toc_
import M3e.Element.TocItem as Item_


{-| The `toc` element of this family — delegates to [`M3e.Element.Toc.component`](M3e.Element.Toc#component).
-}
toc :
    List (Attr TocAttrs msg)
    -> List (Element childAccepts (TocChildAdmittedBy childAdm) msg)
    -> Element (TocIs s) admittedBy msg
toc =
    Toc_.component


{-| See [`M3e.Element.Toc.Is`](M3e.Element.Toc#Is).
-}
type alias TocIs s =
    Toc_.Is s


{-| See [`M3e.Element.Toc.Attrs`](M3e.Element.Toc#Attrs).
-}
type alias TocAttrs =
    Toc_.Attrs


{-| See [`M3e.Element.Toc.Builder`](M3e.Element.Toc#Builder).
-}
type alias TocBuilder attrCaps slotCaps msg kind =
    Toc_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Toc.AttrCaps`](M3e.Element.Toc#AttrCaps).
-}
type alias TocAttrCaps =
    Toc_.AttrCaps


{-| See [`M3e.Element.Toc.SlotCaps`](M3e.Element.Toc#SlotCaps).
-}
type alias TocSlotCaps =
    Toc_.SlotCaps


{-| See [`M3e.Element.Toc.OverlineSlot`](M3e.Element.Toc#OverlineSlot).
-}
type alias TocOverlineSlot =
    Toc_.OverlineSlot


{-| See [`M3e.Element.Toc.TitleSlot`](M3e.Element.Toc#TitleSlot).
-}
type alias TocTitleSlot =
    Toc_.TitleSlot


{-| See [`M3e.Element.Toc.ChildAdmittedBy`](M3e.Element.Toc#ChildAdmittedBy).
-}
type alias TocChildAdmittedBy childAdm =
    Toc_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Toc.for`](M3e.Element.Toc#for).
-}
tocFor : String -> Attr { c | for : Supported } msg
tocFor =
    Toc_.for


{-| See [`M3e.Element.Toc.maxDepth`](M3e.Element.Toc#maxDepth).
-}
tocMaxDepth : Float -> Attr { c | maxDepth : Supported } msg
tocMaxDepth =
    Toc_.maxDepth


{-| See [`M3e.Element.Toc.overline`](M3e.Element.Toc#overline).
-}
tocOverline : Element TocOverlineSlot admittedBy msg -> Element free freeAdmittedBy msg
tocOverline =
    Toc_.overline


{-| See [`M3e.Element.Toc.title`](M3e.Element.Toc#title).
-}
tocTitle : Element TocTitleSlot admittedBy msg -> Element free freeAdmittedBy msg
tocTitle =
    Toc_.title


{-| See [`M3e.Element.Toc.child`](M3e.Element.Toc#child).
-}
tocChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
tocChild =
    Toc_.child


{-| The `item` element of this family — delegates to [`M3e.Element.TocItem.component`](M3e.Element.TocItem#component).
-}
item :
    { content : Element ItemContent (ItemChildAdmittedBy childAdm) msg }
    -> List (Attr ItemAttrs msg)
    -> List (Element ItemContent (ItemChildAdmittedBy childAdm) msg)
    -> Element (ItemIs s) admittedBy msg
item =
    Item_.component


{-| See [`M3e.Element.TocItem.Is`](M3e.Element.TocItem#Is).
-}
type alias ItemIs s =
    Item_.Is s


{-| See [`M3e.Element.TocItem.Attrs`](M3e.Element.TocItem#Attrs).
-}
type alias ItemAttrs =
    Item_.Attrs


{-| See [`M3e.Element.TocItem.Builder`](M3e.Element.TocItem#Builder).
-}
type alias ItemBuilder attrCaps slotCaps msg kind =
    Item_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.TocItem.AttrCaps`](M3e.Element.TocItem#AttrCaps).
-}
type alias ItemAttrCaps =
    Item_.AttrCaps


{-| See [`M3e.Element.TocItem.SlotCaps`](M3e.Element.TocItem#SlotCaps).
-}
type alias ItemSlotCaps =
    Item_.SlotCaps


{-| See [`M3e.Element.TocItem.Content`](M3e.Element.TocItem#Content).
-}
type alias ItemContent =
    Item_.Content


{-| See [`M3e.Element.TocItem.ChildAdmittedBy`](M3e.Element.TocItem#ChildAdmittedBy).
-}
type alias ItemChildAdmittedBy childAdm =
    Item_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.TocItem.disabled`](M3e.Element.TocItem#disabled).
-}
itemDisabled : Bool -> Attr { c | disabled : Supported } msg
itemDisabled =
    Item_.disabled


{-| See [`M3e.Element.TocItem.selected`](M3e.Element.TocItem#selected).
-}
itemSelected : Bool -> Attr { c | selected : Supported } msg
itemSelected =
    Item_.selected


{-| See [`M3e.Element.TocItem.defaultSelected`](M3e.Element.TocItem#defaultSelected).
-}
itemDefaultSelected : Bool -> Attr { c | selected : Supported } msg
itemDefaultSelected =
    Item_.defaultSelected


{-| See [`M3e.Element.TocItem.onClick`](M3e.Element.TocItem#onClick).
-}
itemOnClick : msg -> Attr { c | onClick : Supported } msg
itemOnClick =
    Item_.onClick


{-| See [`M3e.Element.TocItem.child`](M3e.Element.TocItem#child).
-}
itemChild : Element ItemContent admittedBy msg -> Element free freeAdmittedBy msg
itemChild =
    Item_.child
