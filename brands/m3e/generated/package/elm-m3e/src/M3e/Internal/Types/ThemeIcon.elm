module M3e.Internal.Types.ThemeIcon exposing (..)

{-| Internal type definitions for ThemeIcon — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | themeIcon : Brand }


type alias Attrs =
    { class : Supported
    , color : Supported
    , id : Supported
    , scheme : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | themeIcon : Ctx }


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
    , id : Available
    , scheme : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
