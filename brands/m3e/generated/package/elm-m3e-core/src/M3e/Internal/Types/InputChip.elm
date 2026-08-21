module M3e.Internal.Types.InputChip exposing (Is, Attrs, Content, AvatarSlot, IconSlot, RemoveIconSlot, ChildAdmittedBy, Variant, Builder, AttrCaps, SlotCaps)

{-| Type definitions for InputChip. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.InputChip` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, AvatarSlot, IconSlot, RemoveIconSlot, ChildAdmittedBy, Variant, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for InputChip (generated).
-}
type alias Is s =
    { s | inputChip : Brand }


{-| The `Attrs` type row for InputChip (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , disabledInteractive : Supported
    , id : Supported
    , onClick : Supported
    , onRemove : Supported
    , removable : Supported
    , removeLabel : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    , variant : Supported
    }


{-| The `Content` type row for InputChip (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `AvatarSlot` type row for InputChip (generated).
-}
type alias AvatarSlot =
    { avatar : Brand }


{-| The `IconSlot` type row for InputChip (generated).
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The `RemoveIconSlot` type row for InputChip (generated).
-}
type alias RemoveIconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for InputChip (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | inputChip : Ctx }


{-| The `Variant` type row for InputChip (generated).
-}
type alias Variant =
    { elevated : Supported
    , outlined : Supported
    }


{-| The `Builder` type row for InputChip (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for InputChip (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , disabledInteractive : Available
    , id : Available
    , onClick : Available
    , onRemove : Available
    , removable : Available
    , removeLabel : Available
    , slot : Available
    , style : Available
    , value : Available
    , variant : Available
    }


{-| The `SlotCaps` type row for InputChip (generated).
-}
type alias SlotCaps =
    { avatar : Available
    , icon : Available
    , removeIcon : Available
    }
