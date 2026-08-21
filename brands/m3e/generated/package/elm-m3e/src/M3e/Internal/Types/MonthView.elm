module M3e.Internal.Types.MonthView exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for MonthView. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.MonthView` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for MonthView (generated).
-}
type alias Is s =
    { s | monthView : Brand }


{-| The `Attrs` type row for MonthView (generated).
-}
type alias Attrs =
    { active : Supported
    , activeDate : Supported
    , class : Supported
    , date : Supported
    , id : Supported
    , maxDate : Supported
    , minDate : Supported
    , onActiveChange : Supported
    , onChange : Supported
    , rangeEnd : Supported
    , rangeStart : Supported
    , slot : Supported
    , style : Supported
    , today : Supported
    }


{-| The `ChildAdmittedBy` type row for MonthView (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | monthView : Ctx }


{-| The `Builder` type row for MonthView (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for MonthView (generated).
-}
type alias AttrCaps =
    { active : Available
    , activeDate : Available
    , class : Available
    , date : Available
    , id : Available
    , maxDate : Available
    , minDate : Available
    , onActiveChange : Available
    , onChange : Available
    , rangeEnd : Available
    , rangeStart : Available
    , slot : Available
    , style : Available
    , today : Available
    }
