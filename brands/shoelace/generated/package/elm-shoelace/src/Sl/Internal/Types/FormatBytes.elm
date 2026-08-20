module Sl.Internal.Types.FormatBytes exposing (..)

{-| Internal type definitions for FormatBytes — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | formatBytes : Brand }


type alias Attrs =
    { class : Supported
    , display : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , unit : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | formatBytes : Ctx }


type alias Display =
    { long : Supported
    , narrow : Supported
    , short : Supported
    }


type alias Unit =
    { bit : Supported
    , byte : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , display : Available
    , id : Available
    , slot : Available
    , style : Available
    , unit : Available
    , value : Available
    }
