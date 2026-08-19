module M3e.Internal.Types.InputChip exposing (..)

{-| Internal type definitions for InputChip — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | inputChip : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , disabledInteractive : Supported
    , id : Supported
    , onClick : Supported
    , onRemove : Supported
    , removable : Supported
    , removeLabel : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    , variant : Supported
    }


type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


type alias AvatarSlot =
    { avatar : Brand }


type alias IconSlot =
    { sharedIcon : Shared }


type alias RemoveIconSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | inputChip : Ctx }


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
    , onClick : Available
    , onRemove : Available
    , removable : Available
    , removeLabel : Available
    , slot : Available
    , style : Available
    , value : Available
    , variant : Available
    }


type alias SlotCaps =
    { avatar : Available
    , icon : Available
    , removeIcon : Available
    }
