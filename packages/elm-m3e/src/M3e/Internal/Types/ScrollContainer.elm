module M3e.Internal.Types.ScrollContainer exposing (..)

{-| Internal type definitions for ScrollContainer — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | scrollContainer : Brand }


type alias Attrs =
    { class : Supported
    , dividers : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , thin : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | scrollContainer : Ctx }


type alias Dividers =
    { above : Supported
    , aboveBelow : Supported
    , below : Supported
    , none : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , dividers : Available
    , id : Available
    , slot : Available
    , style : Available
    , thin : Available
    }
