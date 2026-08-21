module M3e.Internal.Types.TimepickerDial exposing (Is, Attrs, ChildAdmittedBy, Format, Period, ViewAttr, Builder, AttrCaps)

{-| Type definitions for TimepickerDial. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.TimepickerDial` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Format, Period, ViewAttr, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for TimepickerDial (generated).
-}
type alias Is s =
    { s | timepickerDial : Brand }


{-| The `Attrs` type row for TimepickerDial (generated).
-}
type alias Attrs =
    { class : Supported
    , format : Supported
    , hour : Supported
    , id : Supported
    , maxTime : Supported
    , minTime : Supported
    , minute : Supported
    , onChange : Supported
    , onInput : Supported
    , onViewChange : Supported
    , period : Supported
    , second : Supported
    , showSeconds : Supported
    , slot : Supported
    , style : Supported
    , viewAttr : Supported
    }


{-| The `ChildAdmittedBy` type row for TimepickerDial (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | timepickerDial : Ctx }


{-| The `Format` type row for TimepickerDial (generated).
-}
type alias Format =
    { value12 : Supported
    , value24 : Supported
    , auto : Supported
    }


{-| The `Period` type row for TimepickerDial (generated).
-}
type alias Period =
    { am : Supported
    , pm : Supported
    }


{-| The `ViewAttr` type row for TimepickerDial (generated).
-}
type alias ViewAttr =
    { hour : Supported
    , minute : Supported
    , second : Supported
    }


{-| The `Builder` type row for TimepickerDial (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for TimepickerDial (generated).
-}
type alias AttrCaps =
    { class : Available
    , format : Available
    , hour : Available
    , id : Available
    , maxTime : Available
    , minTime : Available
    , minute : Available
    , onChange : Available
    , onInput : Available
    , onViewChange : Available
    , period : Available
    , second : Available
    , showSeconds : Available
    , slot : Available
    , style : Available
    , viewAttr : Available
    }
