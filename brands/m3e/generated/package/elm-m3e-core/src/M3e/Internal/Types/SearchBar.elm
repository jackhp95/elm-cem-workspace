module M3e.Internal.Types.SearchBar exposing (Is, Attrs, ClearIconSlot, LeadingSlot, TrailingSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for SearchBar. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.SearchBar` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ClearIconSlot, LeadingSlot, TrailingSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for SearchBar (generated).
-}
type alias Is s =
    { s | searchBar : Brand }


{-| The `Attrs` type row for SearchBar (generated).
-}
type alias Attrs =
    { class : Supported
    , clearLabel : Supported
    , clearable : Supported
    , id : Supported
    , onClear : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ClearIconSlot` type row for SearchBar (generated).
-}
type alias ClearIconSlot =
    { sharedIcon : Shared }


{-| The `LeadingSlot` type row for SearchBar (generated).
-}
type alias LeadingSlot =
    { iconButton : Brand
    , sharedIcon : Shared
    }


{-| The `TrailingSlot` type row for SearchBar (generated).
-}
type alias TrailingSlot =
    { iconButton : Brand
    , sharedIcon : Shared
    }


{-| The `ChildAdmittedBy` type row for SearchBar (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | searchBar : Ctx }


{-| The `Builder` type row for SearchBar (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for SearchBar (generated).
-}
type alias AttrCaps =
    { class : Available
    , clearLabel : Available
    , clearable : Available
    , id : Available
    , onClear : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for SearchBar (generated).
-}
type alias SlotCaps =
    { clearIcon : Available
    , input : Available
    }
