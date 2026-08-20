module Sl.Internal.Types.VisuallyHidden exposing (..)

{-| Internal type definitions for VisuallyHidden — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | visuallyHidden : Brand }


type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | visuallyHidden : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    }
