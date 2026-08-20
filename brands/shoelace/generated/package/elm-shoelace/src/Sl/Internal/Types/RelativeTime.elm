module Sl.Internal.Types.RelativeTime exposing (..)

{-| Internal type definitions for RelativeTime — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | relativeTime : Brand }


type alias Attrs =
    { class : Supported
    , date : Supported
    , format : Supported
    , id : Supported
    , numeric : Supported
    , slot : Supported
    , style : Supported
    , sync : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | relativeTime : Ctx }


type alias Format =
    { long : Supported
    , narrow : Supported
    , short : Supported
    }


type alias Numeric =
    { always : Supported
    , auto : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , date : Available
    , format : Available
    , id : Available
    , numeric : Available
    , slot : Available
    , style : Available
    , sync : Available
    }
