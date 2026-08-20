module Sl.Internal.Types.ProgressRing exposing (..)

{-| Internal type definitions for ProgressRing — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | progressRing : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , label : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | progressRing : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , label : Available
    , slot : Available
    , style : Available
    , value : Available
    }
