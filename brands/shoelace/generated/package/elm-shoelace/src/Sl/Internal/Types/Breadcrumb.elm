module Sl.Internal.Types.Breadcrumb exposing (..)

{-| Internal type definitions for Breadcrumb — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | breadcrumb : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , label : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | breadcrumb : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , label : Available
    , slot : Available
    , style : Available
    }
