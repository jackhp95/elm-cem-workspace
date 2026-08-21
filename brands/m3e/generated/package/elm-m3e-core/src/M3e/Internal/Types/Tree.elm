module M3e.Internal.Types.Tree exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Tree. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Tree` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Tree (generated).
-}
type alias Is s =
    { s | tree : Brand }


{-| The `Attrs` type row for Tree (generated).
-}
type alias Attrs =
    { cascade : Supported
    , class : Supported
    , id : Supported
    , multi : Supported
    , onChange : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for Tree (generated).
-}
type alias Content =
    { treeItem : Brand }


{-| The `ChildAdmittedBy` type row for Tree (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | tree : Ctx }


{-| The `Builder` type row for Tree (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Tree (generated).
-}
type alias AttrCaps =
    { cascade : Available
    , class : Available
    , id : Available
    , multi : Available
    , onChange : Available
    , slot : Available
    , style : Available
    }
