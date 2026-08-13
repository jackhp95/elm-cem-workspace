module M3e.Internal.Types.MenuItem exposing (..)

{-| Internal type definitions for MenuItem — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | menuItem : Brand }


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


type alias Content =
    { bottomSheetAction : Brand
    , bottomSheetTrigger : Brand
    , datepickerToggle : Brand
    , dialogAction : Brand
    , dialogTrigger : Brand
    , drawerToggle : Brand
    , fabMenuTrigger : Brand
    , heading : Brand
    , menuTrigger : Brand
    , navRailToggle : Brand
    , richTooltipAction : Brand
    , sharedText : Shared
    , stepperPrevious : Brand
    , stepperReset : Brand
    , timepickerToggle : Brand
    }


type alias IconSlot =
    { sharedIcon : Shared }


type alias TrailingIconSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | menuItem : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


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


type alias SlotCaps =
    { icon : Available
    , trailingIcon : Available
    }
