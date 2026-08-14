module Hz.Internal.Types.Duplicate exposing (..)

{-| Internal type definitions for Duplicate — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Hz.Forge.Internal as B
import Hz.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | duplicate : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


type alias Content =
    {}


type alias ChildAdmittedBy childAdm =
    { childAdm | duplicate : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    , value : Available
    }
