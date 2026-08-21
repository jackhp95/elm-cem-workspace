module M3e.Internal.Types.DateInput exposing (Is, Attrs, ChildAdmittedBy, TimeFormat, Type, Builder, AttrCaps)

{-| Type definitions for DateInput. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.DateInput` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, TimeFormat, Type, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for DateInput (generated).
-}
type alias Is s =
    { s | dateInput : Brand }


{-| The `Attrs` type row for DateInput (generated).
-}
type alias Attrs =
    { class : Supported
    , dayLabel : Supported
    , disabled : Supported
    , hourLabel : Supported
    , id : Supported
    , maxDate : Supported
    , maxTime : Supported
    , minDate : Supported
    , minTime : Supported
    , minuteLabel : Supported
    , monthLabel : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onInput : Supported
    , onInvalid : Supported
    , periodLabel : Supported
    , readonly : Supported
    , required : Supported
    , secondLabel : Supported
    , showSeconds : Supported
    , slot : Supported
    , style : Supported
    , timeFormat : Supported
    , type_ : Supported
    , validationmessages : Supported
    , value : Supported
    , yearLabel : Supported
    }


{-| The `ChildAdmittedBy` type row for DateInput (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | dateInput : Ctx }


{-| The `TimeFormat` type row for DateInput (generated).
-}
type alias TimeFormat =
    { value12 : Supported
    , value24 : Supported
    , auto : Supported
    }


{-| The `Type` type row for DateInput (generated).
-}
type alias Type =
    { date : Supported
    , datetime : Supported
    , time : Supported
    }


{-| The `Builder` type row for DateInput (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for DateInput (generated).
-}
type alias AttrCaps =
    { class : Available
    , dayLabel : Available
    , disabled : Available
    , hourLabel : Available
    , id : Available
    , maxDate : Available
    , maxTime : Available
    , minDate : Available
    , minTime : Available
    , minuteLabel : Available
    , monthLabel : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onInput : Available
    , onInvalid : Available
    , periodLabel : Available
    , readonly : Available
    , required : Available
    , secondLabel : Available
    , showSeconds : Available
    , slot : Available
    , style : Available
    , timeFormat : Available
    , type_ : Available
    , validationmessages : Available
    , value : Available
    , yearLabel : Available
    }
