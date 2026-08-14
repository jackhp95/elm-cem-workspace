module M3e.Internal.Types.Tree exposing (..)

{-| Internal type definitions for Tree — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | tree : Brand }


type alias Attrs =
    { cascade : Supported
    , class : Supported
    , id : Supported
    , multi : Supported
    , onChange : Supported
    , slot : Supported
    , style : Supported
    }


type alias Content =
    { treeItem : Brand }


type alias ChildAdmittedBy childAdm =
    { childAdm | tree : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { cascade : Available
    , class : Available
    , id : Available
    , multi : Available
    , onChange : Available
    , slot : Available
    , style : Available
    }
