module Sl.Internal.Types.Badge exposing (..)

{-| Internal type definitions for Badge — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | badge : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , pill : Supported
    , pulse : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | badge : Ctx }


type alias Variant =
    { danger : Supported
    , neutral : Supported
    , primary : Supported
    , success : Supported
    , warning : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , pill : Available
    , pulse : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
