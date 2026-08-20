module Sl.Internal.Types.TreeItem exposing (..)

{-| Internal type definitions for TreeItem — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | treeItem : Brand }


type alias Attrs =
    { class : Supported
    , disabled : Supported
    , expanded : Supported
    , id : Supported
    , lazy : Supported
    , onAfterCollapse : Supported
    , onAfterExpand : Supported
    , onCollapse : Supported
    , onExpand : Supported
    , onLazyChange : Supported
    , onLazyLoad : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | treeItem : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , disabled : Available
    , expanded : Available
    , id : Available
    , lazy : Available
    , onAfterCollapse : Available
    , onAfterExpand : Available
    , onCollapse : Available
    , onExpand : Available
    , onLazyChange : Available
    , onLazyLoad : Available
    , selected : Available
    , slot : Available
    , style : Available
    }
