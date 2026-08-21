module Hz.Internal.Types.Placement exposing (Is, Attrs, Content, ChildAdmittedBy, Position, Builder, AttrCaps)

{-| Type definitions for Placement. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Hz` barrel and the strict
`Hz.Element.Placement` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Position, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Hz.Forge.Internal as B
import Hz.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Placement (generated).
-}
type alias Is s =
    { s | placement : Brand }


{-| The `Attrs` type row for Placement (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , position : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for Placement (generated).
-}
type alias Content =
    {}


{-| The `ChildAdmittedBy` type row for Placement (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | placement : Ctx }


{-| The `Position` type row for Placement (generated).
-}
type alias Position =
    { blank_ : Supported
    , parent_ : Supported
    , self_ : Supported
    , top_ : Supported
    , top : Supported
    }


{-| The `Builder` type row for Placement (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Placement (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , position : Available
    , slot : Available
    , style : Available
    }
