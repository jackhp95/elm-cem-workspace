module Sl.Internal.Types.TabGroup exposing (..)

{-| Internal type definitions for TabGroup — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | tabGroup : Brand }


type alias Attrs =
    { activation : Supported
    , class : Supported
    , fixedScrollControls : Supported
    , id : Supported
    , noScrollControls : Supported
    , onTabHide : Supported
    , onTabShow : Supported
    , placement : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | tabGroup : Ctx }


type alias Activation =
    { auto : Supported
    , manual : Supported
    }


type alias Placement =
    { bottom : Supported
    , end : Supported
    , start : Supported
    , top : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { activation : Available
    , class : Available
    , fixedScrollControls : Available
    , id : Available
    , noScrollControls : Available
    , onTabHide : Available
    , onTabShow : Available
    , placement : Available
    , slot : Available
    , style : Available
    }
