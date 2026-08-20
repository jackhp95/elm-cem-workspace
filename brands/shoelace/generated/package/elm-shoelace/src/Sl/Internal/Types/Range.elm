module Sl.Internal.Types.Range exposing (..)

{-| Internal type definitions for Range — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | range : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , form : Supported
    , helpText : Supported
    , id : Supported
    , label : Supported
    , max : Supported
    , min : Supported
    , name : Supported
    , onBlur : Supported
    , onChange : Supported
    , onFocus : Supported
    , onInput : Supported
    , onInvalid : Supported
    , slot : Supported
    , step : Supported
    , style : Supported
    , title : Supported
    , tooltip : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | range : Ctx }


type alias Tooltip =
    { bottom : Supported
    , none : Supported
    , top : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , form : Available
    , helpText : Available
    , id : Available
    , label : Available
    , max : Available
    , min : Available
    , name : Available
    , onBlur : Available
    , onChange : Available
    , onFocus : Available
    , onInput : Available
    , onInvalid : Available
    , slot : Available
    , step : Available
    , style : Available
    , title : Available
    , tooltip : Available
    , value : Available
    }
