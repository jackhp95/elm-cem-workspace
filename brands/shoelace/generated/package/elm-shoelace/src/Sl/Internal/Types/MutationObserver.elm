module Sl.Internal.Types.MutationObserver exposing (..)

{-| Internal type definitions for MutationObserver — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | mutationObserver : Brand }


type alias Attrs =
    { attr : Supported
    , attrOldValue : Supported
    , charData : Supported
    , charDataOldValue : Supported
    , childList : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , onMutation : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | mutationObserver : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { attr : Available
    , attrOldValue : Available
    , charData : Available
    , charDataOldValue : Available
    , childList : Available
    , class : Available
    , disabled : Available
    , id : Available
    , onMutation : Available
    , slot : Available
    , style : Available
    }
