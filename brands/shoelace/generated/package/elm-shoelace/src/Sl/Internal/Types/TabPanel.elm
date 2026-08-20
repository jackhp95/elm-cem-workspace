module Sl.Internal.Types.TabPanel exposing (..)

{-| Internal type definitions for TabPanel — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | tabPanel : Brand }


type alias Attrs =
    { active : Supported
    , class : Supported
    , id : Supported
    , name : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | tabPanel : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { active : Available
    , class : Available
    , id : Available
    , name : Available
    , slot : Available
    , style : Available
    }
