module M3e.Internal.Types.MonthView exposing (..)

{-| Internal type definitions for MonthView — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | monthView : Brand }


type alias Attrs =
    { active : Supported
    , activeDate : Supported
    , class : Supported
    , date : Supported
    , id : Supported
    , maxDate : Supported
    , minDate : Supported
    , onActiveChange : Supported
    , onChange : Supported
    , rangeEnd : Supported
    , rangeStart : Supported
    , slot : Supported
    , style : Supported
    , today : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | monthView : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { active : Available
    , activeDate : Available
    , class : Available
    , date : Available
    , id : Available
    , maxDate : Available
    , minDate : Available
    , onActiveChange : Available
    , onChange : Available
    , rangeEnd : Available
    , rangeStart : Available
    , slot : Available
    , style : Available
    , today : Available
    }
