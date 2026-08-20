module Sl.Internal.Types.RadioButton exposing (..)

{-| Internal type definitions for RadioButton — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | radioButton : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , onBlur : Supported
    , onFocus : Supported
    , pill : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | radioButton : Ctx }


type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , onBlur : Available
    , onFocus : Available
    , pill : Available
    , size : Available
    , slot : Available
    , style : Available
    , value : Available
    }
