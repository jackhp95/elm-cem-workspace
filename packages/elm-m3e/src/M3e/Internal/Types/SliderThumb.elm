module M3e.Internal.Types.SliderThumb exposing (..)

{-| Internal type definitions for SliderThumb — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | sliderThumb : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , onValueChange : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | sliderThumb : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , onValueChange : Available
    , slot : Available
    , style : Available
    , value : Available
    }
