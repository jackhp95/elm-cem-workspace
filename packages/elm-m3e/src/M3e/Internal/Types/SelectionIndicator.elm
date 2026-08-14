module M3e.Internal.Types.SelectionIndicator exposing (..)

{-| Internal type definitions for SelectionIndicator — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | selectionIndicator : Brand }


type alias Attrs =
    { bounce : Supported
    , centered : Supported
    , class : Supported
    , disabled : Supported
    , for : Supported
    , id : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | selectionIndicator : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { bounce : Available
    , centered : Available
    , class : Available
    , disabled : Available
    , for : Available
    , id : Available
    , selected : Available
    , slot : Available
    , style : Available
    }
