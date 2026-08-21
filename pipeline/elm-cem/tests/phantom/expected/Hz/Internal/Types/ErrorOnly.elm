module Hz.Internal.Types.ErrorOnly exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for ErrorOnly. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Hz` barrel and the strict
`Hz.Element.ErrorOnly` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Hz.Forge.Internal as B
import Hz.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ErrorOnly (generated).
-}
type alias Is s =
    { s | errorOnly : Brand }


{-| The `Attrs` type row for ErrorOnly (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , onHzError : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for ErrorOnly (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | errorOnly : Ctx }


{-| The `Builder` type row for ErrorOnly (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ErrorOnly (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , onHzError : Available
    , slot : Available
    , style : Available
    }
