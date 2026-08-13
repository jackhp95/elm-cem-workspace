module M3e.Internal.Types.List exposing (..)

{-| Internal type definitions for List — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | list : Brand }


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
    , listItem : Brand
    , listOption : Brand
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | list : Ctx }


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
