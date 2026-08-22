module M3e.Build.Paginator exposing (Builder, AttrCaps, SlotCaps, Is, FirstPageIconSlot, LastPageIconSlot, NextPageIconSlot, PreviousPageIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withFirstPageLabel, withHidePageSize, withId, withItemsPerPageLabel, withLastPageLabel, withLength, withNextPageLabel, withOnPage, withPageIndex, withPageSize, withPageSizeVariant, withPageSizes, withPreviousPageLabel, withShowFirstLastButtons, withSlot, withStyle, firstPageIcon, lastPageIcon, nextPageIcon, previousPageIcon, withFirstPageIcon, withLastPageIcon, withNextPageIcon, withPreviousPageIcon)

{-| The **Paginator** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.Paginator`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, FirstPageIconSlot, LastPageIconSlot, NextPageIconSlot, PreviousPageIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withFirstPageLabel, withHidePageSize, withId, withItemsPerPageLabel, withLastPageLabel, withLength, withNextPageLabel, withOnPage, withPageIndex, withPageSize, withPageSizeVariant, withPageSizes, withPreviousPageLabel, withShowFirstLastButtons, withSlot, withStyle, firstPageIcon, lastPageIcon, nextPageIcon, previousPageIcon, withFirstPageIcon, withLastPageIcon, withNextPageIcon, withPreviousPageIcon

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Paginator as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.PaginatorIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.PaginatorBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.PaginatorAttrCaps


{-| -}
type alias SlotCaps =
    Component.PaginatorSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.PaginatorChildAdmittedBy childAdm


{-| -}
type alias FirstPageIconSlot =
    Component.PaginatorFirstPageIconSlot


{-| -}
type alias LastPageIconSlot =
    Component.PaginatorLastPageIconSlot


{-| -}
type alias NextPageIconSlot =
    Component.PaginatorNextPageIconSlot


{-| -}
type alias PreviousPageIconSlot =
    Component.PaginatorPreviousPageIconSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-paginator" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.PaginatorIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
firstPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PaginatorFirstPageIconSlot msg
    -> Element free freeAdmittedBy msg
firstPageIcon builder =
    Component.paginatorFirstPageIcon (B.toElement builder)


{-| -}
lastPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PaginatorLastPageIconSlot msg
    -> Element free freeAdmittedBy msg
lastPageIcon builder =
    Component.paginatorLastPageIcon (B.toElement builder)


{-| -}
nextPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PaginatorNextPageIconSlot msg
    -> Element free freeAdmittedBy msg
nextPageIcon builder =
    Component.paginatorNextPageIcon (B.toElement builder)


{-| -}
previousPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PaginatorPreviousPageIconSlot msg
    -> Element free freeAdmittedBy msg
previousPageIcon builder =
    Component.paginatorPreviousPageIcon (B.toElement builder)


{-| -}
withFirstPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PaginatorFirstPageIconSlot msg
    -> Builder attrCaps { s | firstPageIcon : Available } msg kind
    -> Builder attrCaps { s | firstPageIcon : Used } msg kind
withFirstPageIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.paginatorFirstPageIcon (B.toElement slotBuilder))) builder_


{-| -}
withLastPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PaginatorLastPageIconSlot msg
    -> Builder attrCaps { s | lastPageIcon : Available } msg kind
    -> Builder attrCaps { s | lastPageIcon : Used } msg kind
withLastPageIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.paginatorLastPageIcon (B.toElement slotBuilder))) builder_


{-| -}
withNextPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PaginatorNextPageIconSlot msg
    -> Builder attrCaps { s | nextPageIcon : Available } msg kind
    -> Builder attrCaps { s | nextPageIcon : Used } msg kind
withNextPageIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.paginatorNextPageIcon (B.toElement slotBuilder))) builder_


{-| -}
withPreviousPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PaginatorPreviousPageIconSlot msg
    -> Builder attrCaps { s | previousPageIcon : Available } msg kind
    -> Builder attrCaps { s | previousPageIcon : Used } msg kind
withPreviousPageIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.paginatorPreviousPageIcon (B.toElement slotBuilder))) builder_


{-| -}
withClass : String -> Builder { a | class : Available } slotCaps msg kind -> Builder { a | class : Used } slotCaps msg kind
withClass value_ =
    B.withAttribute (A.class value_)


{-| -}
withId : String -> Builder { a | id : Available } slotCaps msg kind -> Builder { a | id : Used } slotCaps msg kind
withId value_ =
    B.withAttribute (A.id value_)


{-| -}
withSlot : String -> Builder { a | slot : Available } slotCaps msg kind -> Builder { a | slot : Used } slotCaps msg kind
withSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
withStyle : String -> String -> Builder { a | style : Available } slotCaps msg kind -> Builder { a | style : Used } slotCaps msg kind
withStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withFirstPageLabel : String -> Builder { a | firstPageLabel : Available } slotCaps msg kind -> Builder { a | firstPageLabel : Used } slotCaps msg kind
withFirstPageLabel value_ =
    B.withAttribute (A.firstPageLabel value_)


{-| -}
withHidePageSize : Bool -> Builder { a | hidePageSize : Available } slotCaps msg kind -> Builder { a | hidePageSize : Used } slotCaps msg kind
withHidePageSize value_ =
    B.withAttribute (A.hidePageSize value_)


{-| -}
withItemsPerPageLabel : String -> Builder { a | itemsPerPageLabel : Available } slotCaps msg kind -> Builder { a | itemsPerPageLabel : Used } slotCaps msg kind
withItemsPerPageLabel value_ =
    B.withAttribute (A.itemsPerPageLabel value_)


{-| -}
withLastPageLabel : String -> Builder { a | lastPageLabel : Available } slotCaps msg kind -> Builder { a | lastPageLabel : Used } slotCaps msg kind
withLastPageLabel value_ =
    B.withAttribute (A.lastPageLabel value_)


{-| -}
withLength : Float -> Builder { a | length : Available } slotCaps msg kind -> Builder { a | length : Used } slotCaps msg kind
withLength value_ =
    B.withAttribute (A.length value_)


{-| -}
withNextPageLabel : String -> Builder { a | nextPageLabel : Available } slotCaps msg kind -> Builder { a | nextPageLabel : Used } slotCaps msg kind
withNextPageLabel value_ =
    B.withAttribute (A.nextPageLabel value_)


{-| -}
withPageIndex : Float -> Builder { a | pageIndex : Available } slotCaps msg kind -> Builder { a | pageIndex : Used } slotCaps msg kind
withPageIndex value_ =
    B.withAttribute (A.pageIndex value_)


{-| -}
withPageSize : String -> Builder { a | pageSize : Available } slotCaps msg kind -> Builder { a | pageSize : Used } slotCaps msg kind
withPageSize value_ =
    B.withAttribute (A.pageSize value_)


{-| -}
withPageSizeVariant : Value Component.PaginatorPageSizeVariant -> Builder { a | pageSizeVariant : Available } slotCaps msg kind -> Builder { a | pageSizeVariant : Used } slotCaps msg kind
withPageSizeVariant value_ =
    B.withAttribute (Component.paginatorPageSizeVariant value_)


{-| -}
withPageSizes : String -> Builder { a | pageSizes : Available } slotCaps msg kind -> Builder { a | pageSizes : Used } slotCaps msg kind
withPageSizes value_ =
    B.withAttribute (A.pageSizes value_)


{-| -}
withPreviousPageLabel : String -> Builder { a | previousPageLabel : Available } slotCaps msg kind -> Builder { a | previousPageLabel : Used } slotCaps msg kind
withPreviousPageLabel value_ =
    B.withAttribute (A.previousPageLabel value_)


{-| -}
withShowFirstLastButtons : Bool -> Builder { a | showFirstLastButtons : Available } slotCaps msg kind -> Builder { a | showFirstLastButtons : Used } slotCaps msg kind
withShowFirstLastButtons value_ =
    B.withAttribute (A.showFirstLastButtons value_)


{-| -}
withOnPage : (String -> msg) -> Builder { a | onPage : Available } slotCaps msg kind -> Builder { a | onPage : Used } slotCaps msg kind
withOnPage value_ =
    B.withAttribute (Component.paginatorOnPage value_)
