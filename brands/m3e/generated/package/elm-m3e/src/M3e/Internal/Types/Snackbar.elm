module M3e.Internal.Types.Snackbar exposing (Is, Attrs, Content, CloseIconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for Snackbar. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Snackbar` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, CloseIconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Snackbar (generated).
-}
type alias Is s =
    { s | snackbar : Brand }


{-| The `Attrs` type row for Snackbar (generated).
-}
type alias Attrs =
    { action : Supported
    , class : Supported
    , closeLabel : Supported
    , dismissible : Supported
    , duration : Supported
    , id : Supported
    , onBeforetoggle : Supported
    , onToggle : Supported
    , open : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for Snackbar (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `CloseIconSlot` type row for Snackbar (generated).
-}
type alias CloseIconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for Snackbar (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | snackbar : Ctx }


{-| The `Builder` type row for Snackbar (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Snackbar (generated).
-}
type alias AttrCaps =
    { action : Available
    , class : Available
    , closeLabel : Available
    , dismissible : Available
    , duration : Available
    , id : Available
    , onBeforetoggle : Available
    , onToggle : Available
    , open : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for Snackbar (generated).
-}
type alias SlotCaps =
    { closeIcon : Available
    }
