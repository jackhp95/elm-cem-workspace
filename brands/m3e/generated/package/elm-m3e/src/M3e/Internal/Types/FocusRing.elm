module M3e.Internal.Types.FocusRing exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for FocusRing. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.FocusRing` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for FocusRing (generated).
-}
type alias Is s =
    { s | focusRing : Brand }


{-| The `Attrs` type row for FocusRing (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , for : Supported
    , id : Supported
    , inward : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for FocusRing (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | focusRing : Ctx }


{-| The `Builder` type row for FocusRing (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for FocusRing (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , for : Available
    , id : Available
    , inward : Available
    , slot : Available
    , style : Available
    }
