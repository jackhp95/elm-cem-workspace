module M3e.Internal.Types.SearchView exposing (..)

{-| Internal type definitions for SearchView — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | searchView : Brand }


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


type alias ClearIconSlot =
    { sharedIcon : Shared }


type alias CloseIconSlot =
    { sharedIcon : Shared }


type alias ClosedLeadingSlot =
    { iconButton : Brand
    , sharedIcon : Shared
    }


type alias ClosedTrailingSlot =
    { iconButton : Brand
    , sharedIcon : Shared
    }


type alias OpenLeadingSlot =
    { iconButton : Brand
    , sharedIcon : Shared
    }


type alias OpenTrailingSlot =
    { iconButton : Brand
    , sharedIcon : Shared
    }


type alias SearchIconSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | searchView : Ctx }


type alias Mode =
    { auto : Supported
    , docked : Supported
    , fullscreen : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


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


type alias SlotCaps =
    { clearIcon : Available
    , closeIcon : Available
    , input : Available
    , searchIcon : Available
    }
