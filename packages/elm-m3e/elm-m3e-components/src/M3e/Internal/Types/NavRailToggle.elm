module M3e.Internal.Types.NavRailToggle exposing (..)

{-| Internal type definitions for NavRailToggle — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | navRailToggle : Brand }


type alias Attrs =
    { class : Supported
    , for : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | navRailToggle : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , for : Available
    , id : Available
    , slot : Available
    , style : Available
    }
