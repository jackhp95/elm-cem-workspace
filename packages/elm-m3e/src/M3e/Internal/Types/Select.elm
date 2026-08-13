module M3e.Internal.Types.Select exposing (..)

{-| Internal type definitions for Select — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | select : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , hideSelectionIndicator : Supported
    , id : Supported
    , multi : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onInput : Supported
    , onToggle : Supported
    , panelClass : Supported
    , required : Supported
    , slot : Supported
    , style : Supported
    , validationmessages : Supported
    }


type alias Content =
    { optgroup : Brand
    , option : Brand
    }


type alias ArrowSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | select : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , hideSelectionIndicator : Available
    , id : Available
    , multi : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onInput : Available
    , onToggle : Available
    , panelClass : Available
    , required : Available
    , slot : Available
    , style : Available
    , validationmessages : Available
    }


type alias SlotCaps =
    { arrow : Available
    , value : Available
    }
