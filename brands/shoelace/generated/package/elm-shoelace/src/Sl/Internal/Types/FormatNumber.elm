module Sl.Internal.Types.FormatNumber exposing (..)

{-| Internal type definitions for FormatNumber — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | formatNumber : Brand }


type alias Attrs =
    { class : Supported
    , currency : Supported
    , currencyDisplay : Supported
    , id : Supported
    , maximumFractionDigits : Supported
    , maximumSignificantDigits : Supported
    , minimumFractionDigits : Supported
    , minimumIntegerDigits : Supported
    , minimumSignificantDigits : Supported
    , noGrouping : Supported
    , slot : Supported
    , style : Supported
    , type_ : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | formatNumber : Ctx }


type alias CurrencyDisplay =
    { code : Supported
    , name : Supported
    , narrowsymbol : Supported
    , symbol : Supported
    }


type alias Type =
    { currency : Supported
    , decimal : Supported
    , percent : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , currency : Available
    , currencyDisplay : Available
    , id : Available
    , maximumFractionDigits : Available
    , maximumSignificantDigits : Available
    , minimumFractionDigits : Available
    , minimumIntegerDigits : Available
    , minimumSignificantDigits : Available
    , noGrouping : Available
    , slot : Available
    , style : Available
    , type_ : Available
    , value : Available
    }
