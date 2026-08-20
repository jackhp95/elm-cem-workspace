module Sl.Internal.Types.Skeleton exposing (..)

{-| Internal type definitions for Skeleton — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | skeleton : Brand }


type alias Attrs =
    { class : Supported
    , effect_ : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | skeleton : Ctx }


type alias Effect =
    { none : Supported
    , pulse : Supported
    , sheen : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , effect_ : Available
    , id : Available
    , slot : Available
    , style : Available
    }
