module Sl.Internal.Types.FormatBytes exposing (Is, Attrs, ChildAdmittedBy, Display, Unit, Builder, AttrCaps)

{-| Type definitions for FormatBytes. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.FormatBytes` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Display, Unit, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for FormatBytes (generated).
-}
type alias Is s =
    { s | formatBytes : Brand }


{-| The `Attrs` type row for FormatBytes (generated).
-}
type alias Attrs =
    { class : Supported
    , display : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , unit : Supported
    , value : Supported
    }


{-| The `ChildAdmittedBy` type row for FormatBytes (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | formatBytes : Ctx }


{-| The `Display` type row for FormatBytes (generated).
-}
type alias Display =
    { long : Supported
    , narrow : Supported
    , short : Supported
    }


{-| The `Unit` type row for FormatBytes (generated).
-}
type alias Unit =
    { bit : Supported
    , byte : Supported
    }


{-| The `Builder` type row for FormatBytes (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for FormatBytes (generated).
-}
type alias AttrCaps =
    { class : Available
    , display : Available
    , id : Available
    , slot : Available
    , style : Available
    , unit : Available
    , value : Available
    }
