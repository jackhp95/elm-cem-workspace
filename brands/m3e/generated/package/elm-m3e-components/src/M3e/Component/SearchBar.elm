module M3e.Component.SearchBar exposing (SearchBarIs, SearchBarAttrs, SearchBarBuilder, SearchBarAttrCaps, SearchBarSlotCaps, SearchBarClearIconSlot, SearchBarLeadingSlot, SearchBarTrailingSlot, SearchBarChildAdmittedBy, searchBar, searchBarClearLabel, searchBarClearable, searchBarOnClear, searchBarClearIcon, searchBarInput, searchBarLeading, searchBarTrailing)

{-| The **SearchBar** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.SearchBar`](M3e.Element.SearchBar) as `searchBar`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SearchBarIs, SearchBarAttrs, SearchBarBuilder, SearchBarAttrCaps, SearchBarSlotCaps, SearchBarClearIconSlot, SearchBarLeadingSlot, SearchBarTrailingSlot, SearchBarChildAdmittedBy, searchBar, searchBarClearLabel, searchBarClearable, searchBarOnClear, searchBarClearIcon, searchBarInput, searchBarLeading, searchBarTrailing

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.SearchBar as SearchBar_


{-| The `searchBar` element of this family — delegates to [`M3e.Element.SearchBar.component`](M3e.Element.SearchBar#component).
-}
searchBar :
    { input : Element childAccepts (SearchBarChildAdmittedBy childAdm) msg }
    -> List (Attr SearchBarAttrs msg)
    -> List (Element childAccepts (SearchBarChildAdmittedBy childAdm) msg)
    -> Element (SearchBarIs s) admittedBy msg
searchBar =
    SearchBar_.component


{-| See [`M3e.Element.SearchBar.Is`](M3e.Element.SearchBar#Is).
-}
type alias SearchBarIs s =
    SearchBar_.Is s


{-| See [`M3e.Element.SearchBar.Attrs`](M3e.Element.SearchBar#Attrs).
-}
type alias SearchBarAttrs =
    SearchBar_.Attrs


{-| See [`M3e.Element.SearchBar.Builder`](M3e.Element.SearchBar#Builder).
-}
type alias SearchBarBuilder attrCaps slotCaps msg kind =
    SearchBar_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.SearchBar.AttrCaps`](M3e.Element.SearchBar#AttrCaps).
-}
type alias SearchBarAttrCaps =
    SearchBar_.AttrCaps


{-| See [`M3e.Element.SearchBar.SlotCaps`](M3e.Element.SearchBar#SlotCaps).
-}
type alias SearchBarSlotCaps =
    SearchBar_.SlotCaps


{-| See [`M3e.Element.SearchBar.ClearIconSlot`](M3e.Element.SearchBar#ClearIconSlot).
-}
type alias SearchBarClearIconSlot =
    SearchBar_.ClearIconSlot


{-| See [`M3e.Element.SearchBar.LeadingSlot`](M3e.Element.SearchBar#LeadingSlot).
-}
type alias SearchBarLeadingSlot =
    SearchBar_.LeadingSlot


{-| See [`M3e.Element.SearchBar.TrailingSlot`](M3e.Element.SearchBar#TrailingSlot).
-}
type alias SearchBarTrailingSlot =
    SearchBar_.TrailingSlot


{-| See [`M3e.Element.SearchBar.ChildAdmittedBy`](M3e.Element.SearchBar#ChildAdmittedBy).
-}
type alias SearchBarChildAdmittedBy childAdm =
    SearchBar_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.SearchBar.clearLabel`](M3e.Element.SearchBar#clearLabel).
-}
searchBarClearLabel : String -> Attr { c | clearLabel : Supported } msg
searchBarClearLabel =
    SearchBar_.clearLabel


{-| See [`M3e.Element.SearchBar.clearable`](M3e.Element.SearchBar#clearable).
-}
searchBarClearable : Bool -> Attr { c | clearable : Supported } msg
searchBarClearable =
    SearchBar_.clearable


{-| See [`M3e.Element.SearchBar.onClear`](M3e.Element.SearchBar#onClear).
-}
searchBarOnClear : msg -> Attr { c | onClear : Supported } msg
searchBarOnClear =
    SearchBar_.onClear


{-| See [`M3e.Element.SearchBar.clearIcon`](M3e.Element.SearchBar#clearIcon).
-}
searchBarClearIcon : Element SearchBarClearIconSlot admittedBy msg -> Element free freeAdmittedBy msg
searchBarClearIcon =
    SearchBar_.clearIcon


{-| See [`M3e.Element.SearchBar.input`](M3e.Element.SearchBar#input).
-}
searchBarInput : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
searchBarInput =
    SearchBar_.input


{-| See [`M3e.Element.SearchBar.leading`](M3e.Element.SearchBar#leading).
-}
searchBarLeading : Element SearchBarLeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
searchBarLeading =
    SearchBar_.leading


{-| See [`M3e.Element.SearchBar.trailing`](M3e.Element.SearchBar#trailing).
-}
searchBarTrailing : Element SearchBarTrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
searchBarTrailing =
    SearchBar_.trailing
