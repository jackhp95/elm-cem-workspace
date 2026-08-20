module Sl.Internal.Types.QrCode exposing (..)

{-| Internal type definitions for QrCode — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | qrCode : Brand }


type alias Attrs =
    { background : Supported
    , class : Supported
    , errorCorrection : Supported
    , fill : Supported
    , id : Supported
    , label : Supported
    , radius : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | qrCode : Ctx }


type alias ErrorCorrection =
    { h : Supported
    , l : Supported
    , m : Supported
    , q : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { background : Available
    , class : Available
    , errorCorrection : Available
    , fill : Available
    , id : Available
    , label : Available
    , radius : Available
    , size : Available
    , slot : Available
    , style : Available
    , value : Available
    }
