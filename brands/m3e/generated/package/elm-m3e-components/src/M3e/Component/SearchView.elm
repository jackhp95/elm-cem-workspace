module M3e.Component.SearchView exposing (SearchViewIs, SearchViewAttrs, SearchViewBuilder, SearchViewAttrCaps, SearchViewSlotCaps, SearchViewClearIconSlot, SearchViewCloseIconSlot, SearchViewClosedLeadingSlot, SearchViewClosedTrailingSlot, SearchViewOpenLeadingSlot, SearchViewOpenTrailingSlot, SearchViewSearchIconSlot, SearchViewChildAdmittedBy, SearchViewMode, searchView, searchViewMode, searchViewClearLabel, searchViewCloseLabel, searchViewContained, searchViewHideSearchIcon, searchViewOpen, searchViewOnQuery, searchViewOnClear, searchViewOnBeforetoggle, searchViewOnToggle, searchViewClearIcon, searchViewCloseIcon, searchViewClosedLeading, searchViewClosedTrailing, searchViewInput, searchViewOpenLeading, searchViewOpenTrailing, searchViewSearchIcon, searchViewChild)

{-| The **SearchView** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.SearchView`](M3e.Element.SearchView) as `searchView`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SearchViewIs, SearchViewAttrs, SearchViewBuilder, SearchViewAttrCaps, SearchViewSlotCaps, SearchViewClearIconSlot, SearchViewCloseIconSlot, SearchViewClosedLeadingSlot, SearchViewClosedTrailingSlot, SearchViewOpenLeadingSlot, SearchViewOpenTrailingSlot, SearchViewSearchIconSlot, SearchViewChildAdmittedBy, SearchViewMode, searchView, searchViewMode, searchViewClearLabel, searchViewCloseLabel, searchViewContained, searchViewHideSearchIcon, searchViewOpen, searchViewOnQuery, searchViewOnClear, searchViewOnBeforetoggle, searchViewOnToggle, searchViewClearIcon, searchViewCloseIcon, searchViewClosedLeading, searchViewClosedTrailing, searchViewInput, searchViewOpenLeading, searchViewOpenTrailing, searchViewSearchIcon, searchViewChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.SearchView as SearchView_


{-| The `searchView` element of this family — delegates to [`M3e.Element.SearchView.component`](M3e.Element.SearchView#component).
-}
searchView :
    { input : Element childAccepts (SearchViewChildAdmittedBy childAdm) msg }
    -> List (Attr SearchViewAttrs msg)
    -> List (Element childAccepts (SearchViewChildAdmittedBy childAdm) msg)
    -> Element (SearchViewIs s) admittedBy msg
searchView =
    SearchView_.component


{-| See [`M3e.Element.SearchView.Is`](M3e.Element.SearchView#Is).
-}
type alias SearchViewIs s =
    SearchView_.Is s


{-| See [`M3e.Element.SearchView.Attrs`](M3e.Element.SearchView#Attrs).
-}
type alias SearchViewAttrs =
    SearchView_.Attrs


{-| See [`M3e.Element.SearchView.Builder`](M3e.Element.SearchView#Builder).
-}
type alias SearchViewBuilder attrCaps slotCaps msg kind =
    SearchView_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.SearchView.AttrCaps`](M3e.Element.SearchView#AttrCaps).
-}
type alias SearchViewAttrCaps =
    SearchView_.AttrCaps


{-| See [`M3e.Element.SearchView.SlotCaps`](M3e.Element.SearchView#SlotCaps).
-}
type alias SearchViewSlotCaps =
    SearchView_.SlotCaps


{-| See [`M3e.Element.SearchView.ClearIconSlot`](M3e.Element.SearchView#ClearIconSlot).
-}
type alias SearchViewClearIconSlot =
    SearchView_.ClearIconSlot


{-| See [`M3e.Element.SearchView.CloseIconSlot`](M3e.Element.SearchView#CloseIconSlot).
-}
type alias SearchViewCloseIconSlot =
    SearchView_.CloseIconSlot


{-| See [`M3e.Element.SearchView.ClosedLeadingSlot`](M3e.Element.SearchView#ClosedLeadingSlot).
-}
type alias SearchViewClosedLeadingSlot =
    SearchView_.ClosedLeadingSlot


{-| See [`M3e.Element.SearchView.ClosedTrailingSlot`](M3e.Element.SearchView#ClosedTrailingSlot).
-}
type alias SearchViewClosedTrailingSlot =
    SearchView_.ClosedTrailingSlot


{-| See [`M3e.Element.SearchView.OpenLeadingSlot`](M3e.Element.SearchView#OpenLeadingSlot).
-}
type alias SearchViewOpenLeadingSlot =
    SearchView_.OpenLeadingSlot


{-| See [`M3e.Element.SearchView.OpenTrailingSlot`](M3e.Element.SearchView#OpenTrailingSlot).
-}
type alias SearchViewOpenTrailingSlot =
    SearchView_.OpenTrailingSlot


{-| See [`M3e.Element.SearchView.SearchIconSlot`](M3e.Element.SearchView#SearchIconSlot).
-}
type alias SearchViewSearchIconSlot =
    SearchView_.SearchIconSlot


{-| See [`M3e.Element.SearchView.ChildAdmittedBy`](M3e.Element.SearchView#ChildAdmittedBy).
-}
type alias SearchViewChildAdmittedBy childAdm =
    SearchView_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.SearchView.Mode`](M3e.Element.SearchView#Mode).
-}
type alias SearchViewMode =
    SearchView_.Mode


{-| See [`M3e.Element.SearchView.mode`](M3e.Element.SearchView#mode).
-}
searchViewMode : Value SearchViewMode -> Attr { c | mode : Supported } msg
searchViewMode =
    SearchView_.mode


{-| See [`M3e.Element.SearchView.clearLabel`](M3e.Element.SearchView#clearLabel).
-}
searchViewClearLabel : String -> Attr { c | clearLabel : Supported } msg
searchViewClearLabel =
    SearchView_.clearLabel


{-| See [`M3e.Element.SearchView.closeLabel`](M3e.Element.SearchView#closeLabel).
-}
searchViewCloseLabel : String -> Attr { c | closeLabel : Supported } msg
searchViewCloseLabel =
    SearchView_.closeLabel


{-| See [`M3e.Element.SearchView.contained`](M3e.Element.SearchView#contained).
-}
searchViewContained : Bool -> Attr { c | contained : Supported } msg
searchViewContained =
    SearchView_.contained


{-| See [`M3e.Element.SearchView.hideSearchIcon`](M3e.Element.SearchView#hideSearchIcon).
-}
searchViewHideSearchIcon : Bool -> Attr { c | hideSearchIcon : Supported } msg
searchViewHideSearchIcon =
    SearchView_.hideSearchIcon


{-| See [`M3e.Element.SearchView.open`](M3e.Element.SearchView#open).
-}
searchViewOpen : Bool -> Attr { c | open : Supported } msg
searchViewOpen =
    SearchView_.open


{-| See [`M3e.Element.SearchView.onQuery`](M3e.Element.SearchView#onQuery).
-}
searchViewOnQuery : msg -> Attr { c | onQuery : Supported } msg
searchViewOnQuery =
    SearchView_.onQuery


{-| See [`M3e.Element.SearchView.onClear`](M3e.Element.SearchView#onClear).
-}
searchViewOnClear : msg -> Attr { c | onClear : Supported } msg
searchViewOnClear =
    SearchView_.onClear


{-| See [`M3e.Element.SearchView.onBeforetoggle`](M3e.Element.SearchView#onBeforetoggle).
-}
searchViewOnBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
searchViewOnBeforetoggle =
    SearchView_.onBeforetoggle


{-| See [`M3e.Element.SearchView.onToggle`](M3e.Element.SearchView#onToggle).
-}
searchViewOnToggle : msg -> Attr { c | onToggle : Supported } msg
searchViewOnToggle =
    SearchView_.onToggle


{-| See [`M3e.Element.SearchView.clearIcon`](M3e.Element.SearchView#clearIcon).
-}
searchViewClearIcon : Element SearchViewClearIconSlot admittedBy msg -> Element free freeAdmittedBy msg
searchViewClearIcon =
    SearchView_.clearIcon


{-| See [`M3e.Element.SearchView.closeIcon`](M3e.Element.SearchView#closeIcon).
-}
searchViewCloseIcon : Element SearchViewCloseIconSlot admittedBy msg -> Element free freeAdmittedBy msg
searchViewCloseIcon =
    SearchView_.closeIcon


{-| See [`M3e.Element.SearchView.closedLeading`](M3e.Element.SearchView#closedLeading).
-}
searchViewClosedLeading : Element SearchViewClosedLeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
searchViewClosedLeading =
    SearchView_.closedLeading


{-| See [`M3e.Element.SearchView.closedTrailing`](M3e.Element.SearchView#closedTrailing).
-}
searchViewClosedTrailing : Element SearchViewClosedTrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
searchViewClosedTrailing =
    SearchView_.closedTrailing


{-| See [`M3e.Element.SearchView.input`](M3e.Element.SearchView#input).
-}
searchViewInput : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
searchViewInput =
    SearchView_.input


{-| See [`M3e.Element.SearchView.openLeading`](M3e.Element.SearchView#openLeading).
-}
searchViewOpenLeading : Element SearchViewOpenLeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
searchViewOpenLeading =
    SearchView_.openLeading


{-| See [`M3e.Element.SearchView.openTrailing`](M3e.Element.SearchView#openTrailing).
-}
searchViewOpenTrailing : Element SearchViewOpenTrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
searchViewOpenTrailing =
    SearchView_.openTrailing


{-| See [`M3e.Element.SearchView.searchIcon`](M3e.Element.SearchView#searchIcon).
-}
searchViewSearchIcon : Element SearchViewSearchIconSlot admittedBy msg -> Element free freeAdmittedBy msg
searchViewSearchIcon =
    SearchView_.searchIcon


{-| See [`M3e.Element.SearchView.child`](M3e.Element.SearchView#child).
-}
searchViewChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
searchViewChild =
    SearchView_.child
