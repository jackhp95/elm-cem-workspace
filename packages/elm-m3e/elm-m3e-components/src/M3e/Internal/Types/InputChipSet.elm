module M3e.Internal.Types.InputChipSet exposing (..)

{-| Internal type definitions for InputChipSet — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | inputChipSet : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , name : Supported
    , onChange : Supported
    , required : Supported
    , slot : Supported
    , style : Supported
    , validationmessages : Supported
    , vertical : Supported
    }


type alias Content =
    { inputChip : Brand }


type alias ChildAdmittedBy childAdm =
    { childAdm | inputChipSet : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , name : Available
    , onChange : Available
    , required : Available
    , slot : Available
    , style : Available
    , validationmessages : Available
    , vertical : Available
    }


type alias SlotCaps =
    { input : Available
    }
