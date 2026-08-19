module M3e.Internal.Types.OptionPanel exposing (..)

{-| Internal type definitions for OptionPanel — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | optionPanel : Brand }


type alias Attrs =
    { anchorOffset : Supported
    , class : Supported
    , fitAnchorWidth : Supported
    , id : Supported
    , onBeforetoggle : Supported
    , onToggle : Supported
    , scrollStrategy : Supported
    , slot : Supported
    , style : Supported
    }


type alias Content =
    { divider : Brand
    , optgroup : Brand
    , option : Brand
    }


type alias LoadingSlot =
    { circularProgressIndicator : Brand
    , heading : Brand
    , loadingIndicator : Brand
    , sharedText : Shared
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | optionPanel : Ctx }


type alias ScrollStrategy =
    { hide : Supported
    , reposition : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { anchorOffset : Available
    , class : Available
    , fitAnchorWidth : Available
    , id : Available
    , onBeforetoggle : Available
    , onToggle : Available
    , scrollStrategy : Available
    , slot : Available
    , style : Available
    }


type alias SlotCaps =
    { noData : Available
    }
