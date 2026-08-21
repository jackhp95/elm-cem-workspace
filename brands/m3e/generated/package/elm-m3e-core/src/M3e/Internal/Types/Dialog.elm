module M3e.Internal.Types.Dialog exposing (Is, Attrs, CloseIconSlot, HeaderSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for Dialog. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Dialog` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, CloseIconSlot, HeaderSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Dialog (generated).
-}
type alias Is s =
    { s | dialog : Brand }


{-| The `Attrs` type row for Dialog (generated).
-}
type alias Attrs =
    { alert : Supported
    , class : Supported
    , closeLabel : Supported
    , disableClose : Supported
    , dismissible : Supported
    , id : Supported
    , noFocusTrap : Supported
    , onCancel : Supported
    , onClosed : Supported
    , onClosing : Supported
    , onOpened : Supported
    , onOpening : Supported
    , open : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `CloseIconSlot` type row for Dialog (generated).
-}
type alias CloseIconSlot =
    { sharedIcon : Shared }


{-| The `HeaderSlot` type row for Dialog (generated).
-}
type alias HeaderSlot =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `ChildAdmittedBy` type row for Dialog (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | dialog : Ctx }


{-| The `Builder` type row for Dialog (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Dialog (generated).
-}
type alias AttrCaps =
    { alert : Available
    , class : Available
    , closeLabel : Available
    , disableClose : Available
    , dismissible : Available
    , id : Available
    , noFocusTrap : Available
    , onCancel : Available
    , onClosed : Available
    , onClosing : Available
    , onOpened : Available
    , onOpening : Available
    , open : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for Dialog (generated).
-}
type alias SlotCaps =
    { actions : Available
    , closeIcon : Available
    , header : Available
    }
