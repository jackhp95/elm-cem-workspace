module M3e.Internal.Types.Toc exposing (..)

{-| Internal type definitions for Toc — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | toc : Brand }


type alias Attrs =
    { class : Supported
    , for : Supported
    , id : Supported
    , maxDepth : Supported
    , slot : Supported
    , style : Supported
    }


type alias OverlineSlot =
    { heading : Brand
    , sharedText : Shared
    }


type alias TitleSlot =
    { heading : Brand
    , sharedText : Shared
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | toc : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , for : Available
    , id : Available
    , maxDepth : Available
    , slot : Available
    , style : Available
    }


type alias SlotCaps =
    { overline : Available
    , title : Available
    }
