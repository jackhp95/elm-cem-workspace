module M3e.Internal.Types.Datepicker exposing (..)

{-| Internal type definitions for Datepicker — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | datepicker : Brand }


type alias Attrs =
    { class : Supported
    , clearLabel : Supported
    , clearable : Supported
    , confirmLabel : Supported
    , date : Supported
    , dismissLabel : Supported
    , for : Supported
    , id : Supported
    , label : Supported
    , maxDate : Supported
    , minDate : Supported
    , nextMonthLabel : Supported
    , nextMultiYearLabel : Supported
    , nextYearLabel : Supported
    , onBeforetoggle : Supported
    , onChange : Supported
    , onToggle : Supported
    , previousMonthLabel : Supported
    , previousMultiYearLabel : Supported
    , previousYearLabel : Supported
    , range : Supported
    , rangeEnd : Supported
    , rangeStart : Supported
    , slot : Supported
    , startAt : Supported
    , startView : Supported
    , style : Supported
    , variant : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | datepicker : Ctx }


type alias StartView =
    { month : Supported
    , multiYear : Supported
    , year : Supported
    }


type alias Variant =
    { auto : Supported
    , docked : Supported
    , modal : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , clearLabel : Available
    , clearable : Available
    , confirmLabel : Available
    , date : Available
    , dismissLabel : Available
    , for : Available
    , id : Available
    , label : Available
    , maxDate : Available
    , minDate : Available
    , nextMonthLabel : Available
    , nextMultiYearLabel : Available
    , nextYearLabel : Available
    , onBeforetoggle : Available
    , onChange : Available
    , onToggle : Available
    , previousMonthLabel : Available
    , previousMultiYearLabel : Available
    , previousYearLabel : Available
    , range : Available
    , rangeEnd : Available
    , rangeStart : Available
    , slot : Available
    , startAt : Available
    , startView : Available
    , style : Available
    , variant : Available
    }
