module Hz.Internal.Types.EventClash exposing (..)

{-| Internal type definitions for EventClash — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Hz.Forge.Internal as B
import Hz.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | eventClash : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , onError : Supported
    , onHzError : Supported
    , onHzLoad : Supported
    , onLoad : Supported
    , slot : Supported
    , style : Supported
    }


type alias Content =
    {}


type alias ChildAdmittedBy childAdm =
    { childAdm | eventClash : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , onError : Available
    , onHzError : Available
    , onHzLoad : Available
    , onLoad : Available
    , slot : Available
    , style : Available
    }
