module M3e.Internal.Types.Theme exposing (..)

{-| Internal type definitions for Theme — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B



type alias Is s =
    { s | theme : Brand }


type alias Attrs =
    { class : Supported
    , color : Supported
    , contrast : Supported
    , density : Supported
    , id : Supported
    , motion : Supported
    , onChange : Supported
    , scheme : Supported
    , slot : Supported
    , strongFocus : Supported
    , style : Supported
    , variant : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | theme : Ctx }


type alias Contrast =
    { high : Supported
    , medium : Supported
    , standard : Supported
    }


type alias Motion =
    { expressive : Supported
    , standard : Supported
    }


type alias Scheme =
    { auto : Supported
    , dark : Supported
    , light : Supported
    }


type alias Variant =
    { content : Supported
    , expressive : Supported
    , fidelity : Supported
    , fruitSalad : Supported
    , monochrome : Supported
    , neutral : Supported
    , rainbow : Supported
    , tonalSpot : Supported
    , vibrant : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , color : Available
    , contrast : Available
    , density : Available
    , id : Available
    , motion : Available
    , onChange : Available
    , scheme : Available
    , slot : Available
    , strongFocus : Available
    , style : Available
    , variant : Available
    }
