module Sl.Internal.Types.Details exposing (..)

{-| Internal type definitions for Details — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | details : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , onAfterHide : Supported
    , onAfterShow : Supported
    , onHide : Supported
    , onShow : Supported
    , open : Supported
    , slot : Supported
    , style : Supported
    , summary : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | details : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , onAfterHide : Available
    , onAfterShow : Available
    , onHide : Available
    , onShow : Available
    , open : Available
    , slot : Available
    , style : Available
    , summary : Available
    }
