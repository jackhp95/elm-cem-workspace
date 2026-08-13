module M3e.Internal.Types.TimepickerToggle exposing (..)

{-| Internal type definitions for TimepickerToggle — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | timepickerToggle : Brand }


type alias Attrs =
    { class : Supported
    , for : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | timepickerToggle : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , for : Available
    , id : Available
    , slot : Available
    , style : Available
    }
