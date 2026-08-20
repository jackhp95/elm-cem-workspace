module Sl.Internal.Types.AnimatedImage exposing (..)

{-| Internal type definitions for AnimatedImage — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | animatedImage : Brand }


type alias Attrs =
    { alt : Supported
    , class : Supported
    , id : Supported
    , onError : Supported
    , onLoad : Supported
    , play : Supported
    , slot : Supported
    , src : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | animatedImage : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { alt : Available
    , class : Available
    , id : Available
    , onError : Available
    , onLoad : Available
    , play : Available
    , slot : Available
    , src : Available
    , style : Available
    }
