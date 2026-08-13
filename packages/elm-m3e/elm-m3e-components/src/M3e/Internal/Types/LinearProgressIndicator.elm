module M3e.Internal.Types.LinearProgressIndicator exposing (..)

{-| Internal type definitions for LinearProgressIndicator — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B



type alias Is s =
    { s | linearProgressIndicator : Brand }


type alias Attrs =
    { bufferValue : Supported
    , class : Supported
    , id : Supported
    , max : Supported
    , mode : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    , variant : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | linearProgressIndicator : Ctx }


type alias Mode =
    { buffer : Supported
    , determinate : Supported
    , indeterminate : Supported
    , query : Supported
    }


type alias Variant =
    { flat : Supported
    , wavy : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { bufferValue : Available
    , class : Available
    , id : Available
    , max : Available
    , mode : Available
    , slot : Available
    , style : Available
    , value : Available
    , variant : Available
    }
