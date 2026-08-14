module M3e.Internal.Types.Dialog exposing (..)

{-| Internal type definitions for Dialog — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | dialog : Brand }


type alias Attrs =
    { alert : Supported
    , class : Supported
    , closeLabel : Supported
    , disableClose : Supported
    , dismissible : Supported
    , id : Supported
    , noFocusTrap : Supported
    , onCancel : Supported
    , onClosed : Supported
    , onClosing : Supported
    , onOpened : Supported
    , onOpening : Supported
    , open : Supported
    , slot : Supported
    , style : Supported
    }


type alias CloseIconSlot =
    { sharedIcon : Shared }


type alias HeaderSlot =
    { heading : Brand
    , sharedText : Shared
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | dialog : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { alert : Available
    , class : Available
    , closeLabel : Available
    , disableClose : Available
    , dismissible : Available
    , id : Available
    , noFocusTrap : Available
    , onCancel : Available
    , onClosed : Available
    , onClosing : Available
    , onOpened : Available
    , onOpening : Available
    , open : Available
    , slot : Available
    , style : Available
    }


type alias SlotCaps =
    { actions : Available
    , closeIcon : Available
    , header : Available
    }
