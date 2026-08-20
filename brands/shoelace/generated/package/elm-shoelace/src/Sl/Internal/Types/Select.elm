module Sl.Internal.Types.Select exposing (..)

{-| Internal type definitions for Select — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | select : Brand }


type alias Attrs =
    { class : Supported
    , clearable : Supported
    , disabled : Supported
    , filled : Supported
    , form : Supported
    , gettag : Supported
    , helpText : Supported
    , hoist : Supported
    , id : Supported
    , label : Supported
    , maxOptionsVisible : Supported
    , multiple : Supported
    , name : Supported
    , onAfterHide : Supported
    , onAfterShow : Supported
    , onBlur : Supported
    , onChange : Supported
    , onClear : Supported
    , onFocus : Supported
    , onHide : Supported
    , onInput : Supported
    , onInvalid : Supported
    , onShow : Supported
    , open : Supported
    , pill : Supported
    , placeholder : Supported
    , placement : Supported
    , required : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | select : Ctx }


type alias Placement =
    { bottom : Supported
    , top : Supported
    }


type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , clearable : Available
    , disabled : Available
    , filled : Available
    , form : Available
    , gettag : Available
    , helpText : Available
    , hoist : Available
    , id : Available
    , label : Available
    , maxOptionsVisible : Available
    , multiple : Available
    , name : Available
    , onAfterHide : Available
    , onAfterShow : Available
    , onBlur : Available
    , onChange : Available
    , onClear : Available
    , onFocus : Available
    , onHide : Available
    , onInput : Available
    , onInvalid : Available
    , onShow : Available
    , open : Available
    , pill : Available
    , placeholder : Available
    , placement : Available
    , required : Available
    , size : Available
    , slot : Available
    , style : Available
    , value : Available
    }
