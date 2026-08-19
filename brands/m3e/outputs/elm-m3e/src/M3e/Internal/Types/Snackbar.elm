module M3e.Internal.Types.Snackbar exposing (..)

{-| Internal type definitions for Snackbar — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | snackbar : Brand }


type alias Attrs =
    { action : Supported
    , class : Supported
    , closeLabel : Supported
    , dismissible : Supported
    , duration : Supported
    , id : Supported
    , onBeforetoggle : Supported
    , onToggle : Supported
    , open : Supported
    , slot : Supported
    , style : Supported
    }


type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


type alias CloseIconSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | snackbar : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { action : Available
    , class : Available
    , closeLabel : Available
    , dismissible : Available
    , duration : Available
    , id : Available
    , onBeforetoggle : Available
    , onToggle : Available
    , open : Available
    , slot : Available
    , style : Available
    }


type alias SlotCaps =
    { closeIcon : Available
    }
