module M3e.Internal.Types.DialogAction exposing (..)

{-| Internal type definitions for DialogAction — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | dialogAction : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , returnValue : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | dialogAction : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , returnValue : Available
    , slot : Available
    , style : Available
    }
