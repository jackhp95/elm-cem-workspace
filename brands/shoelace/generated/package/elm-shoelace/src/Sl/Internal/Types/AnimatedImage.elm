module Sl.Internal.Types.AnimatedImage exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for AnimatedImage. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.AnimatedImage` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for AnimatedImage (generated).
-}
type alias Is s =
    { s | animatedImage : Brand }


{-| The `Attrs` type row for AnimatedImage (generated).
-}
type alias Attrs =
    { alt : Supported
    , class : Supported
    , id : Supported
    , onError : Supported
    , onLoad : Supported
    , play : Supported
    , slot : Supported
    , src : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for AnimatedImage (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | animatedImage : Ctx }


{-| The `Builder` type row for AnimatedImage (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for AnimatedImage (generated).
-}
type alias AttrCaps =
    { alt : Available
    , class : Available
    , id : Available
    , onError : Available
    , onLoad : Available
    , play : Available
    , slot : Available
    , src : Available
    , style : Available
    }
