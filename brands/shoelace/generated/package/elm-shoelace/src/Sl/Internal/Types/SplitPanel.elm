module Sl.Internal.Types.SplitPanel exposing (..)

{-| Internal type definitions for SplitPanel — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | splitPanel : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , onReposition : Supported
    , position : Supported
    , positionInPixels : Supported
    , primary : Supported
    , slot : Supported
    , snap : Supported
    , snapThreshold : Supported
    , style : Supported
    , vertical : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | splitPanel : Ctx }


type alias Primary =
    { end : Supported
    , start : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , onReposition : Available
    , position : Available
    , positionInPixels : Available
    , primary : Available
    , slot : Available
    , snap : Available
    , snapThreshold : Available
    , style : Available
    , vertical : Available
    }
