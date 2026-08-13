module M3e.Internal.Types.RadioGroup exposing (..)

{-| Internal type definitions for RadioGroup — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | radioGroup : Brand }


type alias Attrs =
    { ariaInvalid : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onInput : Supported
    , required : Supported
    , slot : Supported
    , style : Supported
    , validationmessages : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | radioGroup : Ctx }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { ariaInvalid : Available
    , class : Available
    , disabled : Available
    , id : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onInput : Available
    , required : Available
    , slot : Available
    , style : Available
    , validationmessages : Available
    }
