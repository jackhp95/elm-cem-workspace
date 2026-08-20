module Sl.Internal.Types.Textarea exposing (..)

{-| Internal type definitions for Textarea — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | textarea : Brand }


type alias Attrs =
    { autocapitalize : Supported
    , autocomplete : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , disabled : Supported
    , enterkeyhint : Supported
    , filled : Supported
    , form : Supported
    , helpText : Supported
    , id : Supported
    , inputmode : Supported
    , label : Supported
    , maxlength : Supported
    , minlength : Supported
    , name : Supported
    , onBlur : Supported
    , onChange : Supported
    , onFocus : Supported
    , onInput : Supported
    , onInvalid : Supported
    , placeholder : Supported
    , readonly : Supported
    , required : Supported
    , resize : Supported
    , rows : Supported
    , size : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , title : Supported
    , value : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | textarea : Ctx }


type alias Autocapitalize =
    { characters : Supported
    , none : Supported
    , off : Supported
    , on : Supported
    , sentences : Supported
    , words : Supported
    }


type alias Enterkeyhint =
    { done : Supported
    , enter : Supported
    , go : Supported
    , next : Supported
    , previous : Supported
    , search : Supported
    , send : Supported
    }


type alias Inputmode =
    { decimal : Supported
    , email : Supported
    , none : Supported
    , numeric : Supported
    , search : Supported
    , tel : Supported
    , text : Supported
    , url : Supported
    }


type alias Resize =
    { auto : Supported
    , none : Supported
    , vertical : Supported
    }


type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { autocapitalize : Available
    , autocomplete : Available
    , autocorrect : Available
    , autofocus : Available
    , class : Available
    , disabled : Available
    , enterkeyhint : Available
    , filled : Available
    , form : Available
    , helpText : Available
    , id : Available
    , inputmode : Available
    , label : Available
    , maxlength : Available
    , minlength : Available
    , name : Available
    , onBlur : Available
    , onChange : Available
    , onFocus : Available
    , onInput : Available
    , onInvalid : Available
    , placeholder : Available
    , readonly : Available
    , required : Available
    , resize : Available
    , rows : Available
    , size : Available
    , slot : Available
    , spellcheck : Available
    , style : Available
    , title : Available
    , value : Available
    }
