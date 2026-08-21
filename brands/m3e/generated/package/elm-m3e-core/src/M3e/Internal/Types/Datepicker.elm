module M3e.Internal.Types.Datepicker exposing (Is, Attrs, ChildAdmittedBy, StartView, Variant, Builder, AttrCaps)

{-| Type definitions for Datepicker. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Datepicker` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, StartView, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Datepicker (generated).
-}
type alias Is s =
    { s | datepicker : Brand }


{-| The `Attrs` type row for Datepicker (generated).
-}
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


{-| The `ChildAdmittedBy` type row for Datepicker (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | datepicker : Ctx }


{-| The `StartView` type row for Datepicker (generated).
-}
type alias StartView =
    { month : Supported
    , multiYear : Supported
    , year : Supported
    }


{-| The `Variant` type row for Datepicker (generated).
-}
type alias Variant =
    { auto : Supported
    , docked : Supported
    , modal : Supported
    }


{-| The `Builder` type row for Datepicker (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Datepicker (generated).
-}
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
