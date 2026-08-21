module Or.Internal.Types.Widget exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Widget. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Or` barrel and the strict
`Or.Element.Widget` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Or.Forge.Internal as B
import Or.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Widget (generated).
-}
type alias Is s =
    { s | widget : Brand }


{-| The `Attrs` type row for Widget (generated).
-}
type alias Attrs =
    { cdir : Supported
    , cflag : Supported
    , class : Supported
    , label : Supported
    }


{-| The `Content` type row for Widget (generated).
-}
type alias Content =
    {}


{-| The `ChildAdmittedBy` type row for Widget (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | widget : Ctx }


{-| The `Builder` type row for Widget (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Widget (generated).
-}
type alias AttrCaps =
    { cdir : Available
    , cflag : Available
    , class : Available
    , label : Available
    }
