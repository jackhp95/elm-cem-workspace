module M3e.Internal.Types.Calendar exposing (..)

{-| Internal type definitions for Calendar — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | calendar : Brand }


type alias Attrs =
    { class : Supported
    , date : Supported
    , id : Supported
    , maxDate : Supported
    , minDate : Supported
    , nextMonthLabel : Supported
    , nextMultiYearLabel : Supported
    , nextYearLabel : Supported
    , onChange : Supported
    , previousMonthLabel : Supported
    , previousMultiYearLabel : Supported
    , previousYearLabel : Supported
    , rangeEnd : Supported
    , rangeStart : Supported
    , slot : Supported
    , startAt : Supported
    , startView : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | calendar : Ctx }


type alias StartView =
    { month : Supported
    , multiYear : Supported
    , year : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , date : Available
    , id : Available
    , maxDate : Available
    , minDate : Available
    , nextMonthLabel : Available
    , nextMultiYearLabel : Available
    , nextYearLabel : Available
    , onChange : Available
    , previousMonthLabel : Available
    , previousMultiYearLabel : Available
    , previousYearLabel : Available
    , rangeEnd : Available
    , rangeStart : Available
    , slot : Available
    , startAt : Available
    , startView : Available
    , style : Available
    }


type alias SlotCaps =
    { header : Available
    }
