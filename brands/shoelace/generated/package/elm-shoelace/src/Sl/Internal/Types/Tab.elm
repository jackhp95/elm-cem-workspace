module Sl.Internal.Types.Tab exposing (..)

{-| Internal type definitions for Tab — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | tab : Brand }


type alias Attrs =
    { active : Supported
    , class : Supported
    , closable : Supported
    , disabled : Supported
    , id : Supported
    , onClose : Supported
    , panel : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | tab : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { active : Available
    , class : Available
    , closable : Available
    , disabled : Available
    , id : Available
    , onClose : Available
    , panel : Available
    , slot : Available
    , style : Available
    }
