module Mini.Internal.Types.Button exposing (..)

{-| Internal type definitions for Button — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Mini.Forge.Internal as B
import Mini.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | button : Brand }


type alias Attrs =
    { class : Supported
    , dir : Supported
    , disabled : Supported
    , id : Supported
    , inert : Supported
    , onClick : Supported
    , slot : Supported
    , style : Supported
    , tabindex : Supported
    , variant : Supported
    , weight : Supported
    }


type alias Content =
    { sharedIcon : Shared
    , sharedText : Shared
    }


type alias IconSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | button : Ctx }


type alias Variant =
    { filled : Supported
    , tonal : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , dir : Available
    , disabled : Available
    , id : Available
    , inert : Available
    , onClick : Available
    , slot : Available
    , style : Available
    , tabindex : Available
    , variant : Available
    , weight : Available
    }


type alias SlotCaps =
    { icon : Available
    }
