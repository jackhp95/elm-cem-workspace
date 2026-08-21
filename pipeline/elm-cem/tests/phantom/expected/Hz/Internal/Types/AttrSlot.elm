module Hz.Internal.Types.AttrSlot exposing (Is, Attrs, HintSlot, LabelSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for AttrSlot. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Hz` barrel and the strict
`Hz.Element.AttrSlot` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, HintSlot, LabelSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Supported)
import Hz.Forge.Internal as B
import Hz.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for AttrSlot (generated).
-}
type alias Is s =
    { s | attrSlot : Brand }


{-| The `Attrs` type row for AttrSlot (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , withHint : Supported
    , withLabel : Supported
    }


{-| The `HintSlot` type row for AttrSlot (generated).
-}
type alias HintSlot =
    {}


{-| The `LabelSlot` type row for AttrSlot (generated).
-}
type alias LabelSlot =
    {}


{-| The `ChildAdmittedBy` type row for AttrSlot (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | attrSlot : Ctx }


{-| The `Builder` type row for AttrSlot (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for AttrSlot (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    , withHint : Available
    , withLabel : Available
    }


{-| The `SlotCaps` type row for AttrSlot (generated).
-}
type alias SlotCaps =
    { hint : Available
    , label : Available
    }
