module Sl.Internal.Types.Menu exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Menu. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Menu` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Menu (generated).
-}
type alias Is s =
    { s | menu : Brand }


{-| The `Attrs` type row for Menu (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , onSelect : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for Menu (generated).
-}
type alias Content =
    { divider : Brand
    , menuItem : Brand
    , menuLabel : Brand
    }


{-| The `ChildAdmittedBy` type row for Menu (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | menu : Ctx }


{-| The `Builder` type row for Menu (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Menu (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , onSelect : Available
    , slot : Available
    , style : Available
    }
