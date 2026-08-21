module M3e.Internal.Types.BreadcrumbItemButton exposing (Is, Attrs, Content, ChildAdmittedBy, Current, Builder, AttrCaps)

{-| Type definitions for BreadcrumbItemButton. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.BreadcrumbItemButton` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Current, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for BreadcrumbItemButton (generated).
-}
type alias Is s =
    { s | breadcrumbItemButton : Brand }


{-| The `Attrs` type row for BreadcrumbItemButton (generated).
-}
type alias Attrs =
    { class : Supported
    , current : Supported
    , disabled : Supported
    , download : Supported
    , href : Supported
    , id : Supported
    , onClick : Supported
    , rel : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    }


{-| The `Content` type row for BreadcrumbItemButton (generated).
-}
type alias Content =
    { heading : Brand
    , sharedIcon : Shared
    , sharedText : Shared
    }


{-| The `ChildAdmittedBy` type row for BreadcrumbItemButton (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | breadcrumbItemButton : Ctx }


{-| The `Current` type row for BreadcrumbItemButton (generated).
-}
type alias Current =
    { date : Supported
    , location : Supported
    , page : Supported
    , step : Supported
    , time : Supported
    , true : Supported
    }


{-| The `Builder` type row for BreadcrumbItemButton (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for BreadcrumbItemButton (generated).
-}
type alias AttrCaps =
    { class : Available
    , current : Available
    , disabled : Available
    , download : Available
    , href : Available
    , id : Available
    , onClick : Available
    , rel : Available
    , slot : Available
    , style : Available
    , target : Available
    }
