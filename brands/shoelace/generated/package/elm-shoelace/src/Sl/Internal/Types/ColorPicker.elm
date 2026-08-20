module Sl.Internal.Types.ColorPicker exposing (..)

{-| Internal type definitions for ColorPicker — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | colorPicker : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , form : Supported
    , format : Supported
    , hoist : Supported
    , id : Supported
    , inline : Supported
    , label : Supported
    , name : Supported
    , noFormatToggle : Supported
    , onBlur : Supported
    , onChange : Supported
    , onFocus : Supported
    , onInput : Supported
    , onInvalid : Supported
    , opacity : Supported
    , required : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , swatches : Supported
    , uppercase : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | colorPicker : Ctx }


type alias Format =
    { hex : Supported
    , hsl : Supported
    , hsv : Supported
    , rgb : Supported
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
    , disabled : Available
    , form : Available
    , format : Available
    , hoist : Available
    , id : Available
    , inline : Available
    , label : Available
    , name : Available
    , noFormatToggle : Available
    , onBlur : Available
    , onChange : Available
    , onFocus : Available
    , onInput : Available
    , onInvalid : Available
    , opacity : Available
    , required : Available
    , size : Available
    , slot : Available
    , style : Available
    , swatches : Available
    , uppercase : Available
    , value : Available
    }
