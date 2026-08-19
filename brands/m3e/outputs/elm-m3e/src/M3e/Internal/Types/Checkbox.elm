module M3e.Internal.Types.Checkbox exposing (..)

{-| Internal type definitions for Checkbox — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | checkbox : Brand }


type alias Attrs =
    { checked : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , indeterminate : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , onInvalid : Supported
    , required : Supported
    , slot : Supported
    , style : Supported
    , validationmessages : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | checkbox : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { checked : Available
    , class : Available
    , disabled : Available
    , id : Available
    , indeterminate : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , onInvalid : Available
    , required : Available
    , slot : Available
    , style : Available
    , validationmessages : Available
    , value : Available
    }
