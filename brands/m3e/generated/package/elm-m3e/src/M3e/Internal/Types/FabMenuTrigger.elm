module M3e.Internal.Types.FabMenuTrigger exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for FabMenuTrigger. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.FabMenuTrigger` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for FabMenuTrigger (generated).
-}
type alias Is s =
    { s | fabMenuTrigger : Brand }


{-| The `Attrs` type row for FabMenuTrigger (generated).
-}
type alias Attrs =
    { class : Supported
    , for : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for FabMenuTrigger (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | fabMenuTrigger : Ctx }


{-| The `Builder` type row for FabMenuTrigger (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for FabMenuTrigger (generated).
-}
type alias AttrCaps =
    { class : Available
    , for : Available
    , id : Available
    , slot : Available
    , style : Available
    }
