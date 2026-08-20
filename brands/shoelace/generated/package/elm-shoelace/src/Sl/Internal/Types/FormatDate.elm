module Sl.Internal.Types.FormatDate exposing (..)

{-| Internal type definitions for FormatDate — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | formatDate : Brand }


type alias Attrs =
    { class : Supported
    , date : Supported
    , day : Supported
    , era : Supported
    , hour : Supported
    , hourFormat : Supported
    , id : Supported
    , minute : Supported
    , month : Supported
    , second : Supported
    , slot : Supported
    , style : Supported
    , timeZone : Supported
    , timeZoneName : Supported
    , weekday : Supported
    , year : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | formatDate : Ctx }


type alias Day =
    { value2Digit : Supported
    , numeric : Supported
    }


type alias Era =
    { long : Supported
    , narrow : Supported
    , short : Supported
    }


type alias Hour =
    { value2Digit : Supported
    , numeric : Supported
    }


type alias HourFormat =
    { value12 : Supported
    , value24 : Supported
    , auto : Supported
    }


type alias Minute =
    { value2Digit : Supported
    , numeric : Supported
    }


type alias Month =
    { value2Digit : Supported
    , long : Supported
    , narrow : Supported
    , numeric : Supported
    , short : Supported
    }


type alias Second =
    { value2Digit : Supported
    , numeric : Supported
    }


type alias TimeZoneName =
    { long : Supported
    , short : Supported
    }


type alias Weekday =
    { long : Supported
    , narrow : Supported
    , short : Supported
    }


type alias Year =
    { value2Digit : Supported
    , numeric : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , date : Available
    , day : Available
    , era : Available
    , hour : Available
    , hourFormat : Available
    , id : Available
    , minute : Available
    , month : Available
    , second : Available
    , slot : Available
    , style : Available
    , timeZone : Available
    , timeZoneName : Available
    , weekday : Available
    , year : Available
    }
