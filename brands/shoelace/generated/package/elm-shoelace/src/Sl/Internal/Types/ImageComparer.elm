module Sl.Internal.Types.ImageComparer exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for ImageComparer. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.ImageComparer` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ImageComparer (generated).
-}
type alias Is s =
    { s | imageComparer : Brand }


{-| The `Attrs` type row for ImageComparer (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , onChange : Supported
    , position : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for ImageComparer (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | imageComparer : Ctx }


{-| The `Builder` type row for ImageComparer (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ImageComparer (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , onChange : Available
    , position : Available
    , slot : Available
    , style : Available
    }
