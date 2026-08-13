module M3e.Internal.Types.BottomSheet exposing (..)

{-| Internal type definitions for BottomSheet — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | bottomSheet : Brand }


type alias Attrs =
    { class : Supported
    , detent : Supported
    , detents : Supported
    , handle : Supported
    , handleLabel : Supported
    , hideFriction : Supported
    , hideable : Supported
    , id : Supported
    , modal : Supported
    , onCancel : Supported
    , onClosed : Supported
    , onClosing : Supported
    , onOpened : Supported
    , onOpening : Supported
    , open : Supported
    , overshootLimit : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | bottomSheet : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , detent : Available
    , detents : Available
    , handle : Available
    , handleLabel : Available
    , hideFriction : Available
    , hideable : Available
    , id : Available
    , modal : Available
    , onCancel : Available
    , onClosed : Available
    , onClosing : Available
    , onOpened : Available
    , onOpening : Available
    , open : Available
    , overshootLimit : Available
    , slot : Available
    , style : Available
    }


type alias SlotCaps =
    { header : Available
    }
