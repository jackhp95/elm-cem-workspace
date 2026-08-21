module Hz.Internal.Types.Duplicate exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Duplicate. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Hz` barrel and the strict
`Hz.Element.Duplicate` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Hz.Forge.Internal as B
import Hz.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Duplicate (generated).
-}
type alias Is s =
    { s | duplicate : Brand }


{-| The `Attrs` type row for Duplicate (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


{-| The `Content` type row for Duplicate (generated).
-}
type alias Content =
    {}


{-| The `ChildAdmittedBy` type row for Duplicate (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | duplicate : Ctx }


{-| The `Builder` type row for Duplicate (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Duplicate (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    , value : Available
    }
