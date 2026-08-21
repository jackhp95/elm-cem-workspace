module M3e.Internal.Types.TocItem exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for TocItem. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.TocItem` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for TocItem (generated).
-}
type alias Is s =
    { s | tocItem : Brand }


{-| The `Attrs` type row for TocItem (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , onClick : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for TocItem (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `ChildAdmittedBy` type row for TocItem (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | tocItem : Ctx }


{-| The `Builder` type row for TocItem (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for TocItem (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , onClick : Available
    , selected : Available
    , slot : Available
    , style : Available
    }
