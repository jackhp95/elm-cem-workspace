module M3e.Internal.Types.Paginator exposing (Is, Attrs, FirstPageIconSlot, LastPageIconSlot, NextPageIconSlot, PreviousPageIconSlot, ChildAdmittedBy, PageSizeVariant, Builder, AttrCaps, SlotCaps)

{-| Type definitions for Paginator. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Paginator` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, FirstPageIconSlot, LastPageIconSlot, NextPageIconSlot, PreviousPageIconSlot, ChildAdmittedBy, PageSizeVariant, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Paginator (generated).
-}
type alias Is s =
    { s | paginator : Brand }


{-| The `Attrs` type row for Paginator (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , firstPageLabel : Supported
    , hidePageSize : Supported
    , id : Supported
    , itemsPerPageLabel : Supported
    , lastPageLabel : Supported
    , length : Supported
    , nextPageLabel : Supported
    , onPage : Supported
    , pageIndex : Supported
    , pageSize : Supported
    , pageSizeVariant : Supported
    , pageSizes : Supported
    , previousPageLabel : Supported
    , showFirstLastButtons : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `FirstPageIconSlot` type row for Paginator (generated).
-}
type alias FirstPageIconSlot =
    { sharedIcon : Shared }


{-| The `LastPageIconSlot` type row for Paginator (generated).
-}
type alias LastPageIconSlot =
    { sharedIcon : Shared }


{-| The `NextPageIconSlot` type row for Paginator (generated).
-}
type alias NextPageIconSlot =
    { sharedIcon : Shared }


{-| The `PreviousPageIconSlot` type row for Paginator (generated).
-}
type alias PreviousPageIconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for Paginator (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | paginator : Ctx }


{-| The `PageSizeVariant` type row for Paginator (generated).
-}
type alias PageSizeVariant =
    { filled : Supported
    , outlined : Supported
    }


{-| The `Builder` type row for Paginator (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Paginator (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , firstPageLabel : Available
    , hidePageSize : Available
    , id : Available
    , itemsPerPageLabel : Available
    , lastPageLabel : Available
    , length : Available
    , nextPageLabel : Available
    , onPage : Available
    , pageIndex : Available
    , pageSize : Available
    , pageSizeVariant : Available
    , pageSizes : Available
    , previousPageLabel : Available
    , showFirstLastButtons : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for Paginator (generated).
-}
type alias SlotCaps =
    { firstPageIcon : Available
    , lastPageIcon : Available
    , nextPageIcon : Available
    , previousPageIcon : Available
    }
