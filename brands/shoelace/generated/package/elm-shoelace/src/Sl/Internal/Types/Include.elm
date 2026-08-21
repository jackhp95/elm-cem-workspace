module Sl.Internal.Types.Include exposing (Is, Attrs, ChildAdmittedBy, Mode, Builder, AttrCaps)

{-| Type definitions for Include. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.Include` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Mode, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Include (generated).
-}
type alias Is s =
    { s | include : Brand }


{-| The `Attrs` type row for Include (generated).
-}
type alias Attrs =
    { allowScripts : Supported
    , class : Supported
    , id : Supported
    , mode : Supported
    , onError : Supported
    , onLoad : Supported
    , slot : Supported
    , src : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Include (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | include : Ctx }


{-| The `Mode` type row for Include (generated).
-}
type alias Mode =
    { cors : Supported
    , noCors : Supported
    , sameOrigin : Supported
    }


{-| The `Builder` type row for Include (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Include (generated).
-}
type alias AttrCaps =
    { allowScripts : Available
    , class : Available
    , id : Available
    , mode : Available
    , onError : Available
    , onLoad : Available
    , slot : Available
    , src : Available
    , style : Available
    }
