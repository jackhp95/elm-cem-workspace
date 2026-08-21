module M3e.Internal.Types.TimepickerInput exposing (Is, Attrs, ChildAdmittedBy, Format, Period, ViewAttr, Builder, AttrCaps)

{-| Type definitions for TimepickerInput. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.TimepickerInput` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Format, Period, ViewAttr, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for TimepickerInput (generated).
-}
type alias Is s =
    { s | timepickerInput : Brand }


{-| The `Attrs` type row for TimepickerInput (generated).
-}
type alias Attrs =
    { class : Supported
    , for : Supported
    , format : Supported
    , hideLabels : Supported
    , hour : Supported
    , hourLabel : Supported
    , id : Supported
    , maxTime : Supported
    , minTime : Supported
    , minute : Supported
    , minuteLabel : Supported
    , onChange : Supported
    , onViewChange : Supported
    , orientation : Supported
    , period : Supported
    , periodToggleLabel : Supported
    , second : Supported
    , secondLabel : Supported
    , showSeconds : Supported
    , slot : Supported
    , style : Supported
    , viewAttr : Supported
    }


{-| The `ChildAdmittedBy` type row for TimepickerInput (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | timepickerInput : Ctx }


{-| The `Format` type row for TimepickerInput (generated).
-}
type alias Format =
    { value12 : Supported
    , value24 : Supported
    , auto : Supported
    }


{-| The `Period` type row for TimepickerInput (generated).
-}
type alias Period =
    { am : Supported
    , pm : Supported
    }


{-| The `ViewAttr` type row for TimepickerInput (generated).
-}
type alias ViewAttr =
    { hour : Supported
    , minute : Supported
    , second : Supported
    }


{-| The `Builder` type row for TimepickerInput (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for TimepickerInput (generated).
-}
type alias AttrCaps =
    { class : Available
    , for : Available
    , format : Available
    , hideLabels : Available
    , hour : Available
    , hourLabel : Available
    , id : Available
    , maxTime : Available
    , minTime : Available
    , minute : Available
    , minuteLabel : Available
    , onChange : Available
    , onViewChange : Available
    , orientation : Available
    , period : Available
    , periodToggleLabel : Available
    , second : Available
    , secondLabel : Available
    , showSeconds : Available
    , slot : Available
    , style : Available
    , viewAttr : Available
    }
