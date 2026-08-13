module M3e.Internal.Types.Toolbar exposing (..)

{-| Internal type definitions for Toolbar — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | toolbar : Brand }


type alias Attrs =
    { class : Supported
    , elevated : Supported
    , id : Supported
    , shape : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    , vertical : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | toolbar : Ctx }


type alias Shape =
    { rounded : Supported
    , square : Supported
    }


type alias Variant =
    { standard : Supported
    , vibrant : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , elevated : Available
    , id : Available
    , shape : Available
    , slot : Available
    , style : Available
    , variant : Available
    , vertical : Available
    }
