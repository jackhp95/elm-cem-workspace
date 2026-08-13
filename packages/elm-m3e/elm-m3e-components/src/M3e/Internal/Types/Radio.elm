module M3e.Internal.Types.Radio exposing (..)

{-| Internal type definitions for Radio — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | radio : Brand }


type alias Attrs =
    { checked : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , required : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | radio : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { checked : Available
    , class : Available
    , disabled : Available
    , id : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , required : Available
    , slot : Available
    , style : Available
    , value : Available
    }
