module Sl.Internal.Types.Badge exposing (Is, Attrs, ChildAdmittedBy, Variant, Builder, AttrCaps)

{-| Type definitions for Badge. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.Badge` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Badge (generated).
-}
type alias Is s =
    { s | badge : Brand }


{-| The `Attrs` type row for Badge (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , pill : Supported
    , pulse : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


{-| The `ChildAdmittedBy` type row for Badge (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | badge : Ctx }


{-| The `Variant` type row for Badge (generated).
-}
type alias Variant =
    { danger : Supported
    , neutral : Supported
    , primary : Supported
    , success : Supported
    , warning : Supported
    }


{-| The `Builder` type row for Badge (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Badge (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , pill : Available
    , pulse : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
