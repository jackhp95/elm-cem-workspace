module M3e.Internal.Types.ChipSet exposing (..)

{-| Internal type definitions for ChipSet — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | chipSet : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , vertical : Supported
    }


type alias Content =
    { assistChip : Brand
    , chip : Brand
    , filterChip : Brand
    , inputChip : Brand
    , suggestionChip : Brand
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | chipSet : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    , vertical : Available
    }
