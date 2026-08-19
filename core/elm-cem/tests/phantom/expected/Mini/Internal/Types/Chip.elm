module Mini.Internal.Types.Chip exposing (..)

{-| Internal type definitions for Chip — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Mini.Forge.Internal as B
import Mini.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | chip : Brand }


type alias Attrs =
    { class : Supported
    , dir : Supported
    , disabled : Supported
    , id : Supported
    , inert : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , tabindex : Supported
    }


type alias Content =
    { sharedText : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | chip : Ctx }


type alias Size =
    { big : Supported
    , small : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , dir : Available
    , disabled : Available
    , id : Available
    , inert : Available
    , size : Available
    , slot : Available
    , style : Available
    , tabindex : Available
    }
