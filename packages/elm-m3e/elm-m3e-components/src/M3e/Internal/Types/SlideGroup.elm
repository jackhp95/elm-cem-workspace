module M3e.Internal.Types.SlideGroup exposing (..)

{-| Internal type definitions for SlideGroup — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | slideGroup : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , nextPageLabel : Supported
    , previousPageLabel : Supported
    , slot : Supported
    , style : Supported
    , threshold : Supported
    , vertical : Supported
    }


type alias NextIconSlot =
    { sharedIcon : Shared }


type alias PrevIconSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | slideGroup : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , nextPageLabel : Available
    , previousPageLabel : Available
    , slot : Available
    , style : Available
    , threshold : Available
    , vertical : Available
    }


type alias SlotCaps =
    { nextIcon : Available
    , prevIcon : Available
    }
