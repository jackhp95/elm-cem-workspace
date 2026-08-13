module M3e.Build.Autocomplete exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
    , withAutoActivate, withCaseSensitive, withClass, withFilter, withFor, withHideLoading, withHideNoData, withHideSelectionIndicator, withId, withLoading, withLoadingLabel, withNoDataLabel, withOnChange, withOnQuery, withOnToggle, withPanelClass, withRequired, withResultsLabel, withSlot, withStyle
    , loading, noData
    , withLoadingSlot, withNoData, withChild
    )

{-| The builder module for `m3e-autocomplete` — seed, pipe, and close.

This module provides everything you need to BUILD with `Autocomplete`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.Autocomplete.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
@docs withAutoActivate, withCaseSensitive, withClass, withFilter, withFor, withHideLoading, withHideNoData, withHideSelectionIndicator, withId, withLoading, withLoadingLabel, withNoDataLabel, withOnChange, withOnQuery, withOnToggle, withPanelClass, withRequired, withResultsLabel, withSlot, withStyle
@docs loading, noData
@docs withLoadingSlot, withNoData, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Autocomplete as Component
import M3e.Events as Ev
import M3e.Internal.Types.Autocomplete
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.Autocomplete.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Autocomplete.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.Autocomplete.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.Autocomplete.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Autocomplete.ChildAdmittedBy childAdm


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Autocomplete.Content


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-autocomplete" [] []


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `loading` slot — calls `B.toElement` internally.
-}
loading :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
loading builder =
    Component.loading (B.toElement builder)


{-| Place a builder-built element into the named `no-data` slot — calls `B.toElement` internally.
-}
noData :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
noData builder =
    Component.noData (B.toElement builder)


{-| Pipe form of the `loading` slot — accepts a builder directly (no `.toElement`).
-}
withLoadingSlot :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | loading : Available } msg kind
    -> Builder attrCaps { s | loading : Used } msg kind
withLoadingSlot slotBuilder builder_ =
    B.withChild (El.toNode (Component.loading (B.toElement slotBuilder))) builder_


{-| Pipe form of the `no-data` slot — accepts a builder directly (no `.toElement`).
-}
withNoData :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | noData : Available } msg kind
    -> Builder attrCaps { s | noData : Used } msg kind
withNoData slotBuilder builder_ =
    B.withChild (El.toNode (Component.noData (B.toElement slotBuilder))) builder_


{-| Pipe form of a default-slot child (repeatable) — accepts a builder directly.
-}
withChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| Pipe form of `class` — consumes its capability (write-once).
-}
withClass : String -> Builder { a | class : Available } slotCaps msg kind -> Builder { a | class : Used } slotCaps msg kind
withClass value_ =
    B.withAttribute (A.class value_)


{-| Pipe form of `id` — consumes its capability (write-once).
-}
withId : String -> Builder { a | id : Available } slotCaps msg kind -> Builder { a | id : Used } slotCaps msg kind
withId value_ =
    B.withAttribute (A.id value_)


{-| Pipe form of `slot` — consumes its capability (write-once).
-}
withSlot : String -> Builder { a | slot : Available } slotCaps msg kind -> Builder { a | slot : Used } slotCaps msg kind
withSlot value_ =
    B.withAttribute (A.slot value_)


{-| Pipe form of `style` — consumes its capability (write-once).
-}
withStyle : String -> String -> Builder { a | style : Available } slotCaps msg kind -> Builder { a | style : Used } slotCaps msg kind
withStyle property value_ =
    B.withAttribute (A.style property value_)


{-| Pipe form of `autoActivate` — consumes its capability (write-once).
-}
withAutoActivate : Bool -> Builder { a | autoActivate : Available } slotCaps msg kind -> Builder { a | autoActivate : Used } slotCaps msg kind
withAutoActivate value_ =
    B.withAttribute (A.autoActivate value_)


{-| Pipe form of `caseSensitive` — consumes its capability (write-once).
-}
withCaseSensitive : Bool -> Builder { a | caseSensitive : Available } slotCaps msg kind -> Builder { a | caseSensitive : Used } slotCaps msg kind
withCaseSensitive value_ =
    B.withAttribute (A.caseSensitive value_)


{-| Pipe form of `filter` — consumes its capability (write-once).
-}
withFilter : Value Component.Filter -> Builder { a | filter : Available } slotCaps msg kind -> Builder { a | filter : Used } slotCaps msg kind
withFilter value_ =
    B.withAttribute (Component.filter value_)


{-| Pipe form of `for` — consumes its capability (write-once).
-}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| Pipe form of `hideLoading` — consumes its capability (write-once).
-}
withHideLoading : Bool -> Builder { a | hideLoading : Available } slotCaps msg kind -> Builder { a | hideLoading : Used } slotCaps msg kind
withHideLoading value_ =
    B.withAttribute (A.hideLoading value_)


{-| Pipe form of `hideNoData` — consumes its capability (write-once).
-}
withHideNoData : Bool -> Builder { a | hideNoData : Available } slotCaps msg kind -> Builder { a | hideNoData : Used } slotCaps msg kind
withHideNoData value_ =
    B.withAttribute (A.hideNoData value_)


{-| Pipe form of `hideSelectionIndicator` — consumes its capability (write-once).
-}
withHideSelectionIndicator : Bool -> Builder { a | hideSelectionIndicator : Available } slotCaps msg kind -> Builder { a | hideSelectionIndicator : Used } slotCaps msg kind
withHideSelectionIndicator value_ =
    B.withAttribute (A.hideSelectionIndicator value_)


{-| Pipe form of `loading` — consumes its capability (write-once).
-}
withLoading : Bool -> Builder { a | loading : Available } slotCaps msg kind -> Builder { a | loading : Used } slotCaps msg kind
withLoading value_ =
    B.withAttribute (A.loading value_)


{-| Pipe form of `loadingLabel` — consumes its capability (write-once).
-}
withLoadingLabel : String -> Builder { a | loadingLabel : Available } slotCaps msg kind -> Builder { a | loadingLabel : Used } slotCaps msg kind
withLoadingLabel value_ =
    B.withAttribute (A.loadingLabel value_)


{-| Pipe form of `noDataLabel` — consumes its capability (write-once).
-}
withNoDataLabel : String -> Builder { a | noDataLabel : Available } slotCaps msg kind -> Builder { a | noDataLabel : Used } slotCaps msg kind
withNoDataLabel value_ =
    B.withAttribute (A.noDataLabel value_)


{-| Pipe form of `panelClass` — consumes its capability (write-once).
-}
withPanelClass : String -> Builder { a | panelClass : Available } slotCaps msg kind -> Builder { a | panelClass : Used } slotCaps msg kind
withPanelClass value_ =
    B.withAttribute (A.panelClass value_)


{-| Pipe form of `required` — consumes its capability (write-once).
-}
withRequired : Bool -> Builder { a | required : Available } slotCaps msg kind -> Builder { a | required : Used } slotCaps msg kind
withRequired value_ =
    B.withAttribute (A.required value_)


{-| Pipe form of `resultsLabel` — consumes its capability (write-once).
-}
withResultsLabel : String -> Builder { a | resultsLabel : Available } slotCaps msg kind -> Builder { a | resultsLabel : Used } slotCaps msg kind
withResultsLabel value_ =
    B.withAttribute (A.resultsLabel value_)


{-| Pipe form of `onChange` — consumes its capability (write-once).
-}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| Pipe form of `onQuery` — consumes its capability (write-once).
-}
withOnQuery : msg -> Builder { a | onQuery : Available } slotCaps msg kind -> Builder { a | onQuery : Used } slotCaps msg kind
withOnQuery value_ =
    B.withAttribute (Ev.onQuery value_)


{-| Pipe form of `onToggle` — consumes its capability (write-once).
-}
withOnToggle : msg -> Builder { a | onToggle : Available } slotCaps msg kind -> Builder { a | onToggle : Used } slotCaps msg kind
withOnToggle value_ =
    B.withAttribute (Ev.onToggle value_)
