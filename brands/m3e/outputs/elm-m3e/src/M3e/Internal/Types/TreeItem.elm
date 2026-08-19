module M3e.Internal.Types.TreeItem exposing (..)

{-| Internal type definitions for TreeItem — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | treeItem : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , indeterminate : Supported
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
    { treeItem : Brand }


type alias IconSlot =
    { sharedIcon : Shared }


type alias LabelSlot =
    { heading : Brand
    , sharedLink : Shared
    , sharedText : Shared
    }


type alias OpenToggleIconSlot =
    { sharedIcon : Shared }


type alias SelectedIconSlot =
    { sharedIcon : Shared }


type alias ToggleIconSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | treeItem : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , indeterminate : Available
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
    { icon : Available
    , label : Available
    , openToggleIcon : Available
    , selectedIcon : Available
    , toggleIcon : Available
    }
