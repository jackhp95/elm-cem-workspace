module Sl.Internal.Types.ResizeObserver exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for ResizeObserver. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.ResizeObserver` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ResizeObserver (generated).
-}
type alias Is s =
    { s | resizeObserver : Brand }


{-| The `Attrs` type row for ResizeObserver (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , onResize : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for ResizeObserver (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | resizeObserver : Ctx }


{-| The `Builder` type row for ResizeObserver (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ResizeObserver (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , onResize : Available
    , slot : Available
    , style : Available
    }
