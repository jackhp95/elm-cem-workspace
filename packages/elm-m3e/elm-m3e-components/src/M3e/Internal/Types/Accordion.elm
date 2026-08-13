module M3e.Internal.Types.Accordion exposing (..)

{-| Internal type definitions for Accordion — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | accordion : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , multi : Supported
    , slot : Supported
    , style : Supported
    }


type alias Content =
    { expansionPanel : Brand }


type alias ChildAdmittedBy childAdm =
    { childAdm | accordion : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , multi : Available
    , slot : Available
    , style : Available
    }
