module M3e.Internal.Types.SearchView exposing (Is, Attrs, ClearIconSlot, CloseIconSlot, ClosedLeadingSlot, ClosedTrailingSlot, OpenLeadingSlot, OpenTrailingSlot, SearchIconSlot, ChildAdmittedBy, Mode, Builder, AttrCaps, SlotCaps)

{-| Type definitions for SearchView. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.SearchView` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ClearIconSlot, CloseIconSlot, ClosedLeadingSlot, ClosedTrailingSlot, OpenLeadingSlot, OpenTrailingSlot, SearchIconSlot, ChildAdmittedBy, Mode, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for SearchView (generated).
-}
type alias Is s =
    { s | searchView : Brand }


{-| The `Attrs` type row for SearchView (generated).
-}
type alias Attrs =
    { class : Supported
    , clearLabel : Supported
    , closeLabel : Supported
    , contained : Supported
    , hideSearchIcon : Supported
    , id : Supported
    , mode : Supported
    , onBeforetoggle : Supported
    , onClear : Supported
    , onQuery : Supported
    , onToggle : Supported
    , open : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ClearIconSlot` type row for SearchView (generated).
-}
type alias ClearIconSlot =
    { sharedIcon : Shared }


{-| The `CloseIconSlot` type row for SearchView (generated).
-}
type alias CloseIconSlot =
    { sharedIcon : Shared }


{-| The `ClosedLeadingSlot` type row for SearchView (generated).
-}
type alias ClosedLeadingSlot =
    { iconButton : Brand
    , sharedIcon : Shared
    }


{-| The `ClosedTrailingSlot` type row for SearchView (generated).
-}
type alias ClosedTrailingSlot =
    { iconButton : Brand
    , sharedIcon : Shared
    }


{-| The `OpenLeadingSlot` type row for SearchView (generated).
-}
type alias OpenLeadingSlot =
    { iconButton : Brand
    , sharedIcon : Shared
    }


{-| The `OpenTrailingSlot` type row for SearchView (generated).
-}
type alias OpenTrailingSlot =
    { iconButton : Brand
    , sharedIcon : Shared
    }


{-| The `SearchIconSlot` type row for SearchView (generated).
-}
type alias SearchIconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for SearchView (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | searchView : Ctx }


{-| The `Mode` type row for SearchView (generated).
-}
type alias Mode =
    { auto : Supported
    , docked : Supported
    , fullscreen : Supported
    }


{-| The `Builder` type row for SearchView (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for SearchView (generated).
-}
type alias AttrCaps =
    { class : Available
    , clearLabel : Available
    , closeLabel : Available
    , contained : Available
    , hideSearchIcon : Available
    , id : Available
    , mode : Available
    , onBeforetoggle : Available
    , onClear : Available
    , onQuery : Available
    , onToggle : Available
    , open : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for SearchView (generated).
-}
type alias SlotCaps =
    { clearIcon : Available
    , closeIcon : Available
    , input : Available
    , searchIcon : Available
    }
