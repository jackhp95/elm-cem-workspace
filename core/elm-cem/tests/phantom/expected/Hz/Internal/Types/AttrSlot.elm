module Hz.Internal.Types.AttrSlot exposing (..)

{-| Internal type definitions for AttrSlot — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Hz.Forge.Internal as B
import Hz.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | attrSlot : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , withHint : Supported
    , withLabel : Supported
    }


type alias HintSlot =
    {}


type alias LabelSlot =
    {}


type alias ChildAdmittedBy childAdm =
    { childAdm | attrSlot : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    , withHint : Available
    , withLabel : Available
    }


type alias SlotCaps =
    { hint : Available
    , label : Available
    }
