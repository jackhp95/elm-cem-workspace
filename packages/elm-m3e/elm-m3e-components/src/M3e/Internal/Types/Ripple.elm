module M3e.Internal.Types.Ripple exposing (..)

{-| Internal type definitions for Ripple — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | ripple : Brand }


type alias Attrs =
    { centered : Supported
    , class : Supported
    , disabled : Supported
    , for : Supported
    , id : Supported
    , radius : Supported
    , slot : Supported
    , style : Supported
    , unbounded : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | ripple : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { centered : Available
    , class : Available
    , disabled : Available
    , for : Available
    , id : Available
    , radius : Available
    , slot : Available
    , style : Available
    , unbounded : Available
    }
