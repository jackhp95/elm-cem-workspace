module M3e.Internal.Types.BreadcrumbItem exposing (Is, Attrs, Content, IconSlot, ChildAdmittedBy, Current, Builder, AttrCaps, SlotCaps)

{-| Type definitions for BreadcrumbItem. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.BreadcrumbItem` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, IconSlot, ChildAdmittedBy, Current, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for BreadcrumbItem (generated).
-}
type alias Is s =
    { s | breadcrumbItem : Brand }


{-| The `Attrs` type row for BreadcrumbItem (generated).
-}
type alias Attrs =
    { class : Supported
    , current : Supported
    , disabled : Supported
    , download : Supported
    , href : Supported
    , id : Supported
    , itemLabel : Supported
    , onClick : Supported
    , rel : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    }


{-| The `Content` type row for BreadcrumbItem (generated).
-}
type alias Content =
    { heading : Brand
    , sharedIcon : Shared
    , sharedText : Shared
    }


{-| The `IconSlot` type row for BreadcrumbItem (generated).
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for BreadcrumbItem (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | breadcrumbItem : Ctx }


{-| The `Current` type row for BreadcrumbItem (generated).
-}
type alias Current =
    { date : Supported
    , location : Supported
    , page : Supported
    , step : Supported
    , time : Supported
    , true : Supported
    }


{-| The `Builder` type row for BreadcrumbItem (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for BreadcrumbItem (generated).
-}
type alias AttrCaps =
    { class : Available
    , current : Available
    , disabled : Available
    , download : Available
    , href : Available
    , id : Available
    , itemLabel : Available
    , onClick : Available
    , rel : Available
    , slot : Available
    , style : Available
    , target : Available
    }


{-| The `SlotCaps` type row for BreadcrumbItem (generated).
-}
type alias SlotCaps =
    { icon : Available
    }
