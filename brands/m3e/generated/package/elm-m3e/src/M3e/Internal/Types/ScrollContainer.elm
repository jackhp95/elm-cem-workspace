module M3e.Internal.Types.ScrollContainer exposing (Is, Attrs, ChildAdmittedBy, Dividers, Builder, AttrCaps)

{-| Type definitions for ScrollContainer. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.ScrollContainer` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Dividers, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ScrollContainer (generated).
-}
type alias Is s =
    { s | scrollContainer : Brand }


{-| The `Attrs` type row for ScrollContainer (generated).
-}
type alias Attrs =
    { class : Supported
    , dividers : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , thin : Supported
    }


{-| The `ChildAdmittedBy` type row for ScrollContainer (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | scrollContainer : Ctx }


{-| The `Dividers` type row for ScrollContainer (generated).
-}
type alias Dividers =
    { above : Supported
    , aboveBelow : Supported
    , below : Supported
    , none : Supported
    }


{-| The `Builder` type row for ScrollContainer (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ScrollContainer (generated).
-}
type alias AttrCaps =
    { class : Available
    , dividers : Available
    , id : Available
    , slot : Available
    , style : Available
    , thin : Available
    }
