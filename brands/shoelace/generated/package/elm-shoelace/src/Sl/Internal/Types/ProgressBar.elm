module Sl.Internal.Types.ProgressBar exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for ProgressBar. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.ProgressBar` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ProgressBar (generated).
-}
type alias Is s =
    { s | progressBar : Brand }


{-| The `Attrs` type row for ProgressBar (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , indeterminate : Supported
    , label : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


{-| The `ChildAdmittedBy` type row for ProgressBar (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | progressBar : Ctx }


{-| The `Builder` type row for ProgressBar (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ProgressBar (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , indeterminate : Available
    , label : Available
    , slot : Available
    , style : Available
    , value : Available
    }
