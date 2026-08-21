module Sl.Internal.Types.Breadcrumb exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Breadcrumb. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Breadcrumb` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Breadcrumb (generated).
-}
type alias Is s =
    { s | breadcrumb : Brand }


{-| The `Attrs` type row for Breadcrumb (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , label : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Breadcrumb (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | breadcrumb : Ctx }


{-| The `Builder` type row for Breadcrumb (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Breadcrumb (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , label : Available
    , slot : Available
    , style : Available
    }
