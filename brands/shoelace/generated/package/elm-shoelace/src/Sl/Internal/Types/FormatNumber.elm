module Sl.Internal.Types.FormatNumber exposing (Is, Attrs, ChildAdmittedBy, CurrencyDisplay, Type, Builder, AttrCaps)

{-| Type definitions for FormatNumber. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.FormatNumber` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, CurrencyDisplay, Type, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for FormatNumber (generated).
-}
type alias Is s =
    { s | formatNumber : Brand }


{-| The `Attrs` type row for FormatNumber (generated).
-}
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


{-| The `ChildAdmittedBy` type row for FormatNumber (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | formatNumber : Ctx }


{-| The `CurrencyDisplay` type row for FormatNumber (generated).
-}
type alias CurrencyDisplay =
    { code : Supported
    , name : Supported
    , narrowsymbol : Supported
    , symbol : Supported
    }


{-| The `Type` type row for FormatNumber (generated).
-}
type alias Type =
    { currency : Supported
    , decimal : Supported
    , percent : Supported
    }


{-| The `Builder` type row for FormatNumber (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for FormatNumber (generated).
-}
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
