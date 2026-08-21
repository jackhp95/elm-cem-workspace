module M3e.Internal.Types.Step exposing (Is, Attrs, Content, DoneIconSlot, EditIconSlot, ErrorSlot, ErrorIconSlot, HintSlot, IconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for Step. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Step` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, DoneIconSlot, EditIconSlot, ErrorSlot, ErrorIconSlot, HintSlot, IconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Step (generated).
-}
type alias Is s =
    { s | step : Brand }


{-| The `Attrs` type row for Step (generated).
-}
type alias Attrs =
    { class : Supported
    , completed : Supported
    , disabled : Supported
    , editable : Supported
    , for : Supported
    , id : Supported
    , invalid : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , optional : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for Step (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `DoneIconSlot` type row for Step (generated).
-}
type alias DoneIconSlot =
    { sharedIcon : Shared }


{-| The `EditIconSlot` type row for Step (generated).
-}
type alias EditIconSlot =
    { sharedIcon : Shared }


{-| The `ErrorSlot` type row for Step (generated).
-}
type alias ErrorSlot =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `ErrorIconSlot` type row for Step (generated).
-}
type alias ErrorIconSlot =
    { sharedIcon : Shared }


{-| The `HintSlot` type row for Step (generated).
-}
type alias HintSlot =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `IconSlot` type row for Step (generated).
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for Step (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | step : Ctx }


{-| The `Builder` type row for Step (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Step (generated).
-}
type alias AttrCaps =
    { class : Available
    , completed : Available
    , disabled : Available
    , editable : Available
    , for : Available
    , id : Available
    , invalid : Available
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , optional : Available
    , selected : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for Step (generated).
-}
type alias SlotCaps =
    { doneIcon : Available
    , editIcon : Available
    , error : Available
    , errorIcon : Available
    , hint : Available
    , icon : Available
    }
