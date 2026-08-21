module Sl.Internal.Types.TabPanel exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for TabPanel. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.TabPanel` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for TabPanel (generated).
-}
type alias Is s =
    { s | tabPanel : Brand }


{-| The `Attrs` type row for TabPanel (generated).
-}
type alias Attrs =
    { active : Supported
    , class : Supported
    , id : Supported
    , name : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for TabPanel (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | tabPanel : Ctx }


{-| The `Builder` type row for TabPanel (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for TabPanel (generated).
-}
type alias AttrCaps =
    { active : Available
    , class : Available
    , id : Available
    , name : Available
    , slot : Available
    , style : Available
    }
