module Sl.Internal.Types.MenuItem exposing (..)

{-| Internal type definitions for MenuItem — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | menuItem : Brand }


type alias Attrs =
    { checked : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , loading : Supported
    , slot : Supported
    , style : Supported
    , type_ : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | menuItem : Ctx }


type alias Type =
    { checkbox : Supported
    , normal : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { checked : Available
    , class : Available
    , disabled : Available
    , id : Available
    , loading : Available
    , slot : Available
    , style : Available
    , type_ : Available
    , value : Available
    }
