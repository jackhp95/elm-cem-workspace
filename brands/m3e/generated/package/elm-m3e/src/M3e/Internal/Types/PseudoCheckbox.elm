module M3e.Internal.Types.PseudoCheckbox exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for PseudoCheckbox. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.PseudoCheckbox` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for PseudoCheckbox (generated).
-}
type alias Is s =
    { s | pseudoCheckbox : Brand }


{-| The `Attrs` type row for PseudoCheckbox (generated).
-}
type alias Attrs =
    { checked : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , indeterminate : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for PseudoCheckbox (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | pseudoCheckbox : Ctx }


{-| The `Builder` type row for PseudoCheckbox (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for PseudoCheckbox (generated).
-}
type alias AttrCaps =
    { checked : Available
    , class : Available
    , disabled : Available
    , id : Available
    , indeterminate : Available
    , slot : Available
    , style : Available
    }
