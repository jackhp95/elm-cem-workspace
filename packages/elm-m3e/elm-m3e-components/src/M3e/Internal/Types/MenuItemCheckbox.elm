module M3e.Internal.Types.MenuItemCheckbox exposing (..)

{-| Internal type definitions for MenuItemCheckbox — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | menuItemCheckbox : Brand }


type alias Attrs =
    { checked : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , onClick : Supported
    , slot : Supported
    , style : Supported
    }


type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


type alias IconSlot =
    { sharedIcon : Shared }


type alias TrailingIconSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | menuItemCheckbox : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { checked : Available
    , class : Available
    , disabled : Available
    , id : Available
    , onClick : Available
    , slot : Available
    , style : Available
    }


type alias SlotCaps =
    { icon : Available
    , trailingIcon : Available
    }
