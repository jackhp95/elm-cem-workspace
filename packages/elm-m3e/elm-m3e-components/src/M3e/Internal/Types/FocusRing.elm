module M3e.Internal.Types.FocusRing exposing (..)

{-| Internal type definitions for FocusRing — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | focusRing : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , for : Supported
    , id : Supported
    , inward : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | focusRing : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , for : Available
    , id : Available
    , inward : Available
    , slot : Available
    , style : Available
    }
