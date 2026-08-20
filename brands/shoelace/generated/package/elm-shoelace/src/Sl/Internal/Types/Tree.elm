module Sl.Internal.Types.Tree exposing (..)

{-| Internal type definitions for Tree — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | tree : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , onSelectionChange : Supported
    , selection : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | tree : Ctx }


type alias Selection =
    { leaf : Supported
    , multiple : Supported
    , single : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , onSelectionChange : Available
    , selection : Available
    , slot : Available
    , style : Available
    }
