module Sl.Internal.Types.SplitPanel exposing (Is, Attrs, ChildAdmittedBy, Primary, Builder, AttrCaps)

{-| Type definitions for SplitPanel. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.SplitPanel` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Primary, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for SplitPanel (generated).
-}
type alias Is s =
    { s | splitPanel : Brand }


{-| The `Attrs` type row for SplitPanel (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , onReposition : Supported
    , position : Supported
    , positionInPixels : Supported
    , primary : Supported
    , slot : Supported
    , snap : Supported
    , snapThreshold : Supported
    , style : Supported
    , vertical : Supported
    }


{-| The `ChildAdmittedBy` type row for SplitPanel (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | splitPanel : Ctx }


{-| The `Primary` type row for SplitPanel (generated).
-}
type alias Primary =
    { end : Supported
    , start : Supported
    }


{-| The `Builder` type row for SplitPanel (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for SplitPanel (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , onReposition : Available
    , position : Available
    , positionInPixels : Available
    , primary : Available
    , slot : Available
    , snap : Available
    , snapThreshold : Available
    , style : Available
    , vertical : Available
    }
