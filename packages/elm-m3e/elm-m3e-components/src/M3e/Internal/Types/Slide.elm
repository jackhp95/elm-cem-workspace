module M3e.Internal.Types.Slide exposing (..)

{-| Internal type definitions for Slide — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | slide : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , selectedIndex : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | slide : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , selectedIndex : Available
    , slot : Available
    , style : Available
    }
