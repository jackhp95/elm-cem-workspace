module M3e.Internal.Types.NavMenu exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for NavMenu. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.NavMenu` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for NavMenu (generated).
-}
type alias Is s =
    { s | navMenu : Brand }


{-| The `Attrs` type row for NavMenu (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for NavMenu (generated).
-}
type alias Content =
    { divider : Brand
    , navMenuItem : Brand
    , navMenuItemGroup : Brand
    }


{-| The `ChildAdmittedBy` type row for NavMenu (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | navMenu : Ctx }


{-| The `Builder` type row for NavMenu (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for NavMenu (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    }
