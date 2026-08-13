module M3e.Internal.Types.Collapsible exposing (..)

{-| Internal type definitions for Collapsible — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B



type alias Is s =
    { s | collapsible : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , noAnimate : Supported
    , onClosed : Supported
    , onClosing : Supported
    , onOpened : Supported
    , onOpening : Supported
    , open : Supported
    , orientation : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | collapsible : Ctx }


type alias Orientation =
    { both : Supported
    , horizontal : Supported
    , vertical : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , noAnimate : Available
    , onClosed : Available
    , onClosing : Available
    , onOpened : Available
    , onOpening : Available
    , open : Available
    , orientation : Available
    , slot : Available
    , style : Available
    }
