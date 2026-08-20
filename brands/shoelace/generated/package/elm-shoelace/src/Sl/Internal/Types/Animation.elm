module Sl.Internal.Types.Animation exposing (..)

{-| Internal type definitions for Animation — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | animation : Brand }


type alias Attrs =
    { class : Supported
    , delay : Supported
    , direction : Supported
    , duration : Supported
    , easing : Supported
    , endDelay : Supported
    , fill : Supported
    , id : Supported
    , iterationStart : Supported
    , iterations : Supported
    , name : Supported
    , onCancel : Supported
    , onFinish : Supported
    , onStart : Supported
    , play : Supported
    , playbackRate : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | animation : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , delay : Available
    , direction : Available
    , duration : Available
    , easing : Available
    , endDelay : Available
    , fill : Available
    , id : Available
    , iterationStart : Available
    , iterations : Available
    , name : Available
    , onCancel : Available
    , onFinish : Available
    , onStart : Available
    , play : Available
    , playbackRate : Available
    , slot : Available
    , style : Available
    }
