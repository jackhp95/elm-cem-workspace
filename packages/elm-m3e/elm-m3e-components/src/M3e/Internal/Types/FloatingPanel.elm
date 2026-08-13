module M3e.Internal.Types.FloatingPanel exposing (..)

{-| Internal type definitions for FloatingPanel — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B



type alias Is s =
    { s | floatingPanel : Brand }


type alias Attrs =
    { anchorOffset : Supported
    , class : Supported
    , fitAnchorWidth : Supported
    , id : Supported
    , onBeforetoggle : Supported
    , onToggle : Supported
    , scrollStrategy : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | floatingPanel : Ctx }


type alias ScrollStrategy =
    { hide : Supported
    , reposition : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { anchorOffset : Available
    , class : Available
    , fitAnchorWidth : Available
    , id : Available
    , onBeforetoggle : Available
    , onToggle : Available
    , scrollStrategy : Available
    , slot : Available
    , style : Available
    }
