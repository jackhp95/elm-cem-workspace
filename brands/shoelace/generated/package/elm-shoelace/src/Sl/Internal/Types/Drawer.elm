module Sl.Internal.Types.Drawer exposing (..)

{-| Internal type definitions for Drawer — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | drawer : Brand }


type alias Attrs =
    { class : Supported
    , contained : Supported
    , id : Supported
    , label : Supported
    , noHeader : Supported
    , onAfterHide : Supported
    , onAfterShow : Supported
    , onHide : Supported
    , onInitialFocus : Supported
    , onRequestClose : Supported
    , onShow : Supported
    , open : Supported
    , placement : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | drawer : Ctx }


type alias Placement =
    { bottom : Supported
    , end : Supported
    , start : Supported
    , top : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , contained : Available
    , id : Available
    , label : Available
    , noHeader : Available
    , onAfterHide : Available
    , onAfterShow : Available
    , onHide : Available
    , onInitialFocus : Available
    , onRequestClose : Available
    , onShow : Available
    , open : Available
    , placement : Available
    , slot : Available
    , style : Available
    }
