module Sl.Internal.Types.Switch exposing (..)

{-| Internal type definitions for Switch — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | switch : Brand }


type alias Attrs =
    { checked : Supported
    , class : Supported
    , disabled : Supported
    , form : Supported
    , helpText : Supported
    , id : Supported
    , name : Supported
    , onBlur : Supported
    , onChange : Supported
    , onFocus : Supported
    , onInput : Supported
    , onInvalid : Supported
    , required : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , title : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | switch : Ctx }


type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { checked : Available
    , class : Available
    , disabled : Available
    , form : Available
    , helpText : Available
    , id : Available
    , name : Available
    , onBlur : Available
    , onChange : Available
    , onFocus : Available
    , onInput : Available
    , onInvalid : Available
    , required : Available
    , size : Available
    , slot : Available
    , style : Available
    , title : Available
    , value : Available
    }
