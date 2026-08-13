module M3e.Internal.Types.TimepickerDial exposing (..)

{-| Internal type definitions for TimepickerDial — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B



type alias Is s =
    { s | timepickerDial : Brand }


type alias Attrs =
    { class : Supported
    , format : Supported
    , hour : Supported
    , id : Supported
    , maxTime : Supported
    , minTime : Supported
    , minute : Supported
    , onChange : Supported
    , onInput : Supported
    , onViewChange : Supported
    , period : Supported
    , second : Supported
    , showSeconds : Supported
    , slot : Supported
    , style : Supported
    , viewAttr : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | timepickerDial : Ctx }


type alias Format =
    { value12 : Supported
    , value24 : Supported
    , auto : Supported
    }


type alias Period =
    { am : Supported
    , pm : Supported
    }


type alias ViewAttr =
    { hour : Supported
    , minute : Supported
    , second : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , format : Available
    , hour : Available
    , id : Available
    , maxTime : Available
    , minTime : Available
    , minute : Available
    , onChange : Available
    , onInput : Available
    , onViewChange : Available
    , period : Available
    , second : Available
    , showSeconds : Available
    , slot : Available
    , style : Available
    , viewAttr : Available
    }
