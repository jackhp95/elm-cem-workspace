module Sl.Internal.Types.RelativeTime exposing (Is, Attrs, ChildAdmittedBy, Format, Numeric, Builder, AttrCaps)

{-| Type definitions for RelativeTime. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.RelativeTime` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Format, Numeric, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for RelativeTime (generated).
-}
type alias Is s =
    { s | relativeTime : Brand }


{-| The `Attrs` type row for RelativeTime (generated).
-}
type alias Attrs =
    { class : Supported
    , date : Supported
    , format : Supported
    , id : Supported
    , numeric : Supported
    , slot : Supported
    , style : Supported
    , sync : Supported
    }


{-| The `ChildAdmittedBy` type row for RelativeTime (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | relativeTime : Ctx }


{-| The `Format` type row for RelativeTime (generated).
-}
type alias Format =
    { long : Supported
    , narrow : Supported
    , short : Supported
    }


{-| The `Numeric` type row for RelativeTime (generated).
-}
type alias Numeric =
    { always : Supported
    , auto : Supported
    }


{-| The `Builder` type row for RelativeTime (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for RelativeTime (generated).
-}
type alias AttrCaps =
    { class : Available
    , date : Available
    , format : Available
    , id : Available
    , numeric : Available
    , slot : Available
    , style : Available
    , sync : Available
    }
