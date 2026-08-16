module M3e.Component.Paginator exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, FirstPageIconSlot, LastPageIconSlot, NextPageIconSlot, PreviousPageIconSlot, ChildAdmittedBy
    , PageSizeVariant, pageSizeVariant
    , disabled, firstPageLabel, hidePageSize, itemsPerPageLabel, lastPageLabel, length, nextPageLabel, pageIndex, pageSize, pageSizes, previousPageLabel, showFirstLastButtons, onPage
    , firstPageIcon, lastPageIcon, nextPageIcon, previousPageIcon
    )

{-| The `m3e-paginator` component — strict per-component surface.

Provides navigation for paged information, typically used with a table.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, FirstPageIconSlot, LastPageIconSlot, NextPageIconSlot, PreviousPageIconSlot, ChildAdmittedBy
@docs PageSizeVariant, pageSizeVariant
@docs disabled, firstPageLabel, hidePageSize, itemsPerPageLabel, lastPageLabel, length, nextPageLabel, pageIndex, pageSize, pageSizes, previousPageLabel, showFirstLastButtons, onPage
@docs firstPageIcon, lastPageIcon, nextPageIcon, previousPageIcon

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Decode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Paginator
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-paginator` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Paginator.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Paginator.Attrs


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


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Paginator.ChildAdmittedBy childAdm


{-| The `pageSizeVariant` values valid on this component (compile-tight narrowing).
-}
type alias PageSizeVariant =
    M3e.Internal.Types.Paginator.PageSizeVariant


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Paginator.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Paginator.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.Paginator.SlotCaps


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.paginator


{-| The appearance variant of the page size field. (default: `"outlined"`)
-}
pageSizeVariant : Value PageSizeVariant -> Attr { c | pageSizeVariant : Supported } msg
pageSizeVariant value_ =
    Ir.attribute "page-size-variant" (Val.toString value_)


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.firstPageLabel`.
-}
firstPageLabel : String -> Attr { c | firstPageLabel : Supported } msg
firstPageLabel =
    A.firstPageLabel


{-| See `M3e.Attributes.hidePageSize`.
-}
hidePageSize : Bool -> Attr { c | hidePageSize : Supported } msg
hidePageSize =
    A.hidePageSize


{-| See `M3e.Attributes.itemsPerPageLabel`.
-}
itemsPerPageLabel : String -> Attr { c | itemsPerPageLabel : Supported } msg
itemsPerPageLabel =
    A.itemsPerPageLabel


{-| See `M3e.Attributes.lastPageLabel`.
-}
lastPageLabel : String -> Attr { c | lastPageLabel : Supported } msg
lastPageLabel =
    A.lastPageLabel


{-| See `M3e.Attributes.length`.
-}
length : Float -> Attr { c | length : Supported } msg
length =
    A.length


{-| See `M3e.Attributes.nextPageLabel`.
-}
nextPageLabel : String -> Attr { c | nextPageLabel : Supported } msg
nextPageLabel =
    A.nextPageLabel


{-| See `M3e.Attributes.pageIndex`.
-}
pageIndex : Float -> Attr { c | pageIndex : Supported } msg
pageIndex =
    A.pageIndex


{-| See `M3e.Attributes.pageSize`.
-}
pageSize : String -> Attr { c | pageSize : Supported } msg
pageSize =
    A.pageSize


{-| See `M3e.Attributes.pageSizes`.
-}
pageSizes : String -> Attr { c | pageSizes : Supported } msg
pageSizes =
    A.pageSizes


{-| See `M3e.Attributes.previousPageLabel`.
-}
previousPageLabel : String -> Attr { c | previousPageLabel : Supported } msg
previousPageLabel =
    A.previousPageLabel


{-| See `M3e.Attributes.showFirstLastButtons`.
-}
showFirstLastButtons : Bool -> Attr { c | showFirstLastButtons : Supported } msg
showFirstLastButtons =
    A.showFirstLastButtons


{-| Typed `page` event: decodes `detail.pageIndex` as String.
-}
onPage : (String -> msg) -> Attr { c | onPage : Supported } msg
onPage toMsg =
    Ir.on "page" (Json.Decode.map toMsg (Json.Decode.at [ "detail", "pageIndex" ] Json.Decode.string))


{-| Place an element into the named `first-page-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
firstPageIcon : Element FirstPageIconSlot admittedBy msg -> Element free freeAdmittedBy msg
firstPageIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "first-page-icon") (El.toNode element))


{-| Place an element into the named `last-page-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
lastPageIcon : Element LastPageIconSlot admittedBy msg -> Element free freeAdmittedBy msg
lastPageIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "last-page-icon") (El.toNode element))


{-| Place an element into the named `next-page-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
nextPageIcon : Element NextPageIconSlot admittedBy msg -> Element free freeAdmittedBy msg
nextPageIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "next-page-icon") (El.toNode element))


{-| Place an element into the named `previous-page-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
previousPageIcon : Element PreviousPageIconSlot admittedBy msg -> Element free freeAdmittedBy msg
previousPageIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "previous-page-icon") (El.toNode element))
