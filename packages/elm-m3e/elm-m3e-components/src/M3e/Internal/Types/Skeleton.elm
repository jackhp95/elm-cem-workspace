module M3e.Internal.Types.Skeleton exposing (..)

{-| Internal type definitions for Skeleton — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B



type alias Is s =
    { s | skeleton : Brand }


type alias Attrs =
    { animation : Supported
    , class : Supported
    , id : Supported
    , loaded : Supported
    , shape : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | skeleton : Ctx }


type alias Animation =
    { none : Supported
    , pulse : Supported
    , wave : Supported
    }


type alias Shape =
    { auto : Supported
    , circular : Supported
    , rounded : Supported
    , square : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { animation : Available
    , class : Available
    , id : Available
    , loaded : Available
    , shape : Available
    , slot : Available
    , style : Available
    }
