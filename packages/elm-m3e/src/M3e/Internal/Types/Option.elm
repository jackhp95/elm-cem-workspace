module M3e.Internal.Types.Option exposing (..)

{-| Internal type definitions for Option — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | option : Brand }


type alias Attrs =
    { class : Supported
    , disableHighlight : Supported
    , disabled : Supported
    , highlightMode : Supported
    , id : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    , term : Supported
    , value : Supported
    }


type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | option : Ctx }


type alias HighlightMode =
    { contains : Supported
    , endsWith : Supported
    , startsWith : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disableHighlight : Available
    , disabled : Available
    , highlightMode : Available
    , id : Available
    , selected : Available
    , slot : Available
    , style : Available
    , term : Available
    , value : Available
    }
