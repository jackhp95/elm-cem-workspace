module M3e.Internal.Types.TextareaAutosize exposing (..)

{-| Internal type definitions for TextareaAutosize — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | textareaAutosize : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , for : Supported
    , id : Supported
    , maxRows : Supported
    , minRows : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | textareaAutosize : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , for : Available
    , id : Available
    , maxRows : Available
    , minRows : Available
    , slot : Available
    , style : Available
    }
