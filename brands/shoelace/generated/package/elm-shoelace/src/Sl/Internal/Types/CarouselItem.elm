module Sl.Internal.Types.CarouselItem exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for CarouselItem. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.CarouselItem` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for CarouselItem (generated).
-}
type alias Is s =
    { s | carouselItem : Brand }


{-| The `Attrs` type row for CarouselItem (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for CarouselItem (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | carouselItem : Ctx }


{-| The `Builder` type row for CarouselItem (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for CarouselItem (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    }
