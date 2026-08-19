module M3e.Internal.Types.DateInput exposing (..)

{-| Internal type definitions for DateInput — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | dateInput : Brand }


type alias Attrs =
    { class : Supported
    , dayLabel : Supported
    , disabled : Supported
    , hourLabel : Supported
    , id : Supported
    , maxDate : Supported
    , maxTime : Supported
    , minDate : Supported
    , minTime : Supported
    , minuteLabel : Supported
    , monthLabel : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onInput : Supported
    , onInvalid : Supported
    , periodLabel : Supported
    , readonly : Supported
    , required : Supported
    , secondLabel : Supported
    , showSeconds : Supported
    , slot : Supported
    , style : Supported
    , timeFormat : Supported
    , type_ : Supported
    , validationmessages : Supported
    , value : Supported
    , yearLabel : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | dateInput : Ctx }


type alias TimeFormat =
    { value12 : Supported
    , value24 : Supported
    , auto : Supported
    }


type alias Type =
    { date : Supported
    , datetime : Supported
    , time : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , dayLabel : Available
    , disabled : Available
    , hourLabel : Available
    , id : Available
    , maxDate : Available
    , maxTime : Available
    , minDate : Available
    , minTime : Available
    , minuteLabel : Available
    , monthLabel : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onInput : Available
    , onInvalid : Available
    , periodLabel : Available
    , readonly : Available
    , required : Available
    , secondLabel : Available
    , showSeconds : Available
    , slot : Available
    , style : Available
    , timeFormat : Available
    , type_ : Available
    , validationmessages : Available
    , value : Available
    , yearLabel : Available
    }
