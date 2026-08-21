module Sl.Internal.Types.TreeItem exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for TreeItem. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.TreeItem` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for TreeItem (generated).
-}
type alias Is s =
    { s | treeItem : Brand }


{-| The `Attrs` type row for TreeItem (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , expanded : Supported
    , id : Supported
    , lazy : Supported
    , onAfterCollapse : Supported
    , onAfterExpand : Supported
    , onCollapse : Supported
    , onExpand : Supported
    , onLazyChange : Supported
    , onLazyLoad : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for TreeItem (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | treeItem : Ctx }


{-| The `Builder` type row for TreeItem (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for TreeItem (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , expanded : Available
    , id : Available
    , lazy : Available
    , onAfterCollapse : Available
    , onAfterExpand : Available
    , onCollapse : Available
    , onExpand : Available
    , onLazyChange : Available
    , onLazyLoad : Available
    , selected : Available
    , slot : Available
    , style : Available
    }
