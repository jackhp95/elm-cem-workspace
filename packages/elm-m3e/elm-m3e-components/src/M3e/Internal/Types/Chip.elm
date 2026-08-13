module M3e.Internal.Types.Chip exposing (..)

{-| Internal type definitions for Chip — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B



type alias Is s =
    { s | chip : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    , variant : Supported
    }


type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


type alias IconSlot =
    { sharedIcon : Shared }


type alias TrailingIconSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | chip : Ctx }


type alias Variant =
    { elevated : Supported
    , outlined : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    , value : Available
    , variant : Available
    }


type alias SlotCaps =
    { icon : Available
    , trailingIcon : Available
    }
