module M3e.Internal.Types.StateLayer exposing (..)

{-| Internal type definitions for StateLayer — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | stateLayer : Brand }


type alias Attrs =
    { class : Supported
    , disableHover : Supported
    , disabled : Supported
    , enablePressed : Supported
    , for : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | stateLayer : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disableHover : Available
    , disabled : Available
    , enablePressed : Available
    , for : Available
    , id : Available
    , slot : Available
    , style : Available
    }
