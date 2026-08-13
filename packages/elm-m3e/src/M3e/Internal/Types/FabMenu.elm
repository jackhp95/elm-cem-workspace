module M3e.Internal.Types.FabMenu exposing (..)

{-| Internal type definitions for FabMenu — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | fabMenu : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , onBeforetoggle : Supported
    , onToggle : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


type alias Content =
    { fabMenuItem : Brand
    , menuItem : Brand
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | fabMenu : Ctx }


type alias Variant =
    { primary : Supported
    , secondary : Supported
    , tertiary : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , onBeforetoggle : Available
    , onToggle : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
