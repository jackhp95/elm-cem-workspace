module M3e.Component.Autocomplete exposing (AutocompleteIs, AutocompleteAttrs, AutocompleteBuilder, AutocompleteAttrCaps, AutocompleteSlotCaps, AutocompleteContent, AutocompleteChildAdmittedBy, AutocompleteFilter, autocomplete, autocompleteFilter, autocompleteAutoActivate, autocompleteCaseSensitive, autocompleteFor, autocompleteHideLoading, autocompleteHideNoData, autocompleteHideSelectionIndicator, autocompleteLoadingLabel, autocompleteNoDataLabel, autocompletePanelClass, autocompleteRequired, autocompleteResultsLabel, autocompleteOnChange, autocompleteOnQuery, autocompleteOnToggle, autocompleteLoading, autocompleteNoData, autocompleteChild)

{-| The **Autocomplete** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Autocomplete`](M3e.Element.Autocomplete) as `autocomplete`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs AutocompleteIs, AutocompleteAttrs, AutocompleteBuilder, AutocompleteAttrCaps, AutocompleteSlotCaps, AutocompleteContent, AutocompleteChildAdmittedBy, AutocompleteFilter, autocomplete, autocompleteFilter, autocompleteAutoActivate, autocompleteCaseSensitive, autocompleteFor, autocompleteHideLoading, autocompleteHideNoData, autocompleteHideSelectionIndicator, autocompleteLoadingLabel, autocompleteNoDataLabel, autocompletePanelClass, autocompleteRequired, autocompleteResultsLabel, autocompleteOnChange, autocompleteOnQuery, autocompleteOnToggle, autocompleteLoading, autocompleteNoData, autocompleteChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Autocomplete as Autocomplete_


{-| The `autocomplete` element of this family — delegates to [`M3e.Element.Autocomplete.component`](M3e.Element.Autocomplete#component).
-}
autocomplete :
    List (Attr AutocompleteAttrs msg)
    -> List (Element AutocompleteContent (AutocompleteChildAdmittedBy childAdm) msg)
    -> Element (AutocompleteIs s) admittedBy msg
autocomplete =
    Autocomplete_.component


{-| See [`M3e.Element.Autocomplete.Is`](M3e.Element.Autocomplete#Is).
-}
type alias AutocompleteIs s =
    Autocomplete_.Is s


{-| See [`M3e.Element.Autocomplete.Attrs`](M3e.Element.Autocomplete#Attrs).
-}
type alias AutocompleteAttrs =
    Autocomplete_.Attrs


{-| See [`M3e.Element.Autocomplete.Builder`](M3e.Element.Autocomplete#Builder).
-}
type alias AutocompleteBuilder attrCaps slotCaps msg kind =
    Autocomplete_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Autocomplete.AttrCaps`](M3e.Element.Autocomplete#AttrCaps).
-}
type alias AutocompleteAttrCaps =
    Autocomplete_.AttrCaps


{-| See [`M3e.Element.Autocomplete.SlotCaps`](M3e.Element.Autocomplete#SlotCaps).
-}
type alias AutocompleteSlotCaps =
    Autocomplete_.SlotCaps


{-| See [`M3e.Element.Autocomplete.Content`](M3e.Element.Autocomplete#Content).
-}
type alias AutocompleteContent =
    Autocomplete_.Content


{-| See [`M3e.Element.Autocomplete.ChildAdmittedBy`](M3e.Element.Autocomplete#ChildAdmittedBy).
-}
type alias AutocompleteChildAdmittedBy childAdm =
    Autocomplete_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Autocomplete.Filter`](M3e.Element.Autocomplete#Filter).
-}
type alias AutocompleteFilter =
    Autocomplete_.Filter


{-| See [`M3e.Element.Autocomplete.filter`](M3e.Element.Autocomplete#filter).
-}
autocompleteFilter : Value AutocompleteFilter -> Attr { c | filter : Supported } msg
autocompleteFilter =
    Autocomplete_.filter


{-| See [`M3e.Element.Autocomplete.autoActivate`](M3e.Element.Autocomplete#autoActivate).
-}
autocompleteAutoActivate : Bool -> Attr { c | autoActivate : Supported } msg
autocompleteAutoActivate =
    Autocomplete_.autoActivate


{-| See [`M3e.Element.Autocomplete.caseSensitive`](M3e.Element.Autocomplete#caseSensitive).
-}
autocompleteCaseSensitive : Bool -> Attr { c | caseSensitive : Supported } msg
autocompleteCaseSensitive =
    Autocomplete_.caseSensitive


{-| See [`M3e.Element.Autocomplete.for`](M3e.Element.Autocomplete#for).
-}
autocompleteFor : String -> Attr { c | for : Supported } msg
autocompleteFor =
    Autocomplete_.for


{-| See [`M3e.Element.Autocomplete.hideLoading`](M3e.Element.Autocomplete#hideLoading).
-}
autocompleteHideLoading : Bool -> Attr { c | hideLoading : Supported } msg
autocompleteHideLoading =
    Autocomplete_.hideLoading


{-| See [`M3e.Element.Autocomplete.hideNoData`](M3e.Element.Autocomplete#hideNoData).
-}
autocompleteHideNoData : Bool -> Attr { c | hideNoData : Supported } msg
autocompleteHideNoData =
    Autocomplete_.hideNoData


{-| See [`M3e.Element.Autocomplete.hideSelectionIndicator`](M3e.Element.Autocomplete#hideSelectionIndicator).
-}
autocompleteHideSelectionIndicator : Bool -> Attr { c | hideSelectionIndicator : Supported } msg
autocompleteHideSelectionIndicator =
    Autocomplete_.hideSelectionIndicator


{-| See [`M3e.Element.Autocomplete.loadingLabel`](M3e.Element.Autocomplete#loadingLabel).
-}
autocompleteLoadingLabel : String -> Attr { c | loadingLabel : Supported } msg
autocompleteLoadingLabel =
    Autocomplete_.loadingLabel


{-| See [`M3e.Element.Autocomplete.noDataLabel`](M3e.Element.Autocomplete#noDataLabel).
-}
autocompleteNoDataLabel : String -> Attr { c | noDataLabel : Supported } msg
autocompleteNoDataLabel =
    Autocomplete_.noDataLabel


{-| See [`M3e.Element.Autocomplete.panelClass`](M3e.Element.Autocomplete#panelClass).
-}
autocompletePanelClass : String -> Attr { c | panelClass : Supported } msg
autocompletePanelClass =
    Autocomplete_.panelClass


{-| See [`M3e.Element.Autocomplete.required`](M3e.Element.Autocomplete#required).
-}
autocompleteRequired : Bool -> Attr { c | required : Supported } msg
autocompleteRequired =
    Autocomplete_.required


{-| See [`M3e.Element.Autocomplete.resultsLabel`](M3e.Element.Autocomplete#resultsLabel).
-}
autocompleteResultsLabel : String -> Attr { c | resultsLabel : Supported } msg
autocompleteResultsLabel =
    Autocomplete_.resultsLabel


{-| See [`M3e.Element.Autocomplete.onChange`](M3e.Element.Autocomplete#onChange).
-}
autocompleteOnChange : msg -> Attr { c | onChange : Supported } msg
autocompleteOnChange =
    Autocomplete_.onChange


{-| See [`M3e.Element.Autocomplete.onQuery`](M3e.Element.Autocomplete#onQuery).
-}
autocompleteOnQuery : msg -> Attr { c | onQuery : Supported } msg
autocompleteOnQuery =
    Autocomplete_.onQuery


{-| See [`M3e.Element.Autocomplete.onToggle`](M3e.Element.Autocomplete#onToggle).
-}
autocompleteOnToggle : msg -> Attr { c | onToggle : Supported } msg
autocompleteOnToggle =
    Autocomplete_.onToggle


{-| See [`M3e.Element.Autocomplete.loading`](M3e.Element.Autocomplete#loading).
-}
autocompleteLoading : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
autocompleteLoading =
    Autocomplete_.loading


{-| See [`M3e.Element.Autocomplete.noData`](M3e.Element.Autocomplete#noData).
-}
autocompleteNoData : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
autocompleteNoData =
    Autocomplete_.noData


{-| See [`M3e.Element.Autocomplete.child`](M3e.Element.Autocomplete#child).
-}
autocompleteChild : Element AutocompleteContent admittedBy msg -> Element free freeAdmittedBy msg
autocompleteChild =
    Autocomplete_.child
