module M3e.Internal.Types.SelectionIndicator exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for SelectionIndicator. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.SelectionIndicator` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for SelectionIndicator (generated).
-}
type alias Is s =
    { s | selectionIndicator : Brand }


{-| The `Attrs` type row for SelectionIndicator (generated).
-}
type alias Attrs =
    { bounce : Supported
    , centered : Supported
    , class : Supported
    , disabled : Supported
    , for : Supported
    , id : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for SelectionIndicator (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | selectionIndicator : Ctx }


{-| The `Builder` type row for SelectionIndicator (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for SelectionIndicator (generated).
-}
type alias AttrCaps =
    { bounce : Available
    , centered : Available
    , class : Available
    , disabled : Available
    , for : Available
    , id : Available
    , selected : Available
    , slot : Available
    , style : Available
    }
