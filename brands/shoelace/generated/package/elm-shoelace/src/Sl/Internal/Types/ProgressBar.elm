module Sl.Internal.Types.ProgressBar exposing (..)

{-| Internal type definitions for ProgressBar — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | progressBar : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , indeterminate : Supported
    , label : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | progressBar : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , indeterminate : Available
    , label : Available
    , slot : Available
    , style : Available
    , value : Available
    }
