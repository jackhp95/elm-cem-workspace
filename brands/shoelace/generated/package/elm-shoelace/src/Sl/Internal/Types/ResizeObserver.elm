module Sl.Internal.Types.ResizeObserver exposing (..)

{-| Internal type definitions for ResizeObserver — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | resizeObserver : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , onResize : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | resizeObserver : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , onResize : Available
    , slot : Available
    , style : Available
    }
