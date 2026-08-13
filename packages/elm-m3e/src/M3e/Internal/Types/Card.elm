module M3e.Internal.Types.Card exposing (..)

{-| Internal type definitions for Card — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | card : Brand }


type alias Attrs =
    { actionable : Supported
    , class : Supported
    , disabled : Supported
    , disabledInteractive : Supported
    , download : Supported
    , href : Supported
    , id : Supported
    , inline : Supported
    , name : Supported
    , onClick : Supported
    , orientation : Supported
    , rel : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    , type_ : Supported
    , value : Supported
    , variant : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | card : Ctx }


type alias Orientation =
    { horizontal : Supported
    , vertical : Supported
    }


type alias Type =
    { button : Supported
    , reset : Supported
    , submit : Supported
    }


type alias Variant =
    { elevated : Supported
    , filled : Supported
    , outlined : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { actionable : Available
    , class : Available
    , disabled : Available
    , disabledInteractive : Available
    , download : Available
    , href : Available
    , id : Available
    , inline : Available
    , name : Available
    , onClick : Available
    , orientation : Available
    , rel : Available
    , slot : Available
    , style : Available
    , target : Available
    , type_ : Available
    , value : Available
    , variant : Available
    }


type alias SlotCaps =
    { actions : Available
    , content : Available
    , footer : Available
    , header : Available
    }
