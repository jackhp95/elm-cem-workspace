module M3e.Internal.Types.ContentPane exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for ContentPane. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.ContentPane` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ContentPane (generated).
-}
type alias Is s =
    { s | contentPane : Brand }


{-| The `Attrs` type row for ContentPane (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for ContentPane (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | contentPane : Ctx }


{-| The `Builder` type row for ContentPane (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ContentPane (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    }
