module Sl.Internal.Types.Avatar exposing (Is, Attrs, ChildAdmittedBy, Loading, Shape, Builder, AttrCaps)

{-| Type definitions for Avatar. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Avatar` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Loading, Shape, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Avatar (generated).
-}
type alias Is s =
    { s | avatar : Brand }


{-| The `Attrs` type row for Avatar (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , image : Supported
    , initials : Supported
    , label : Supported
    , loading : Supported
    , onError : Supported
    , shape : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Avatar (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | avatar : Ctx }


{-| The `Loading` type row for Avatar (generated).
-}
type alias Loading =
    { eager : Supported
    , lazy : Supported
    }


{-| The `Shape` type row for Avatar (generated).
-}
type alias Shape =
    { circle : Supported
    , rounded : Supported
    , square : Supported
    }


{-| The `Builder` type row for Avatar (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Avatar (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , image : Available
    , initials : Available
    , label : Available
    , loading : Available
    , onError : Available
    , shape : Available
    , slot : Available
    , style : Available
    }
