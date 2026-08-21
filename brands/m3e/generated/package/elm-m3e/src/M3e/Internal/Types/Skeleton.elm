module M3e.Internal.Types.Skeleton exposing (Is, Attrs, ChildAdmittedBy, Animation, Shape, Builder, AttrCaps)

{-| Type definitions for Skeleton. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Skeleton` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Animation, Shape, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Skeleton (generated).
-}
type alias Is s =
    { s | skeleton : Brand }


{-| The `Attrs` type row for Skeleton (generated).
-}
type alias Attrs =
    { animation : Supported
    , class : Supported
    , id : Supported
    , loaded : Supported
    , shape : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Skeleton (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | skeleton : Ctx }


{-| The `Animation` type row for Skeleton (generated).
-}
type alias Animation =
    { none : Supported
    , pulse : Supported
    , wave : Supported
    }


{-| The `Shape` type row for Skeleton (generated).
-}
type alias Shape =
    { auto : Supported
    , circular : Supported
    , rounded : Supported
    , square : Supported
    }


{-| The `Builder` type row for Skeleton (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Skeleton (generated).
-}
type alias AttrCaps =
    { animation : Available
    , class : Available
    , id : Available
    , loaded : Available
    , shape : Available
    , slot : Available
    , style : Available
    }
