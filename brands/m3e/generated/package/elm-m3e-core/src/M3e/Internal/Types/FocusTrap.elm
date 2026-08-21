module M3e.Internal.Types.FocusTrap exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for FocusTrap. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.FocusTrap` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for FocusTrap (generated).
-}
type alias Is s =
    { s | focusTrap : Brand }


{-| The `Attrs` type row for FocusTrap (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for FocusTrap (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | focusTrap : Ctx }


{-| The `Builder` type row for FocusTrap (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for FocusTrap (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , slot : Available
    , style : Available
    }
