module M3e.Internal.Types.Icon exposing (..)

{-| Internal type definitions for Icon — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Kind exposing (Available, Ctx, Used)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B



type alias Is s =
    { s | sharedIcon : Shared }


type alias Attrs =
    { class : Supported
    , filled : Supported
    , grade : Supported
    , id : Supported
    , name : Supported
    , opticalSize : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    , weight : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | icon : Ctx }


type alias Grade =
    { high : Supported
    , low : Supported
    , medium : Supported
    }


type alias Variant =
    { outlined : Supported
    , rounded : Supported
    , sharp : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , filled : Available
    , grade : Available
    , id : Available
    , name : Available
    , opticalSize : Available
    , slot : Available
    , style : Available
    , variant : Available
    , weight : Available
    }
