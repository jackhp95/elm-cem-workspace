module M3e.Internal.Types.SuggestionChip exposing (..)

{-| Internal type definitions for SuggestionChip — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B



type alias Is s =
    { s | suggestionChip : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , disabledInteractive : Supported
    , download : Supported
    , href : Supported
    , id : Supported
    , name : Supported
    , onClick : Supported
    , rel : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    , type_ : Supported
    , value : Supported
    , variant : Supported
    }


type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


type alias IconSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | suggestionChip : Ctx }


type alias Type =
    { button : Supported
    , reset : Supported
    , submit : Supported
    }


type alias Variant =
    { elevated : Supported
    , outlined : Supported
    }


type alias ActionCaps =
    { bottomSheetAction : Supported
    , bottomSheetTrigger : Supported
    , click : Supported
    , datepickerToggle : Supported
    , dialogAction : Supported
    , dialogTrigger : Supported
    , drawerToggle : Supported
    , fabMenuTrigger : Supported
    , link : Supported
    , menuTrigger : Supported
    , navRailToggle : Supported
    , richTooltipAction : Supported
    , stepperPrevious : Supported
    , stepperReset : Supported
    , timepickerToggle : Supported
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
    , name : Available
    , onClick : Available
    , rel : Available
    , slot : Available
    , style : Available
    , target : Available
    , type_ : Available
    , value : Available
    , variant : Available
    }


type alias SlotCaps =
    { icon : Available
    }
