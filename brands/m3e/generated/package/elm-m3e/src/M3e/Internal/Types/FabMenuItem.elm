module M3e.Internal.Types.FabMenuItem exposing (Is, Attrs, IconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for FabMenuItem. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.FabMenuItem` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, IconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for FabMenuItem (generated).
-}
type alias Is s =
    { s | fabMenuItem : Brand }


{-| The `Attrs` type row for FabMenuItem (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , download : Supported
    , href : Supported
    , id : Supported
    , onClick : Supported
    , rel : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    }


{-| The `IconSlot` type row for FabMenuItem (generated).
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for FabMenuItem (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | fabMenuItem : Ctx }


{-| The `Builder` type row for FabMenuItem (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for FabMenuItem (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , download : Available
    , href : Available
    , id : Available
    , onClick : Available
    , rel : Available
    , slot : Available
    , style : Available
    , target : Available
    }


{-| The `SlotCaps` type row for FabMenuItem (generated).
-}
type alias SlotCaps =
    { icon : Available
    }
