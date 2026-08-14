module Or.Internal.Types.Widget exposing (..)

{-| Internal type definitions for Widget — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Or.Forge.Internal as B
import Or.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | widget : Brand }


type alias Attrs =
    { cdir : Supported
    , cflag : Supported
    , class : Supported
    , label : Supported
    }


type alias Content =
    {}


type alias ChildAdmittedBy childAdm =
    { childAdm | widget : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { cdir : Available
    , cflag : Available
    , class : Available
    , label : Available
    }
