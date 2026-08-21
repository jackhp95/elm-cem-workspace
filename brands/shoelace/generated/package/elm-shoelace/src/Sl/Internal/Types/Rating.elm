module Sl.Internal.Types.Rating exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Rating. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.Rating` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Rating (generated).
-}
type alias Is s =
    { s | rating : Brand }


{-| The `Attrs` type row for Rating (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , getsymbol : Supported
    , id : Supported
    , label : Supported
    , max : Supported
    , onChange : Supported
    , onHover : Supported
    , precision : Supported
    , readonly : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


{-| The `ChildAdmittedBy` type row for Rating (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | rating : Ctx }


{-| The `Builder` type row for Rating (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Rating (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , getsymbol : Available
    , id : Available
    , label : Available
    , max : Available
    , onChange : Available
    , onHover : Available
    , precision : Available
    , readonly : Available
    , slot : Available
    , style : Available
    , value : Available
    }
