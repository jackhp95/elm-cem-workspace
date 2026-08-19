module M3e.Internal.Types.TimepickerInputPeriodToggle exposing (..)

{-| Internal type definitions for TimepickerInputPeriodToggle — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | timepickerInputPeriodToggle : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , onChange : Supported
    , orientation : Supported
    , period : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | timepickerInputPeriodToggle : Ctx }


type alias Period =
    { am : Supported
    , pm : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , onChange : Available
    , orientation : Available
    , period : Available
    , slot : Available
    , style : Available
    }
