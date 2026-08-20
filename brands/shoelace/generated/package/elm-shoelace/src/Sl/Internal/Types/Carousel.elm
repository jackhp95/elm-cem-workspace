module Sl.Internal.Types.Carousel exposing (..)

{-| Internal type definitions for Carousel — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | carousel : Brand }


type alias Attrs =
    { autoplay : Supported
    , autoplayInterval : Supported
    , class : Supported
    , id : Supported
    , loop : Supported
    , mouseDragging : Supported
    , navigation : Supported
    , onSlideChange : Supported
    , orientation : Supported
    , pagination : Supported
    , slidesPerMove : Supported
    , slidesPerPage : Supported
    , slot : Supported
    , style : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | carousel : Ctx }


type alias Orientation =
    { horizontal : Supported
    , vertical : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { autoplay : Available
    , autoplayInterval : Available
    , class : Available
    , id : Available
    , loop : Available
    , mouseDragging : Available
    , navigation : Available
    , onSlideChange : Available
    , orientation : Available
    , pagination : Available
    , slidesPerMove : Available
    , slidesPerPage : Available
    , slot : Available
    , style : Available
    }
