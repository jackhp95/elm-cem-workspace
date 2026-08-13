module M3e.Internal.Types.TocItem exposing (..)

{-| Internal type definitions for TocItem — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | tocItem : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , onClick : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    }


type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | tocItem : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , onClick : Available
    , selected : Available
    , slot : Available
    , style : Available
    }
