module M3e.Internal.Types.FilterChip exposing (..)

{-| Internal type definitions for FilterChip — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | filterChip : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , disabledInteractive : Supported
    , id : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , selected : Supported
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
    { childAdm | filterChip : Ctx }


type alias Variant =
    { elevated : Supported
    , outlined : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , disabledInteractive : Available
    , id : Available
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , selected : Available
    , slot : Available
    , style : Available
    , value : Available
    , variant : Available
    }


type alias SlotCaps =
    { icon : Available
    , trailingIcon : Available
    }
