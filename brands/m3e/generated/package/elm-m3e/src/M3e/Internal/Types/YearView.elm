module M3e.Internal.Types.YearView exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for YearView. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.YearView` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for YearView (generated).
-}
type alias Is s =
    { s | yearView : Brand }


{-| The `Attrs` type row for YearView (generated).
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
    , slot : Supported
    , style : Supported
    , today : Supported
    }


{-| The `ChildAdmittedBy` type row for YearView (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | yearView : Ctx }


{-| The `Builder` type row for YearView (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for YearView (generated).
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
    , slot : Available
    , style : Available
    , today : Available
    }
