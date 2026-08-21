module M3e.Internal.Types.SplitButton exposing (Is, Attrs, LeadingButtonSlot, TrailingButtonSlot, ChildAdmittedBy, Size, Variant, Builder, AttrCaps, SlotCaps)

{-| Type definitions for SplitButton. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.SplitButton` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, LeadingButtonSlot, TrailingButtonSlot, ChildAdmittedBy, Size, Variant, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for SplitButton (generated).
-}
type alias Is s =
    { s | splitButton : Brand }


{-| The `Attrs` type row for SplitButton (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


{-| The `LeadingButtonSlot` type row for SplitButton (generated).
-}
type alias LeadingButtonSlot =
    { button : Brand }


{-| The `TrailingButtonSlot` type row for SplitButton (generated).
-}
type alias TrailingButtonSlot =
    { iconButton : Brand }


{-| The `ChildAdmittedBy` type row for SplitButton (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | splitButton : Ctx }


{-| The `Size` type row for SplitButton (generated).
-}
type alias Size =
    { extraLarge : Supported
    , extraSmall : Supported
    , large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Variant` type row for SplitButton (generated).
-}
type alias Variant =
    { elevated : Supported
    , filled : Supported
    , outlined : Supported
    , tonal : Supported
    }


{-| The `Builder` type row for SplitButton (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for SplitButton (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , size : Available
    , slot : Available
    , style : Available
    , variant : Available
    }


{-| The `SlotCaps` type row for SplitButton (generated).
-}
type alias SlotCaps =
    { leadingButton : Available
    , trailingButton : Available
    }
