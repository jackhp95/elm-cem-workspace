module M3e.Internal.Types.Divider exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Divider. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Divider` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Divider (generated).
-}
type alias Is s =
    { s | divider : Brand }


{-| The `Attrs` type row for Divider (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , inset : Supported
    , insetEnd : Supported
    , insetStart : Supported
    , slot : Supported
    , style : Supported
    , vertical : Supported
    }


{-| The `ChildAdmittedBy` type row for Divider (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | divider : Ctx }


{-| The `Builder` type row for Divider (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Divider (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , inset : Available
    , insetEnd : Available
    , insetStart : Available
    , slot : Available
    , style : Available
    , vertical : Available
    }
