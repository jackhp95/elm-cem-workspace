module M3e.Internal.Types.TextHighlight exposing (..)

{-| Internal type definitions for TextHighlight — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | textHighlight : Brand }


type alias Attrs =
    { caseSensitive : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , mode : Supported
    , onHighlight : Supported
    , slot : Supported
    , style : Supported
    , term : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | textHighlight : Ctx }


type alias Mode =
    { contains : Supported
    , endsWith : Supported
    , startsWith : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { caseSensitive : Available
    , class : Available
    , disabled : Available
    , id : Available
    , mode : Available
    , onHighlight : Available
    , slot : Available
    , style : Available
    , term : Available
    }
