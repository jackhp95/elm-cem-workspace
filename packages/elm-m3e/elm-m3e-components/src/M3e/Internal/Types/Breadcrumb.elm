module M3e.Internal.Types.Breadcrumb exposing (..)

{-| Internal type definitions for Breadcrumb — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | breadcrumb : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , wrap : Supported
    }


type alias Content =
    { breadcrumbItem : Brand }


type alias ChildAdmittedBy childAdm =
    { childAdm | breadcrumb : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    , wrap : Available
    }


type alias SlotCaps =
    { separator : Available
    }
