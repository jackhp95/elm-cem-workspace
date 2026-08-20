module M3e.Internal.Types.BreadcrumbItem exposing (..)

{-| Internal type definitions for BreadcrumbItem — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | breadcrumbItem : Brand }


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


type alias Content =
    { heading : Brand
    , sharedIcon : Shared
    , sharedText : Shared
    }


type alias IconSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | breadcrumbItem : Ctx }


type alias Current =
    { date : Supported
    , location : Supported
    , page : Supported
    , step : Supported
    , time : Supported
    , true : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


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


type alias SlotCaps =
    { icon : Available
    }
