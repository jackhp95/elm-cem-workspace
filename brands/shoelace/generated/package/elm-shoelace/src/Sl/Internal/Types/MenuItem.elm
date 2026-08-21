module Sl.Internal.Types.MenuItem exposing (Is, Attrs, ChildAdmittedBy, Type, Builder, AttrCaps)

{-| Type definitions for MenuItem. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.MenuItem` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Type, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for MenuItem (generated).
-}
type alias Is s =
    { s | menuItem : Brand }


{-| The `Attrs` type row for MenuItem (generated).
-}
type alias Attrs =
    { checked : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , loading : Supported
    , slot : Supported
    , style : Supported
    , type_ : Supported
    , value : Supported
    }


{-| The `ChildAdmittedBy` type row for MenuItem (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | menuItem : Ctx }


{-| The `Type` type row for MenuItem (generated).
-}
type alias Type =
    { checkbox : Supported
    , normal : Supported
    }


{-| The `Builder` type row for MenuItem (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for MenuItem (generated).
-}
type alias AttrCaps =
    { checked : Available
    , class : Available
    , disabled : Available
    , id : Available
    , loading : Available
    , slot : Available
    , style : Available
    , type_ : Available
    , value : Available
    }
