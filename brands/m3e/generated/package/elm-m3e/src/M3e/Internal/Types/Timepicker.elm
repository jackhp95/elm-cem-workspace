module M3e.Internal.Types.Timepicker exposing (Is, Attrs, ChildAdmittedBy, Format, Mode, Orientation, Variant, Builder, AttrCaps)

{-| Type definitions for Timepicker. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Timepicker` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Format, Mode, Orientation, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Timepicker (generated).
-}
type alias Is s =
    { s | timepicker : Brand }


{-| The `Attrs` type row for Timepicker (generated).
-}
type alias Attrs =
    { class : Supported
    , confirmLabel : Supported
    , date : Supported
    , dialLabel : Supported
    , dismissLabel : Supported
    , for : Supported
    , format : Supported
    , hideModeToggle : Supported
    , hourLabel : Supported
    , id : Supported
    , inputLabel : Supported
    , maxTime : Supported
    , minTime : Supported
    , minuteLabel : Supported
    , mode : Supported
    , modeToggleLabel : Supported
    , onBeforetoggle : Supported
    , onChange : Supported
    , onToggle : Supported
    , orientation : Supported
    , periodToggleLabel : Supported
    , secondLabel : Supported
    , showSeconds : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


{-| The `ChildAdmittedBy` type row for Timepicker (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | timepicker : Ctx }


{-| The `Format` type row for Timepicker (generated).
-}
type alias Format =
    { value12 : Supported
    , value24 : Supported
    , auto : Supported
    }


{-| The `Mode` type row for Timepicker (generated).
-}
type alias Mode =
    { dial : Supported
    , input : Supported
    }


{-| The `Orientation` type row for Timepicker (generated).
-}
type alias Orientation =
    { auto : Supported
    , horizontal : Supported
    , vertical : Supported
    }


{-| The `Variant` type row for Timepicker (generated).
-}
type alias Variant =
    { auto : Supported
    , docked : Supported
    , modal : Supported
    }


{-| The `Builder` type row for Timepicker (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Timepicker (generated).
-}
type alias AttrCaps =
    { class : Available
    , confirmLabel : Available
    , date : Available
    , dialLabel : Available
    , dismissLabel : Available
    , for : Available
    , format : Available
    , hideModeToggle : Available
    , hourLabel : Available
    , id : Available
    , inputLabel : Available
    , maxTime : Available
    , minTime : Available
    , minuteLabel : Available
    , mode : Available
    , modeToggleLabel : Available
    , onBeforetoggle : Available
    , onChange : Available
    , onToggle : Available
    , orientation : Available
    , periodToggleLabel : Available
    , secondLabel : Available
    , showSeconds : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
