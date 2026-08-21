module M3e.Internal.Types.TimepickerInputPeriodToggle exposing (Is, Attrs, ChildAdmittedBy, Period, Builder, AttrCaps)

{-| Type definitions for TimepickerInputPeriodToggle. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.TimepickerInputPeriodToggle` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Period, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for TimepickerInputPeriodToggle (generated).
-}
type alias Is s =
    { s | timepickerInputPeriodToggle : Brand }


{-| The `Attrs` type row for TimepickerInputPeriodToggle (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , onChange : Supported
    , orientation : Supported
    , period : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for TimepickerInputPeriodToggle (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | timepickerInputPeriodToggle : Ctx }


{-| The `Period` type row for TimepickerInputPeriodToggle (generated).
-}
type alias Period =
    { am : Supported
    , pm : Supported
    }


{-| The `Builder` type row for TimepickerInputPeriodToggle (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for TimepickerInputPeriodToggle (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , onChange : Available
    , orientation : Available
    , period : Available
    , slot : Available
    , style : Available
    }
