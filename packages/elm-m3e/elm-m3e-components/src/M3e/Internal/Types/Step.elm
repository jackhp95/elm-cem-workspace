module M3e.Internal.Types.Step exposing (..)

{-| Internal type definitions for Step — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | step : Brand }


type alias Attrs =
    { class : Supported
    , completed : Supported
    , disabled : Supported
    , editable : Supported
    , for : Supported
    , id : Supported
    , invalid : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , optional : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    }


type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


type alias DoneIconSlot =
    { sharedIcon : Shared }


type alias EditIconSlot =
    { sharedIcon : Shared }


type alias ErrorSlot =
    { heading : Brand
    , sharedText : Shared
    }


type alias ErrorIconSlot =
    { sharedIcon : Shared }


type alias HintSlot =
    { heading : Brand
    , sharedText : Shared
    }


type alias IconSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | step : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , completed : Available
    , disabled : Available
    , editable : Available
    , for : Available
    , id : Available
    , invalid : Available
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , optional : Available
    , selected : Available
    , slot : Available
    , style : Available
    }


type alias SlotCaps =
    { doneIcon : Available
    , editIcon : Available
    , error : Available
    , errorIcon : Available
    , hint : Available
    , icon : Available
    }
