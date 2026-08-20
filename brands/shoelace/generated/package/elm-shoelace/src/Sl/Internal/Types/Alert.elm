module Sl.Internal.Types.Alert exposing (..)

{-| Internal type definitions for Alert — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | alert : Brand }


type alias Attrs =
    { class : Supported
    , closable : Supported
    , countdown : Supported
    , duration : Supported
    , id : Supported
    , onAfterHide : Supported
    , onAfterShow : Supported
    , onHide : Supported
    , onShow : Supported
    , open : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | alert : Ctx }


type alias Countdown =
    { ltr : Supported
    , rtl : Supported
    }


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
    , closable : Available
    , countdown : Available
    , duration : Available
    , id : Available
    , onAfterHide : Available
    , onAfterShow : Available
    , onHide : Available
    , onShow : Available
    , open : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
