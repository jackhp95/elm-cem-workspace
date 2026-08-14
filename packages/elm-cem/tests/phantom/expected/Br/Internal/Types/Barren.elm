module Br.Internal.Types.Barren exposing (..)

{-| Internal type definitions for Barren — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import Br.Forge.Internal as B
import Br.Kind exposing (Available, Brand, Ctx, Used)
import HtmlIr.Kind exposing (Supported)


type alias Is s =
    { s | barren : Brand }


type alias Attrs =
    { class : Supported
    , count : Supported
    , id : Supported
    , label : Supported
    , slot : Supported
    , style : Supported
    }


type alias Content =
    {}


type alias ChildAdmittedBy childAdm =
    { childAdm | barren : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , count : Available
    , id : Available
    , label : Available
    , slot : Available
    , style : Available
    }
