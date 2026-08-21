module Sl.Internal.Types.Option exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Option. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.Option` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Option (generated).
-}
type alias Is s =
    { s | option : Brand }


{-| The `Attrs` type row for Option (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


{-| The `ChildAdmittedBy` type row for Option (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | option : Ctx }


{-| The `Builder` type row for Option (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Option (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , slot : Available
    , style : Available
    , value : Available
    }
