module M3e.Internal.Types.NavMenu exposing (..)

{-| Internal type definitions for NavMenu — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | navMenu : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


type alias Content =
    { divider : Brand
    , navMenuItem : Brand
    , navMenuItemGroup : Brand
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | navMenu : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    }
