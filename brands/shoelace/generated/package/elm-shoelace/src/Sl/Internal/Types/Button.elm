module Sl.Internal.Types.Button exposing (..)

{-| Internal type definitions for Button — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | button : Brand }


type alias Attrs =
    { caret : Supported
    , circle : Supported
    , class : Supported
    , disabled : Supported
    , download : Supported
    , form : Supported
    , formenctype : Supported
    , formmethod : Supported
    , formnovalidate : Supported
    , formtarget : Supported
    , href : Supported
    , id : Supported
    , loading : Supported
    , name : Supported
    , onBlur : Supported
    , onFocus : Supported
    , onInvalid : Supported
    , outline : Supported
    , pill : Supported
    , rel : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    , title : Supported
    , type_ : Supported
    , value : Supported
    , variant : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | button : Ctx }


type alias Formenctype =
    { applicationXWwwFormUrlencoded : Supported
    , multipartFormData : Supported
    , textPlain : Supported
    }


type alias Formmethod =
    { get : Supported
    , post : Supported
    }


type alias Formtarget =
    { blank_ : Supported
    , parent_ : Supported
    , self_ : Supported
    , top_ : Supported
    }


type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


type alias Target =
    { blank_ : Supported
    , parent_ : Supported
    , self_ : Supported
    , top_ : Supported
    }


type alias Type =
    { button : Supported
    , reset : Supported
    , submit : Supported
    }


type alias Variant =
    { danger : Supported
    , default : Supported
    , neutral : Supported
    , primary : Supported
    , success : Supported
    , text : Supported
    , warning : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { caret : Available
    , circle : Available
    , class : Available
    , disabled : Available
    , download : Available
    , form : Available
    , formenctype : Available
    , formmethod : Available
    , formnovalidate : Available
    , formtarget : Available
    , href : Available
    , id : Available
    , loading : Available
    , name : Available
    , onBlur : Available
    , onFocus : Available
    , onInvalid : Available
    , outline : Available
    , pill : Available
    , rel : Available
    , size : Available
    , slot : Available
    , style : Available
    , target : Available
    , title : Available
    , type_ : Available
    , value : Available
    , variant : Available
    }
