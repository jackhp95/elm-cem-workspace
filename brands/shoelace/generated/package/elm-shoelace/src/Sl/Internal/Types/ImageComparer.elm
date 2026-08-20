module Sl.Internal.Types.ImageComparer exposing (..)

{-| Internal type definitions for ImageComparer — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | imageComparer : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , onChange : Supported
    , position : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | imageComparer : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , onChange : Available
    , position : Available
    , slot : Available
    , style : Available
    }
