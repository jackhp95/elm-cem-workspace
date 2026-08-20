module Sl.Internal.Types.Icon exposing (..)

{-| Internal type definitions for Icon — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | icon : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , label : Supported
    , library : Supported
    , name : Supported
    , onError : Supported
    , onLoad : Supported
    , slot : Supported
    , src : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | icon : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , label : Available
    , library : Available
    , name : Available
    , onError : Available
    , onLoad : Available
    , slot : Available
    , src : Available
    , style : Available
    }
