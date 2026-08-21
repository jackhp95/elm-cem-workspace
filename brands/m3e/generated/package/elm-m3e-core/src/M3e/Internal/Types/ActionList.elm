module M3e.Internal.Types.ActionList exposing (Is, Attrs, Content, ChildAdmittedBy, Variant, Builder, AttrCaps)

{-| Type definitions for ActionList. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.ActionList` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ActionList (generated).
-}
type alias Is s =
    { s | actionList : Brand }


{-| The `Attrs` type row for ActionList (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


{-| The `Content` type row for ActionList (generated).
-}
type alias Content =
    { divider : Brand
    , expandableListItem : Brand
    , listAction : Brand
    }


{-| The `ChildAdmittedBy` type row for ActionList (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | actionList : Ctx }


{-| The `Variant` type row for ActionList (generated).
-}
type alias Variant =
    { segmented : Supported
    , standard : Supported
    }


{-| The `Builder` type row for ActionList (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ActionList (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
