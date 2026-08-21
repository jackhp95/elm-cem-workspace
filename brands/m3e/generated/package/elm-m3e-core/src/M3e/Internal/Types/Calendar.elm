module M3e.Internal.Types.Calendar exposing (Is, Attrs, ChildAdmittedBy, StartView, Builder, AttrCaps, SlotCaps)

{-| Type definitions for Calendar. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Calendar` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, StartView, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Calendar (generated).
-}
type alias Is s =
    { s | calendar : Brand }


{-| The `Attrs` type row for Calendar (generated).
-}
type alias Attrs =
    { class : Supported
    , date : Supported
    , id : Supported
    , maxDate : Supported
    , minDate : Supported
    , nextMonthLabel : Supported
    , nextMultiYearLabel : Supported
    , nextYearLabel : Supported
    , onChange : Supported
    , previousMonthLabel : Supported
    , previousMultiYearLabel : Supported
    , previousYearLabel : Supported
    , rangeEnd : Supported
    , rangeStart : Supported
    , slot : Supported
    , startAt : Supported
    , startView : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Calendar (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | calendar : Ctx }


{-| The `StartView` type row for Calendar (generated).
-}
type alias StartView =
    { month : Supported
    , multiYear : Supported
    , year : Supported
    }


{-| The `Builder` type row for Calendar (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Calendar (generated).
-}
type alias AttrCaps =
    { class : Available
    , date : Available
    , id : Available
    , maxDate : Available
    , minDate : Available
    , nextMonthLabel : Available
    , nextMultiYearLabel : Available
    , nextYearLabel : Available
    , onChange : Available
    , previousMonthLabel : Available
    , previousMultiYearLabel : Available
    , previousYearLabel : Available
    , rangeEnd : Available
    , rangeStart : Available
    , slot : Available
    , startAt : Available
    , startView : Available
    , style : Available
    }


{-| The `SlotCaps` type row for Calendar (generated).
-}
type alias SlotCaps =
    { header : Available
    }
