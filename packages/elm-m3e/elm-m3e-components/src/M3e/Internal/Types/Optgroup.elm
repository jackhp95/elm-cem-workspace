module M3e.Internal.Types.Optgroup exposing (..)

{-| Internal type definitions for Optgroup — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | optgroup : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


type alias Content =
    { option : Brand }


type alias LabelSlot =
    { heading : Brand
    , sharedText : Shared
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | optgroup : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    }


type alias SlotCaps =
    { label : Available
    }
