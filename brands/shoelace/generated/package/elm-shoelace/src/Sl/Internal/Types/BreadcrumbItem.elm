module Sl.Internal.Types.BreadcrumbItem exposing (..)

{-| Internal type definitions for BreadcrumbItem — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | breadcrumbItem : Brand }


type alias Attrs =
    { class : Supported
    , href : Supported
    , id : Supported
    , rel : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | breadcrumbItem : Ctx }


type alias Target =
    { blank_ : Supported
    , parent_ : Supported
    , self_ : Supported
    , top_ : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , href : Available
    , id : Available
    , rel : Available
    , slot : Available
    , style : Available
    , target : Available
    }
