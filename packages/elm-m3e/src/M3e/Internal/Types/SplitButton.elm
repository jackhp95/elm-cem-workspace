module M3e.Internal.Types.SplitButton exposing (..)

{-| Internal type definitions for SplitButton — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | splitButton : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


type alias LeadingButtonSlot =
    { button : Brand }


type alias TrailingButtonSlot =
    { iconButton : Brand }


type alias ChildAdmittedBy childAdm =
    { childAdm | splitButton : Ctx }


type alias Size =
    { extraLarge : Supported
    , extraSmall : Supported
    , large : Supported
    , medium : Supported
    , small : Supported
    }


type alias Variant =
    { elevated : Supported
    , filled : Supported
    , outlined : Supported
    , tonal : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , size : Available
    , slot : Available
    , style : Available
    , variant : Available
    }


type alias SlotCaps =
    { leadingButton : Available
    , trailingButton : Available
    }
