module M3e.Internal.Types.StepPanel exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for StepPanel. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.StepPanel` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for StepPanel (generated).
-}
type alias Is s =
    { s | stepPanel : Brand }


{-| The `Attrs` type row for StepPanel (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for StepPanel (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | stepPanel : Ctx }


{-| The `Builder` type row for StepPanel (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for StepPanel (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for StepPanel (generated).
-}
type alias SlotCaps =
    { actions : Available
    }
