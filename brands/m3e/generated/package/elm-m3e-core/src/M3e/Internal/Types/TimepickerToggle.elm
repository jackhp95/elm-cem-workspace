module M3e.Internal.Types.TimepickerToggle exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for TimepickerToggle. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.TimepickerToggle` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for TimepickerToggle (generated).
-}
type alias Is s =
    { s | timepickerToggle : Brand }


{-| The `Attrs` type row for TimepickerToggle (generated).
-}
type alias Attrs =
    { class : Supported
    , for : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for TimepickerToggle (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | timepickerToggle : Ctx }


{-| The `Builder` type row for TimepickerToggle (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for TimepickerToggle (generated).
-}
type alias AttrCaps =
    { class : Available
    , for : Available
    , id : Available
    , slot : Available
    , style : Available
    }
