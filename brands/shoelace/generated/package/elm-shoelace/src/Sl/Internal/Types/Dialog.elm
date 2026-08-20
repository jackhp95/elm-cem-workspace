module Sl.Internal.Types.Dialog exposing (..)

{-| Internal type definitions for Dialog — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | dialog : Brand }


type alias Attrs =
    { class : Supported
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
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | dialog : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
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
    , slot : Available
    , style : Available
    }
