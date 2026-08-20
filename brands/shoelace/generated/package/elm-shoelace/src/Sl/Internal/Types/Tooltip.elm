module Sl.Internal.Types.Tooltip exposing (..)

{-| Internal type definitions for Tooltip — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | tooltip : Brand }


type alias Attrs =
    { class : Supported
    , content : Supported
    , disabled : Supported
    , distance : Supported
    , hoist : Supported
    , id : Supported
    , onAfterHide : Supported
    , onAfterShow : Supported
    , onHide : Supported
    , onShow : Supported
    , open : Supported
    , placement : Supported
    , skidding : Supported
    , slot : Supported
    , style : Supported
    , trigger : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | tooltip : Ctx }


type alias Placement =
    { bottom : Supported
    , bottomEnd : Supported
    , bottomStart : Supported
    , left : Supported
    , leftEnd : Supported
    , leftStart : Supported
    , right : Supported
    , rightEnd : Supported
    , rightStart : Supported
    , top : Supported
    , topEnd : Supported
    , topStart : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , content : Available
    , disabled : Available
    , distance : Available
    , hoist : Available
    , id : Available
    , onAfterHide : Available
    , onAfterShow : Available
    , onHide : Available
    , onShow : Available
    , open : Available
    , placement : Available
    , skidding : Available
    , slot : Available
    , style : Available
    , trigger : Available
    }
