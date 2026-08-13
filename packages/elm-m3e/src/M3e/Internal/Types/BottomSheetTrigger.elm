module M3e.Internal.Types.BottomSheetTrigger exposing (..)

{-| Internal type definitions for BottomSheetTrigger — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | bottomSheetTrigger : Brand }


type alias Attrs =
    { class : Supported
    , detent : Supported
    , for : Supported
    , id : Supported
    , secondary : Supported
    , slot : Supported
    , style : Supported
    }


type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | bottomSheetTrigger : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , detent : Available
    , for : Available
    , id : Available
    , secondary : Available
    , slot : Available
    , style : Available
    }
