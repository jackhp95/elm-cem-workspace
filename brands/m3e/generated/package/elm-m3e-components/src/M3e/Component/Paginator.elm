module M3e.Component.Paginator exposing (PaginatorIs, PaginatorAttrs, PaginatorBuilder, PaginatorAttrCaps, PaginatorSlotCaps, PaginatorFirstPageIconSlot, PaginatorLastPageIconSlot, PaginatorNextPageIconSlot, PaginatorPreviousPageIconSlot, PaginatorChildAdmittedBy, PaginatorPageSizeVariant, paginator, paginatorPageSizeVariant, paginatorDisabled, paginatorFirstPageLabel, paginatorHidePageSize, paginatorItemsPerPageLabel, paginatorLastPageLabel, paginatorLength, paginatorNextPageLabel, paginatorPageIndex, paginatorPageSize, paginatorPageSizes, paginatorPreviousPageLabel, paginatorShowFirstLastButtons, paginatorOnPage, paginatorFirstPageIcon, paginatorLastPageIcon, paginatorNextPageIcon, paginatorPreviousPageIcon)

{-| The **Paginator** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Paginator`](M3e.Element.Paginator) as `paginator`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs PaginatorIs, PaginatorAttrs, PaginatorBuilder, PaginatorAttrCaps, PaginatorSlotCaps, PaginatorFirstPageIconSlot, PaginatorLastPageIconSlot, PaginatorNextPageIconSlot, PaginatorPreviousPageIconSlot, PaginatorChildAdmittedBy, PaginatorPageSizeVariant, paginator, paginatorPageSizeVariant, paginatorDisabled, paginatorFirstPageLabel, paginatorHidePageSize, paginatorItemsPerPageLabel, paginatorLastPageLabel, paginatorLength, paginatorNextPageLabel, paginatorPageIndex, paginatorPageSize, paginatorPageSizes, paginatorPreviousPageLabel, paginatorShowFirstLastButtons, paginatorOnPage, paginatorFirstPageIcon, paginatorLastPageIcon, paginatorNextPageIcon, paginatorPreviousPageIcon

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Paginator as Paginator_


{-| The `paginator` element of this family — delegates to [`M3e.Element.Paginator.component`](M3e.Element.Paginator#component).
-}
paginator :
    List (Attr PaginatorAttrs msg)
    -> List (Element childAccepts (PaginatorChildAdmittedBy childAdm) msg)
    -> Element (PaginatorIs s) admittedBy msg
paginator =
    Paginator_.component


{-| See [`M3e.Element.Paginator.Is`](M3e.Element.Paginator#Is).
-}
type alias PaginatorIs s =
    Paginator_.Is s


{-| See [`M3e.Element.Paginator.Attrs`](M3e.Element.Paginator#Attrs).
-}
type alias PaginatorAttrs =
    Paginator_.Attrs


{-| See [`M3e.Element.Paginator.Builder`](M3e.Element.Paginator#Builder).
-}
type alias PaginatorBuilder attrCaps slotCaps msg kind =
    Paginator_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Paginator.AttrCaps`](M3e.Element.Paginator#AttrCaps).
-}
type alias PaginatorAttrCaps =
    Paginator_.AttrCaps


{-| See [`M3e.Element.Paginator.SlotCaps`](M3e.Element.Paginator#SlotCaps).
-}
type alias PaginatorSlotCaps =
    Paginator_.SlotCaps


{-| See [`M3e.Element.Paginator.FirstPageIconSlot`](M3e.Element.Paginator#FirstPageIconSlot).
-}
type alias PaginatorFirstPageIconSlot =
    Paginator_.FirstPageIconSlot


{-| See [`M3e.Element.Paginator.LastPageIconSlot`](M3e.Element.Paginator#LastPageIconSlot).
-}
type alias PaginatorLastPageIconSlot =
    Paginator_.LastPageIconSlot


{-| See [`M3e.Element.Paginator.NextPageIconSlot`](M3e.Element.Paginator#NextPageIconSlot).
-}
type alias PaginatorNextPageIconSlot =
    Paginator_.NextPageIconSlot


{-| See [`M3e.Element.Paginator.PreviousPageIconSlot`](M3e.Element.Paginator#PreviousPageIconSlot).
-}
type alias PaginatorPreviousPageIconSlot =
    Paginator_.PreviousPageIconSlot


{-| See [`M3e.Element.Paginator.ChildAdmittedBy`](M3e.Element.Paginator#ChildAdmittedBy).
-}
type alias PaginatorChildAdmittedBy childAdm =
    Paginator_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Paginator.PageSizeVariant`](M3e.Element.Paginator#PageSizeVariant).
-}
type alias PaginatorPageSizeVariant =
    Paginator_.PageSizeVariant


{-| See [`M3e.Element.Paginator.pageSizeVariant`](M3e.Element.Paginator#pageSizeVariant).
-}
paginatorPageSizeVariant : Value PaginatorPageSizeVariant -> Attr { c | pageSizeVariant : Supported } msg
paginatorPageSizeVariant =
    Paginator_.pageSizeVariant


{-| See [`M3e.Element.Paginator.disabled`](M3e.Element.Paginator#disabled).
-}
paginatorDisabled : Bool -> Attr { c | disabled : Supported } msg
paginatorDisabled =
    Paginator_.disabled


{-| See [`M3e.Element.Paginator.firstPageLabel`](M3e.Element.Paginator#firstPageLabel).
-}
paginatorFirstPageLabel : String -> Attr { c | firstPageLabel : Supported } msg
paginatorFirstPageLabel =
    Paginator_.firstPageLabel


{-| See [`M3e.Element.Paginator.hidePageSize`](M3e.Element.Paginator#hidePageSize).
-}
paginatorHidePageSize : Bool -> Attr { c | hidePageSize : Supported } msg
paginatorHidePageSize =
    Paginator_.hidePageSize


{-| See [`M3e.Element.Paginator.itemsPerPageLabel`](M3e.Element.Paginator#itemsPerPageLabel).
-}
paginatorItemsPerPageLabel : String -> Attr { c | itemsPerPageLabel : Supported } msg
paginatorItemsPerPageLabel =
    Paginator_.itemsPerPageLabel


{-| See [`M3e.Element.Paginator.lastPageLabel`](M3e.Element.Paginator#lastPageLabel).
-}
paginatorLastPageLabel : String -> Attr { c | lastPageLabel : Supported } msg
paginatorLastPageLabel =
    Paginator_.lastPageLabel


{-| See [`M3e.Element.Paginator.length`](M3e.Element.Paginator#length).
-}
paginatorLength : Float -> Attr { c | length : Supported } msg
paginatorLength =
    Paginator_.length


{-| See [`M3e.Element.Paginator.nextPageLabel`](M3e.Element.Paginator#nextPageLabel).
-}
paginatorNextPageLabel : String -> Attr { c | nextPageLabel : Supported } msg
paginatorNextPageLabel =
    Paginator_.nextPageLabel


{-| See [`M3e.Element.Paginator.pageIndex`](M3e.Element.Paginator#pageIndex).
-}
paginatorPageIndex : Float -> Attr { c | pageIndex : Supported } msg
paginatorPageIndex =
    Paginator_.pageIndex


{-| See [`M3e.Element.Paginator.pageSize`](M3e.Element.Paginator#pageSize).
-}
paginatorPageSize : String -> Attr { c | pageSize : Supported } msg
paginatorPageSize =
    Paginator_.pageSize


{-| See [`M3e.Element.Paginator.pageSizes`](M3e.Element.Paginator#pageSizes).
-}
paginatorPageSizes : String -> Attr { c | pageSizes : Supported } msg
paginatorPageSizes =
    Paginator_.pageSizes


{-| See [`M3e.Element.Paginator.previousPageLabel`](M3e.Element.Paginator#previousPageLabel).
-}
paginatorPreviousPageLabel : String -> Attr { c | previousPageLabel : Supported } msg
paginatorPreviousPageLabel =
    Paginator_.previousPageLabel


{-| See [`M3e.Element.Paginator.showFirstLastButtons`](M3e.Element.Paginator#showFirstLastButtons).
-}
paginatorShowFirstLastButtons : Bool -> Attr { c | showFirstLastButtons : Supported } msg
paginatorShowFirstLastButtons =
    Paginator_.showFirstLastButtons


{-| See [`M3e.Element.Paginator.onPage`](M3e.Element.Paginator#onPage).
-}
paginatorOnPage : (String -> msg) -> Attr { c | onPage : Supported } msg
paginatorOnPage =
    Paginator_.onPage


{-| See [`M3e.Element.Paginator.firstPageIcon`](M3e.Element.Paginator#firstPageIcon).
-}
paginatorFirstPageIcon : Element PaginatorFirstPageIconSlot admittedBy msg -> Element free freeAdmittedBy msg
paginatorFirstPageIcon =
    Paginator_.firstPageIcon


{-| See [`M3e.Element.Paginator.lastPageIcon`](M3e.Element.Paginator#lastPageIcon).
-}
paginatorLastPageIcon : Element PaginatorLastPageIconSlot admittedBy msg -> Element free freeAdmittedBy msg
paginatorLastPageIcon =
    Paginator_.lastPageIcon


{-| See [`M3e.Element.Paginator.nextPageIcon`](M3e.Element.Paginator#nextPageIcon).
-}
paginatorNextPageIcon : Element PaginatorNextPageIconSlot admittedBy msg -> Element free freeAdmittedBy msg
paginatorNextPageIcon =
    Paginator_.nextPageIcon


{-| See [`M3e.Element.Paginator.previousPageIcon`](M3e.Element.Paginator#previousPageIcon).
-}
paginatorPreviousPageIcon : Element PaginatorPreviousPageIconSlot admittedBy msg -> Element free freeAdmittedBy msg
paginatorPreviousPageIcon =
    Paginator_.previousPageIcon
