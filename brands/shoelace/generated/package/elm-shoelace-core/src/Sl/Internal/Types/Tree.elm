module Sl.Internal.Types.Tree exposing (Is, Attrs, ChildAdmittedBy, Selection, Builder, AttrCaps)

{-| Type definitions for Tree. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Tree` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Selection, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Tree (generated).
-}
type alias Is s =
    { s | tree : Brand }


{-| The `Attrs` type row for Tree (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , onSelectionChange : Supported
    , selection : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Tree (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | tree : Ctx }


{-| The `Selection` type row for Tree (generated).
-}
type alias Selection =
    { leaf : Supported
    , multiple : Supported
    , single : Supported
    }


{-| The `Builder` type row for Tree (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Tree (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , onSelectionChange : Available
    , selection : Available
    , slot : Available
    , style : Available
    }
