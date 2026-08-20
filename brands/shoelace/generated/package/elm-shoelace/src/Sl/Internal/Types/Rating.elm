module Sl.Internal.Types.Rating exposing (..)

{-| Internal type definitions for Rating — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | rating : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , getsymbol : Supported
    , id : Supported
    , label : Supported
    , max : Supported
    , onChange : Supported
    , onHover : Supported
    , precision : Supported
    , readonly : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | rating : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , getsymbol : Available
    , id : Available
    , label : Available
    , max : Available
    , onChange : Available
    , onHover : Available
    , precision : Available
    , readonly : Available
    , slot : Available
    , style : Available
    , value : Available
    }
