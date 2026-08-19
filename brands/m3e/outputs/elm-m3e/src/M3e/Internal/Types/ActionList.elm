module M3e.Internal.Types.ActionList exposing (..)

{-| Internal type definitions for ActionList — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | actionList : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


type alias Content =
    { divider : Brand
    , expandableListItem : Brand
    , listAction : Brand
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | actionList : Ctx }


type alias Variant =
    { segmented : Supported
    , standard : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
