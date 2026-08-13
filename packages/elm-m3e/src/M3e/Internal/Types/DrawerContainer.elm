module M3e.Internal.Types.DrawerContainer exposing (..)

{-| Internal type definitions for DrawerContainer — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | drawerContainer : Brand }


type alias Attrs =
    { class : Supported
    , end : Supported
    , endDivider : Supported
    , endMode : Supported
    , id : Supported
    , onChange : Supported
    , slot : Supported
    , start : Supported
    , startDivider : Supported
    , startMode : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | drawerContainer : Ctx }


type alias EndMode =
    { auto : Supported
    , over : Supported
    , push : Supported
    , side : Supported
    }


type alias StartMode =
    { auto : Supported
    , over : Supported
    , push : Supported
    , side : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , end : Available
    , endDivider : Available
    , endMode : Available
    , id : Available
    , onChange : Available
    , slot : Available
    , start : Available
    , startDivider : Available
    , startMode : Available
    , style : Available
    }


type alias SlotCaps =
    { end : Available
    , start : Available
    }
