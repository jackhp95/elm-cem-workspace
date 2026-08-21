module M3e.Internal.Types.Elevation exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Elevation. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Elevation` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Elevation (generated).
-}
type alias Is s =
    { s | elevation : Brand }


{-| The `Attrs` type row for Elevation (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , for : Supported
    , id : Supported
    , level : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Elevation (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | elevation : Ctx }


{-| The `Builder` type row for Elevation (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Elevation (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , for : Available
    , id : Available
    , level : Available
    , slot : Available
    , style : Available
    }
