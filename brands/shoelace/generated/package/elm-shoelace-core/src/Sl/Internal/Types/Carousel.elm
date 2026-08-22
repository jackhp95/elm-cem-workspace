module Sl.Internal.Types.Carousel exposing (Is, Attrs, ChildAdmittedBy, Orientation, Builder, AttrCaps)

{-| Type definitions for Carousel. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Carousel` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Orientation, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Carousel (generated).
-}
type alias Is s =
    { s | carousel : Brand }


{-| The `Attrs` type row for Carousel (generated).
-}
type alias Attrs =
    { autoplay : Supported
    , autoplayInterval : Supported
    , class : Supported
    , id : Supported
    , loop : Supported
    , mouseDragging : Supported
    , navigation : Supported
    , onSlideChange : Supported
    , orientation : Supported
    , pagination : Supported
    , slidesPerMove : Supported
    , slidesPerPage : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Carousel (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | carousel : Ctx }


{-| The `Orientation` type row for Carousel (generated).
-}
type alias Orientation =
    { horizontal : Supported
    , vertical : Supported
    }


{-| The `Builder` type row for Carousel (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Carousel (generated).
-}
type alias AttrCaps =
    { autoplay : Available
    , autoplayInterval : Available
    , class : Available
    , id : Available
    , loop : Available
    , mouseDragging : Available
    , navigation : Available
    , onSlideChange : Available
    , orientation : Available
    , pagination : Available
    , slidesPerMove : Available
    , slidesPerPage : Available
    , slot : Available
    , style : Available
    }
