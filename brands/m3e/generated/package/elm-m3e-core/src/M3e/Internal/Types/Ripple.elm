module M3e.Internal.Types.Ripple exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Ripple. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Ripple` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Ripple (generated).
-}
type alias Is s =
    { s | ripple : Brand }


{-| The `Attrs` type row for Ripple (generated).
-}
type alias Attrs =
    { centered : Supported
    , class : Supported
    , disabled : Supported
    , for : Supported
    , id : Supported
    , radius : Supported
    , slot : Supported
    , style : Supported
    , unbounded : Supported
    }


{-| The `ChildAdmittedBy` type row for Ripple (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | ripple : Ctx }


{-| The `Builder` type row for Ripple (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Ripple (generated).
-}
type alias AttrCaps =
    { centered : Available
    , class : Available
    , disabled : Available
    , for : Available
    , id : Available
    , radius : Available
    , slot : Available
    , style : Available
    , unbounded : Available
    }
