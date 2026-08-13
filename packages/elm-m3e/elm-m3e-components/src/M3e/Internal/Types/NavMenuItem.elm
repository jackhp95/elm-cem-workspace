module M3e.Internal.Types.NavMenuItem exposing (..)

{-| Internal type definitions for NavMenuItem — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | navMenuItem : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , onClick : Supported
    , onClosed : Supported
    , onClosing : Supported
    , onOpened : Supported
    , onOpening : Supported
    , open : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    }


type alias Content =
    { navMenuItem : Brand }


type alias BadgeSlot =
    { badge : Brand
    , heading : Brand
    , sharedText : Shared
    }


type alias IconSlot =
    { sharedIcon : Shared }


type alias LabelSlot =
    { heading : Brand
    , sharedLink : Shared
    , sharedText : Shared
    }


type alias SelectedIconSlot =
    { sharedIcon : Shared }


type alias ToggleIconSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | navMenuItem : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , onClick : Available
    , onClosed : Available
    , onClosing : Available
    , onOpened : Available
    , onOpening : Available
    , open : Available
    , selected : Available
    , slot : Available
    , style : Available
    }


type alias SlotCaps =
    { badge : Available
    , icon : Available
    , label : Available
    , selectedIcon : Available
    , toggleIcon : Available
    }
