module M3e.Internal.Types.ButtonGroup exposing (..)

{-| Internal type definitions for ButtonGroup — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B



type alias Is s =
    { s | buttonGroup : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , multi : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


type alias Content =
    { button : Brand
    , iconButton : Brand
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | buttonGroup : Ctx }


type alias Size =
    { extraLarge : Supported
    , extraSmall : Supported
    , large : Supported
    , medium : Supported
    , small : Supported
    }


type alias Variant =
    { connected : Supported
    , standard : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , multi : Available
    , size : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
