module M3e.Internal.Types.IconButton exposing (..)

{-| Internal type definitions for IconButton — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | iconButton : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , disabledInteractive : Supported
    , download : Supported
    , href : Supported
    , id : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , rel : Supported
    , selected : Supported
    , shape : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    , toggle : Supported
    , type_ : Supported
    , value : Supported
    , variant : Supported
    , width : Supported
    }


type alias Content =
    { bottomSheetAction : Brand
    , bottomSheetTrigger : Brand
    , datepickerToggle : Brand
    , dialogAction : Brand
    , dialogTrigger : Brand
    , drawerToggle : Brand
    , fabMenuTrigger : Brand
    , menuTrigger : Brand
    , navRailToggle : Brand
    , richTooltipAction : Brand
    , sharedIcon : Shared
    , stepperNext : Brand
    , stepperPrevious : Brand
    , stepperReset : Brand
    , timepickerToggle : Brand
    }


type alias SelectedSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | iconButton : Ctx }


type alias Shape =
    { rounded : Supported
    , square : Supported
    }


type alias Size =
    { extraLarge : Supported
    , extraSmall : Supported
    , large : Supported
    , medium : Supported
    , small : Supported
    }


type alias Type =
    { button : Supported
    , reset : Supported
    , submit : Supported
    }


type alias Variant =
    { filled : Supported
    , outlined : Supported
    , standard : Supported
    , tonal : Supported
    }


type alias Width =
    { default : Supported
    , narrow : Supported
    , wide : Supported
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
    , stepperNext : Supported
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
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , rel : Available
    , selected : Available
    , shape : Available
    , size : Available
    , slot : Available
    , style : Available
    , target : Available
    , toggle : Available
    , type_ : Available
    , value : Available
    , variant : Available
    , width : Available
    }


type alias SlotCaps =
    { selected : Available
    }
