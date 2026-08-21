module Sl.Internal.Types.Skeleton exposing (Is, Attrs, ChildAdmittedBy, Effect, Builder, AttrCaps)

{-| Type definitions for Skeleton. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.Skeleton` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Effect, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Skeleton (generated).
-}
type alias Is s =
    { s | skeleton : Brand }


{-| The `Attrs` type row for Skeleton (generated).
-}
type alias Attrs =
    { class : Supported
    , effect_ : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Skeleton (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | skeleton : Ctx }


{-| The `Effect` type row for Skeleton (generated).
-}
type alias Effect =
    { none : Supported
    , pulse : Supported
    , sheen : Supported
    }


{-| The `Builder` type row for Skeleton (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Skeleton (generated).
-}
type alias AttrCaps =
    { class : Available
    , effect_ : Available
    , id : Available
    , slot : Available
    , style : Available
    }
