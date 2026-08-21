module M3e.Internal.Types.BottomSheet exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for BottomSheet. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.BottomSheet` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for BottomSheet (generated).
-}
type alias Is s =
    { s | bottomSheet : Brand }


{-| The `Attrs` type row for BottomSheet (generated).
-}
type alias Attrs =
    { class : Supported
    , detent : Supported
    , detents : Supported
    , handle : Supported
    , handleLabel : Supported
    , hideFriction : Supported
    , hideable : Supported
    , id : Supported
    , modal : Supported
    , onCancel : Supported
    , onClosed : Supported
    , onClosing : Supported
    , onOpened : Supported
    , onOpening : Supported
    , open : Supported
    , overshootLimit : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for BottomSheet (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | bottomSheet : Ctx }


{-| The `Builder` type row for BottomSheet (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for BottomSheet (generated).
-}
type alias AttrCaps =
    { class : Available
    , detent : Available
    , detents : Available
    , handle : Available
    , handleLabel : Available
    , hideFriction : Available
    , hideable : Available
    , id : Available
    , modal : Available
    , onCancel : Available
    , onClosed : Available
    , onClosing : Available
    , onOpened : Available
    , onOpening : Available
    , open : Available
    , overshootLimit : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for BottomSheet (generated).
-}
type alias SlotCaps =
    { header : Available
    }
