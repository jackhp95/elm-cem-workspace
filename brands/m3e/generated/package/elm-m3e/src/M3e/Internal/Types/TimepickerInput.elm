module M3e.Internal.Types.TimepickerInput exposing (..)

{-| Internal type definitions for TimepickerInput — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | timepickerInput : Brand }


type alias Attrs =
    { class : Supported
    , for : Supported
    , format : Supported
    , hideLabels : Supported
    , hour : Supported
    , hourLabel : Supported
    , id : Supported
    , maxTime : Supported
    , minTime : Supported
    , minute : Supported
    , minuteLabel : Supported
    , onChange : Supported
    , onViewChange : Supported
    , orientation : Supported
    , period : Supported
    , periodToggleLabel : Supported
    , second : Supported
    , secondLabel : Supported
    , showSeconds : Supported
    , slot : Supported
    , style : Supported
    , viewAttr : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | timepickerInput : Ctx }


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
    , for : Available
    , format : Available
    , hideLabels : Available
    , hour : Available
    , hourLabel : Available
    , id : Available
    , maxTime : Available
    , minTime : Available
    , minute : Available
    , minuteLabel : Available
    , onChange : Available
    , onViewChange : Available
    , orientation : Available
    , period : Available
    , periodToggleLabel : Available
    , second : Available
    , secondLabel : Available
    , showSeconds : Available
    , slot : Available
    , style : Available
    , viewAttr : Available
    }
