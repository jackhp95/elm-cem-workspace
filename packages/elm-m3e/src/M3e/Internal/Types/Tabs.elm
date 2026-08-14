module M3e.Internal.Types.Tabs exposing (..)

{-| Internal type definitions for Tabs — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | tabs : Brand }


type alias Attrs =
    { class : Supported
    , disablePagination : Supported
    , headerPosition : Supported
    , id : Supported
    , nextPageLabel : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onInput : Supported
    , previousPageLabel : Supported
    , slot : Supported
    , stretch : Supported
    , style : Supported
    , variant : Supported
    }


type alias Content =
    { tab : Brand }


type alias NextIconSlot =
    { sharedIcon : Shared }


type alias PanelSlot =
    { tabPanel : Brand }


type alias PrevIconSlot =
    { sharedIcon : Shared }


type alias ChildAdmittedBy childAdm =
    { childAdm | tabs : Ctx }


type alias DisablePagination =
    { auto : Supported
    , false : Supported
    , true : Supported
    }


type alias HeaderPosition =
    { after : Supported
    , before : Supported
    }


type alias Variant =
    { primary : Supported
    , secondary : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disablePagination : Available
    , headerPosition : Available
    , id : Available
    , nextPageLabel : Available
    , onBeforeinput : Available
    , onChange : Available
    , onInput : Available
    , previousPageLabel : Available
    , slot : Available
    , stretch : Available
    , style : Available
    , variant : Available
    }


type alias SlotCaps =
    { nextIcon : Available
    , prevIcon : Available
    }
