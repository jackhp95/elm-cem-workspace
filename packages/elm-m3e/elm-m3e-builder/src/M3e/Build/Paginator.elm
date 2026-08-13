module M3e.Build.Paginator exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, FirstPageIconSlot, LastPageIconSlot, NextPageIconSlot, PreviousPageIconSlot, ChildAdmittedBy
    , withClass, withDisabled, withFirstPageLabel, withHidePageSize, withId, withItemsPerPageLabel, withLastPageLabel, withLength, withNextPageLabel, withOnPage, withPageIndex, withPageSize, withPageSizeVariant, withPageSizes, withPreviousPageLabel, withShowFirstLastButtons, withSlot, withStyle
    , firstPageIcon, lastPageIcon, nextPageIcon, previousPageIcon
    , withFirstPageIcon, withLastPageIcon, withNextPageIcon, withPreviousPageIcon
    )

{-| The builder module for `m3e-paginator` — seed, pipe, and close.

This module provides everything you need to BUILD with `Paginator`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.Paginator.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, FirstPageIconSlot, LastPageIconSlot, NextPageIconSlot, PreviousPageIconSlot, ChildAdmittedBy
@docs withClass, withDisabled, withFirstPageLabel, withHidePageSize, withId, withItemsPerPageLabel, withLastPageLabel, withLength, withNextPageLabel, withOnPage, withPageIndex, withPageSize, withPageSizeVariant, withPageSizes, withPreviousPageLabel, withShowFirstLastButtons, withSlot, withStyle
@docs firstPageIcon, lastPageIcon, nextPageIcon, previousPageIcon
@docs withFirstPageIcon, withLastPageIcon, withNextPageIcon, withPreviousPageIcon

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Paginator as Component
import M3e.Events as Ev
import M3e.Internal.Types.Paginator
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.Paginator.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Paginator.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.Paginator.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.Paginator.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Paginator.ChildAdmittedBy childAdm


{-| The kinds the `first-page-icon` slot admits.
-}
type alias FirstPageIconSlot =
    M3e.Internal.Types.Paginator.FirstPageIconSlot


{-| The kinds the `last-page-icon` slot admits.
-}
type alias LastPageIconSlot =
    M3e.Internal.Types.Paginator.LastPageIconSlot


{-| The kinds the `next-page-icon` slot admits.
-}
type alias NextPageIconSlot =
    M3e.Internal.Types.Paginator.NextPageIconSlot


{-| The kinds the `previous-page-icon` slot admits.
-}
type alias PreviousPageIconSlot =
    M3e.Internal.Types.Paginator.PreviousPageIconSlot


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-paginator" [] []


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `first-page-icon` slot — calls `B.toElement` internally.
-}
firstPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.FirstPageIconSlot msg
    -> Element free freeAdmittedBy msg
firstPageIcon builder =
    Component.firstPageIcon (B.toElement builder)


{-| Place a builder-built element into the named `last-page-icon` slot — calls `B.toElement` internally.
-}
lastPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.LastPageIconSlot msg
    -> Element free freeAdmittedBy msg
lastPageIcon builder =
    Component.lastPageIcon (B.toElement builder)


{-| Place a builder-built element into the named `next-page-icon` slot — calls `B.toElement` internally.
-}
nextPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.NextPageIconSlot msg
    -> Element free freeAdmittedBy msg
nextPageIcon builder =
    Component.nextPageIcon (B.toElement builder)


{-| Place a builder-built element into the named `previous-page-icon` slot — calls `B.toElement` internally.
-}
previousPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PreviousPageIconSlot msg
    -> Element free freeAdmittedBy msg
previousPageIcon builder =
    Component.previousPageIcon (B.toElement builder)


{-| Pipe form of the `first-page-icon` slot — accepts a builder directly (no `.toElement`).
-}
withFirstPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.FirstPageIconSlot msg
    -> Builder attrCaps { s | firstPageIcon : Available } msg kind
    -> Builder attrCaps { s | firstPageIcon : Used } msg kind
withFirstPageIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.firstPageIcon (B.toElement slotBuilder))) builder_


{-| Pipe form of the `last-page-icon` slot — accepts a builder directly (no `.toElement`).
-}
withLastPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.LastPageIconSlot msg
    -> Builder attrCaps { s | lastPageIcon : Available } msg kind
    -> Builder attrCaps { s | lastPageIcon : Used } msg kind
withLastPageIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.lastPageIcon (B.toElement slotBuilder))) builder_


{-| Pipe form of the `next-page-icon` slot — accepts a builder directly (no `.toElement`).
-}
withNextPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.NextPageIconSlot msg
    -> Builder attrCaps { s | nextPageIcon : Available } msg kind
    -> Builder attrCaps { s | nextPageIcon : Used } msg kind
withNextPageIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.nextPageIcon (B.toElement slotBuilder))) builder_


{-| Pipe form of the `previous-page-icon` slot — accepts a builder directly (no `.toElement`).
-}
withPreviousPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PreviousPageIconSlot msg
    -> Builder attrCaps { s | previousPageIcon : Available } msg kind
    -> Builder attrCaps { s | previousPageIcon : Used } msg kind
withPreviousPageIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.previousPageIcon (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `disabled` — consumes its capability (write-once).
-}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| Pipe form of `firstPageLabel` — consumes its capability (write-once).
-}
withFirstPageLabel : String -> Builder { a | firstPageLabel : Available } slotCaps msg kind -> Builder { a | firstPageLabel : Used } slotCaps msg kind
withFirstPageLabel value_ =
    B.withAttribute (A.firstPageLabel value_)


{-| Pipe form of `hidePageSize` — consumes its capability (write-once).
-}
withHidePageSize : Bool -> Builder { a | hidePageSize : Available } slotCaps msg kind -> Builder { a | hidePageSize : Used } slotCaps msg kind
withHidePageSize value_ =
    B.withAttribute (A.hidePageSize value_)


{-| Pipe form of `itemsPerPageLabel` — consumes its capability (write-once).
-}
withItemsPerPageLabel : String -> Builder { a | itemsPerPageLabel : Available } slotCaps msg kind -> Builder { a | itemsPerPageLabel : Used } slotCaps msg kind
withItemsPerPageLabel value_ =
    B.withAttribute (A.itemsPerPageLabel value_)


{-| Pipe form of `lastPageLabel` — consumes its capability (write-once).
-}
withLastPageLabel : String -> Builder { a | lastPageLabel : Available } slotCaps msg kind -> Builder { a | lastPageLabel : Used } slotCaps msg kind
withLastPageLabel value_ =
    B.withAttribute (A.lastPageLabel value_)


{-| Pipe form of `length` — consumes its capability (write-once).
-}
withLength : Float -> Builder { a | length : Available } slotCaps msg kind -> Builder { a | length : Used } slotCaps msg kind
withLength value_ =
    B.withAttribute (A.length value_)


{-| Pipe form of `nextPageLabel` — consumes its capability (write-once).
-}
withNextPageLabel : String -> Builder { a | nextPageLabel : Available } slotCaps msg kind -> Builder { a | nextPageLabel : Used } slotCaps msg kind
withNextPageLabel value_ =
    B.withAttribute (A.nextPageLabel value_)


{-| Pipe form of `pageIndex` — consumes its capability (write-once).
-}
withPageIndex : Float -> Builder { a | pageIndex : Available } slotCaps msg kind -> Builder { a | pageIndex : Used } slotCaps msg kind
withPageIndex value_ =
    B.withAttribute (A.pageIndex value_)


{-| Pipe form of `pageSize` — consumes its capability (write-once).
-}
withPageSize : String -> Builder { a | pageSize : Available } slotCaps msg kind -> Builder { a | pageSize : Used } slotCaps msg kind
withPageSize value_ =
    B.withAttribute (A.pageSize value_)


{-| Pipe form of `pageSizeVariant` — consumes its capability (write-once).
-}
withPageSizeVariant : Value Component.PageSizeVariant -> Builder { a | pageSizeVariant : Available } slotCaps msg kind -> Builder { a | pageSizeVariant : Used } slotCaps msg kind
withPageSizeVariant value_ =
    B.withAttribute (Component.pageSizeVariant value_)


{-| Pipe form of `pageSizes` — consumes its capability (write-once).
-}
withPageSizes : String -> Builder { a | pageSizes : Available } slotCaps msg kind -> Builder { a | pageSizes : Used } slotCaps msg kind
withPageSizes value_ =
    B.withAttribute (A.pageSizes value_)


{-| Pipe form of `previousPageLabel` — consumes its capability (write-once).
-}
withPreviousPageLabel : String -> Builder { a | previousPageLabel : Available } slotCaps msg kind -> Builder { a | previousPageLabel : Used } slotCaps msg kind
withPreviousPageLabel value_ =
    B.withAttribute (A.previousPageLabel value_)


{-| Pipe form of `showFirstLastButtons` — consumes its capability (write-once).
-}
withShowFirstLastButtons : Bool -> Builder { a | showFirstLastButtons : Available } slotCaps msg kind -> Builder { a | showFirstLastButtons : Used } slotCaps msg kind
withShowFirstLastButtons value_ =
    B.withAttribute (A.showFirstLastButtons value_)


{-| Pipe form of `onPage` — consumes its capability (write-once).
-}
withOnPage : (String -> msg) -> Builder { a | onPage : Available } slotCaps msg kind -> Builder { a | onPage : Used } slotCaps msg kind
withOnPage value_ =
    B.withAttribute (Component.onPage value_)
