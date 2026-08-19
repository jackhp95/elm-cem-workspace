module Hz.Internal.Types.ErrorOnly exposing (..)

{-| Internal type definitions for ErrorOnly — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Hz.Forge.Internal as B
import Hz.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | errorOnly : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , onHzError : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | errorOnly : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , onHzError : Available
    , slot : Available
    , style : Available
    }
