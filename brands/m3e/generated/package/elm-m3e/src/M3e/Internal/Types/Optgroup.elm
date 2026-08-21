module M3e.Internal.Types.Optgroup exposing (Is, Attrs, Content, LabelSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for Optgroup. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Optgroup` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, LabelSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Optgroup (generated).
-}
type alias Is s =
    { s | optgroup : Brand }


{-| The `Attrs` type row for Optgroup (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for Optgroup (generated).
-}
type alias Content =
    { option : Brand }


{-| The `LabelSlot` type row for Optgroup (generated).
-}
type alias LabelSlot =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `ChildAdmittedBy` type row for Optgroup (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | optgroup : Ctx }


{-| The `Builder` type row for Optgroup (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Optgroup (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for Optgroup (generated).
-}
type alias SlotCaps =
    { label : Available
    }
