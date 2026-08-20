module Sl.Internal.Types.Popup exposing (..)

{-| Internal type definitions for Popup — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | popup : Brand }


type alias Attrs =
    { active : Supported
    , anchor : Supported
    , arrow : Supported
    , arrowPadding : Supported
    , arrowPlacement : Supported
    , autoSize : Supported
    , autoSizePadding : Supported
    , autosizeboundary : Supported
    , class : Supported
    , distance : Supported
    , flip : Supported
    , flipFallbackPlacements : Supported
    , flipFallbackStrategy : Supported
    , flipPadding : Supported
    , flipboundary : Supported
    , hoverBridge : Supported
    , id : Supported
    , onReposition : Supported
    , placement : Supported
    , shift : Supported
    , shiftPadding : Supported
    , shiftboundary : Supported
    , skidding : Supported
    , slot : Supported
    , strategy : Supported
    , style : Supported
    , sync : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | popup : Ctx }


type alias ArrowPlacement =
    { anchor : Supported
    , center : Supported
    , end : Supported
    , start : Supported
    }


type alias AutoSize =
    { both : Supported
    , horizontal : Supported
    , vertical : Supported
    }


type alias FlipFallbackStrategy =
    { bestFit : Supported
    , initial : Supported
    }


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


type alias Strategy =
    { absolute : Supported
    , fixed : Supported
    }


type alias Sync =
    { both : Supported
    , height : Supported
    , width : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { active : Available
    , anchor : Available
    , arrow : Available
    , arrowPadding : Available
    , arrowPlacement : Available
    , autoSize : Available
    , autoSizePadding : Available
    , autosizeboundary : Available
    , class : Available
    , distance : Available
    , flip : Available
    , flipFallbackPlacements : Available
    , flipFallbackStrategy : Available
    , flipPadding : Available
    , flipboundary : Available
    , hoverBridge : Available
    , id : Available
    , onReposition : Available
    , placement : Available
    , shift : Available
    , shiftPadding : Available
    , shiftboundary : Available
    , skidding : Available
    , slot : Available
    , strategy : Available
    , style : Available
    , sync : Available
    }
