module Sl.Internal.Types.Avatar exposing (..)

{-| Internal type definitions for Avatar — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | avatar : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , image : Supported
    , initials : Supported
    , label : Supported
    , loading : Supported
    , onError : Supported
    , shape : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | avatar : Ctx }


type alias Loading =
    { eager : Supported
    , lazy : Supported
    }


type alias Shape =
    { circle : Supported
    , rounded : Supported
    , square : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , image : Available
    , initials : Available
    , label : Available
    , loading : Available
    , onError : Available
    , shape : Available
    , slot : Available
    , style : Available
    }
