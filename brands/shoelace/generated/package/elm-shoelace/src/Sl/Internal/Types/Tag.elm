module Sl.Internal.Types.Tag exposing (..)

{-| Internal type definitions for Tag — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | tag : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , onRemove : Supported
    , pill : Supported
    , removable : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | tag : Ctx }


type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


type alias Variant =
    { danger : Supported
    , neutral : Supported
    , primary : Supported
    , success : Supported
    , text : Supported
    , warning : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , onRemove : Available
    , pill : Available
    , removable : Available
    , size : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
