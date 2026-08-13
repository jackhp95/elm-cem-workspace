module M3e.Internal.Types.PseudoCheckbox exposing (..)

{-| Internal type definitions for PseudoCheckbox — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Build.Internal as B



type alias Is s =
    { s | pseudoCheckbox : Brand }


type alias Attrs =
    { checked : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , indeterminate : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | pseudoCheckbox : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { checked : Available
    , class : Available
    , disabled : Available
    , id : Available
    , indeterminate : Available
    , slot : Available
    , style : Available
    }
