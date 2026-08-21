module Br.Internal.Types.Barren exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Barren. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Br` barrel and the strict
`Br.Element.Barren` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps

-}

import Br.Forge.Internal as B
import Br.Kind exposing (Available, Brand, Ctx, Used)
import HtmlIr.Kind exposing (Supported)


{-| The `Is` type row for Barren (generated).
-}
type alias Is s =
    { s | barren : Brand }


{-| The `Attrs` type row for Barren (generated).
-}
type alias Attrs =
    { class : Supported
    , count : Supported
    , id : Supported
    , label : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for Barren (generated).
-}
type alias Content =
    {}


{-| The `ChildAdmittedBy` type row for Barren (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | barren : Ctx }


{-| The `Builder` type row for Barren (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Barren (generated).
-}
type alias AttrCaps =
    { class : Available
    , count : Available
    , id : Available
    , label : Available
    , slot : Available
    , style : Available
    }
