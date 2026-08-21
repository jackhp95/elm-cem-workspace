module Sl.Internal.Types.FormatDate exposing (Is, Attrs, ChildAdmittedBy, Day, Era, Hour, HourFormat, Minute, Month, Second, TimeZoneName, Weekday, Year, Builder, AttrCaps)

{-| Type definitions for FormatDate. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.FormatDate` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Day, Era, Hour, HourFormat, Minute, Month, Second, TimeZoneName, Weekday, Year, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for FormatDate (generated).
-}
type alias Is s =
    { s | formatDate : Brand }


{-| The `Attrs` type row for FormatDate (generated).
-}
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


{-| The `ChildAdmittedBy` type row for FormatDate (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | formatDate : Ctx }


{-| The `Day` type row for FormatDate (generated).
-}
type alias Day =
    { value2Digit : Supported
    , numeric : Supported
    }


{-| The `Era` type row for FormatDate (generated).
-}
type alias Era =
    { long : Supported
    , narrow : Supported
    , short : Supported
    }


{-| The `Hour` type row for FormatDate (generated).
-}
type alias Hour =
    { value2Digit : Supported
    , numeric : Supported
    }


{-| The `HourFormat` type row for FormatDate (generated).
-}
type alias HourFormat =
    { value12 : Supported
    , value24 : Supported
    , auto : Supported
    }


{-| The `Minute` type row for FormatDate (generated).
-}
type alias Minute =
    { value2Digit : Supported
    , numeric : Supported
    }


{-| The `Month` type row for FormatDate (generated).
-}
type alias Month =
    { value2Digit : Supported
    , long : Supported
    , narrow : Supported
    , numeric : Supported
    , short : Supported
    }


{-| The `Second` type row for FormatDate (generated).
-}
type alias Second =
    { value2Digit : Supported
    , numeric : Supported
    }


{-| The `TimeZoneName` type row for FormatDate (generated).
-}
type alias TimeZoneName =
    { long : Supported
    , short : Supported
    }


{-| The `Weekday` type row for FormatDate (generated).
-}
type alias Weekday =
    { long : Supported
    , narrow : Supported
    , short : Supported
    }


{-| The `Year` type row for FormatDate (generated).
-}
type alias Year =
    { value2Digit : Supported
    , numeric : Supported
    }


{-| The `Builder` type row for FormatDate (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for FormatDate (generated).
-}
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
