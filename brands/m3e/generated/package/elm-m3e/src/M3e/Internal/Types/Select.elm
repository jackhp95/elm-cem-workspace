module M3e.Internal.Types.Select exposing (Is, Attrs, Content, ArrowSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for Select. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Select` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ArrowSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Select (generated).
-}
type alias Is s =
    { s | select : Brand }


{-| The `Attrs` type row for Select (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , hideSelectionIndicator : Supported
    , id : Supported
    , multi : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onInput : Supported
    , onToggle : Supported
    , panelClass : Supported
    , required : Supported
    , slot : Supported
    , style : Supported
    , validationmessages : Supported
    }


{-| The `Content` type row for Select (generated).
-}
type alias Content =
    { optgroup : Brand
    , option : Brand
    }


{-| The `ArrowSlot` type row for Select (generated).
-}
type alias ArrowSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for Select (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | select : Ctx }


{-| The `Builder` type row for Select (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Select (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , hideSelectionIndicator : Available
    , id : Available
    , multi : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onInput : Available
    , onToggle : Available
    , panelClass : Available
    , required : Available
    , slot : Available
    , style : Available
    , validationmessages : Available
    }


{-| The `SlotCaps` type row for Select (generated).
-}
type alias SlotCaps =
    { arrow : Available
    , value : Available
    }
