module Sl.Internal.Types.IconButton exposing (..)

{-| Internal type definitions for IconButton — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | iconButton : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , download : Supported
    , href : Supported
    , id : Supported
    , label : Supported
    , library : Supported
    , name : Supported
    , onBlur : Supported
    , onFocus : Supported
    , slot : Supported
    , src : Supported
    , style : Supported
    , target : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | iconButton : Ctx }


type alias Target =
    { blank_ : Supported
    , parent_ : Supported
    , self_ : Supported
    , top_ : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , download : Available
    , href : Available
    , id : Available
    , label : Available
    , library : Available
    , name : Available
    , onBlur : Available
    , onFocus : Available
    , slot : Available
    , src : Available
    , style : Available
    , target : Available
    }
