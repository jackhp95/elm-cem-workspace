module M3e.Build.Paginator exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, FirstPageIconSlot, LastPageIconSlot, NextPageIconSlot, PreviousPageIconSlot, ChildAdmittedBy
    , withClass, withDisabled, withFirstPageLabel, withHidePageSize, withId, withItemsPerPageLabel, withLastPageLabel, withLength, withNextPageLabel, withOnPage, withPageIndex, withPageSize, withPageSizeVariant, withPageSizes, withPreviousPageLabel, withShowFirstLastButtons, withSlot, withStyle
    , firstPageIcon, lastPageIcon, nextPageIcon, previousPageIcon
    , withFirstPageIcon, withLastPageIcon, withNextPageIcon, withPreviousPageIcon
    )

{-|

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
import M3e.Component.Paginator as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.AttrCaps


{-| -}
type alias SlotCaps =
    Component.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ChildAdmittedBy childAdm


{-| -}
type alias FirstPageIconSlot =
    Component.FirstPageIconSlot


{-| -}
type alias LastPageIconSlot =
    Component.LastPageIconSlot


{-| -}
type alias NextPageIconSlot =
    Component.NextPageIconSlot


{-| -}
type alias PreviousPageIconSlot =
    Component.PreviousPageIconSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-paginator" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
firstPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.FirstPageIconSlot msg
    -> Element free freeAdmittedBy msg
firstPageIcon builder =
    Component.firstPageIcon (B.toElement builder)


{-| -}
lastPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.LastPageIconSlot msg
    -> Element free freeAdmittedBy msg
lastPageIcon builder =
    Component.lastPageIcon (B.toElement builder)


{-| -}
nextPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.NextPageIconSlot msg
    -> Element free freeAdmittedBy msg
nextPageIcon builder =
    Component.nextPageIcon (B.toElement builder)


{-| -}
previousPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PreviousPageIconSlot msg
    -> Element free freeAdmittedBy msg
previousPageIcon builder =
    Component.previousPageIcon (B.toElement builder)


{-| -}
withFirstPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.FirstPageIconSlot msg
    -> Builder attrCaps { s | firstPageIcon : Available } msg kind
    -> Builder attrCaps { s | firstPageIcon : Used } msg kind
withFirstPageIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.firstPageIcon (B.toElement slotBuilder))) builder_


{-| -}
withLastPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.LastPageIconSlot msg
    -> Builder attrCaps { s | lastPageIcon : Available } msg kind
    -> Builder attrCaps { s | lastPageIcon : Used } msg kind
withLastPageIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.lastPageIcon (B.toElement slotBuilder))) builder_


{-| -}
withNextPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.NextPageIconSlot msg
    -> Builder attrCaps { s | nextPageIcon : Available } msg kind
    -> Builder attrCaps { s | nextPageIcon : Used } msg kind
withNextPageIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.nextPageIcon (B.toElement slotBuilder))) builder_


{-| -}
withPreviousPageIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PreviousPageIconSlot msg
    -> Builder attrCaps { s | previousPageIcon : Available } msg kind
    -> Builder attrCaps { s | previousPageIcon : Used } msg kind
withPreviousPageIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.previousPageIcon (B.toElement slotBuilder))) builder_


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
withPageSizeVariant : Value Component.PageSizeVariant -> Builder { a | pageSizeVariant : Available } slotCaps msg kind -> Builder { a | pageSizeVariant : Used } slotCaps msg kind
withPageSizeVariant value_ =
    B.withAttribute (Component.pageSizeVariant value_)


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
    B.withAttribute (Component.onPage value_)
