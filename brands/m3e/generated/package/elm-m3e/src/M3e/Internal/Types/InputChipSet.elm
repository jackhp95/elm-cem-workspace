module M3e.Internal.Types.InputChipSet exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for InputChipSet. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.InputChipSet` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for InputChipSet (generated).
-}
type alias Is s =
    { s | inputChipSet : Brand }


{-| The `Attrs` type row for InputChipSet (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , maxChips : Supported
    , name : Supported
    , onChange : Supported
    , required : Supported
    , slot : Supported
    , style : Supported
    , validationmessages : Supported
    , vertical : Supported
    }


{-| The `Content` type row for InputChipSet (generated).
-}
type alias Content =
    { inputChip : Brand }


{-| The `ChildAdmittedBy` type row for InputChipSet (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | inputChipSet : Ctx }


{-| The `Builder` type row for InputChipSet (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for InputChipSet (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , maxChips : Available
    , name : Available
    , onChange : Available
    , required : Available
    , slot : Available
    , style : Available
    , validationmessages : Available
    , vertical : Available
    }


{-| The `SlotCaps` type row for InputChipSet (generated).
-}
type alias SlotCaps =
    { input : Available
    }
