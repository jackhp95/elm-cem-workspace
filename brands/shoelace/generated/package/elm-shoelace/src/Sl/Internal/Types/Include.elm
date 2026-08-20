module Sl.Internal.Types.Include exposing (..)

{-| Internal type definitions for Include — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | include : Brand }


type alias Attrs =
    { allowScripts : Supported
    , class : Supported
    , id : Supported
    , mode : Supported
    , onError : Supported
    , onLoad : Supported
    , slot : Supported
    , src : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | include : Ctx }


type alias Mode =
    { cors : Supported
    , noCors : Supported
    , sameOrigin : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { allowScripts : Available
    , class : Available
    , id : Available
    , mode : Available
    , onError : Available
    , onLoad : Available
    , slot : Available
    , src : Available
    , style : Available
    }
