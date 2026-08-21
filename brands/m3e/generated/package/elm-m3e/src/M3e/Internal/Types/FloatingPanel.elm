module M3e.Internal.Types.FloatingPanel exposing (Is, Attrs, ChildAdmittedBy, ScrollStrategy, Builder, AttrCaps)

{-| Type definitions for FloatingPanel. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.FloatingPanel` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, ScrollStrategy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for FloatingPanel (generated).
-}
type alias Is s =
    { s | floatingPanel : Brand }


{-| The `Attrs` type row for FloatingPanel (generated).
-}
type alias Attrs =
    { anchorOffset : Supported
    , class : Supported
    , fitAnchorWidth : Supported
    , id : Supported
    , onBeforetoggle : Supported
    , onToggle : Supported
    , scrollStrategy : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for FloatingPanel (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | floatingPanel : Ctx }


{-| The `ScrollStrategy` type row for FloatingPanel (generated).
-}
type alias ScrollStrategy =
    { hide : Supported
    , reposition : Supported
    }


{-| The `Builder` type row for FloatingPanel (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for FloatingPanel (generated).
-}
type alias AttrCaps =
    { anchorOffset : Available
    , class : Available
    , fitAnchorWidth : Available
    , id : Available
    , onBeforetoggle : Available
    , onToggle : Available
    , scrollStrategy : Available
    , slot : Available
    , style : Available
    }
