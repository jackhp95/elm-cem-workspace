module Sl.Internal.Types.RadioGroup exposing (..)

{-| Internal type definitions for RadioGroup — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | radioGroup : Brand }


type alias Attrs =
    { class : Supported
    , form : Supported
    , helpText : Supported
    , id : Supported
    , label : Supported
    , name : Supported
    , onChange : Supported
    , onInput : Supported
    , onInvalid : Supported
    , required : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | radioGroup : Ctx }


type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , form : Available
    , helpText : Available
    , id : Available
    , label : Available
    , name : Available
    , onChange : Available
    , onInput : Available
    , onInvalid : Available
    , required : Available
    , size : Available
    , slot : Available
    , style : Available
    , value : Available
    }
