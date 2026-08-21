module M3e.Internal.Types.NavMenuItemGroup exposing (Is, Attrs, Content, LabelSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for NavMenuItemGroup. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.NavMenuItemGroup` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, LabelSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for NavMenuItemGroup (generated).
-}
type alias Is s =
    { s | navMenuItemGroup : Brand }


{-| The `Attrs` type row for NavMenuItemGroup (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for NavMenuItemGroup (generated).
-}
type alias Content =
    { navMenuItem : Brand }


{-| The `LabelSlot` type row for NavMenuItemGroup (generated).
-}
type alias LabelSlot =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `ChildAdmittedBy` type row for NavMenuItemGroup (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | navMenuItemGroup : Ctx }


{-| The `Builder` type row for NavMenuItemGroup (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for NavMenuItemGroup (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for NavMenuItemGroup (generated).
-}
type alias SlotCaps =
    { label : Available
    }
