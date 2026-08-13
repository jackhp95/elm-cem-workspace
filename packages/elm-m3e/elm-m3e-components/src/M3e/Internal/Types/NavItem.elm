module M3e.Internal.Types.NavItem exposing (..)

{-| Internal type definitions for NavItem — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B



type alias Is s =
    { s | navItem : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , disabledInteractive : Supported
    , download : Supported
    , href : Supported
    , id : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , orientation : Supported
    , rel : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    }


type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


type alias IconSlot =
    { sharedIcon : Shared }


type alias SelectedIconSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | navItem : Ctx }


type alias Orientation =
    { horizontal : Supported
    , vertical : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , disabledInteractive : Available
    , download : Available
    , href : Available
    , id : Available
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , orientation : Available
    , rel : Available
    , selected : Available
    , slot : Available
    , style : Available
    , target : Available
    }


type alias SlotCaps =
    { icon : Available
    , selectedIcon : Available
    }
