module M3e.Internal.Types.DatepickerToggle exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for DatepickerToggle. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.DatepickerToggle` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for DatepickerToggle (generated).
-}
type alias Is s =
    { s | datepickerToggle : Brand }


{-| The `Attrs` type row for DatepickerToggle (generated).
-}
type alias Attrs =
    { class : Supported
    , for : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for DatepickerToggle (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | datepickerToggle : Ctx }


{-| The `Builder` type row for DatepickerToggle (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for DatepickerToggle (generated).
-}
type alias AttrCaps =
    { class : Available
    , for : Available
    , id : Available
    , slot : Available
    , style : Available
    }
