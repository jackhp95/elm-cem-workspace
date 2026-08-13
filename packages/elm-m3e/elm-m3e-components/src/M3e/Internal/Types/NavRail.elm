module M3e.Internal.Types.NavRail exposing (..)

{-| Internal type definitions for NavRail — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B



type alias Is s =
    { s | navRail : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , mode : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onInput : Supported
    , slot : Supported
    , style : Supported
    }


type alias Content =
    { fab : Brand
    , iconButton : Brand
    , navItem : Brand
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | navRail : Ctx }


type alias Mode =
    { auto : Supported
    , compact : Supported
    , expanded : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , mode : Available
    , onBeforeinput : Available
    , onChange : Available
    , onInput : Available
    , slot : Available
    , style : Available
    }
