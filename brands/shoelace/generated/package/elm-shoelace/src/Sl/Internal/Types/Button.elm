module Sl.Internal.Types.Button exposing (Is, Attrs, Content, ChildAdmittedBy, Formenctype, Formmethod, Formtarget, Size, Target, Type, Variant, Builder, AttrCaps)

{-| Type definitions for Button. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Button` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Formenctype, Formmethod, Formtarget, Size, Target, Type, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Button (generated).
-}
type alias Is s =
    { s | button : Brand }


{-| The `Attrs` type row for Button (generated).
-}
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


{-| The `Content` type row for Button (generated).
-}
type alias Content =
    { avatar : Brand
    , badge : Brand
    , formatBytes : Brand
    , formatDate : Brand
    , formatNumber : Brand
    , icon : Brand
    , relativeTime : Brand
    , sharedText : Shared
    , spinner : Brand
    , tag : Brand
    , visuallyHidden : Brand
    }


{-| The `ChildAdmittedBy` type row for Button (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | button : Ctx }


{-| The `Formenctype` type row for Button (generated).
-}
type alias Formenctype =
    { applicationXWwwFormUrlencoded : Supported
    , multipartFormData : Supported
    , textPlain : Supported
    }


{-| The `Formmethod` type row for Button (generated).
-}
type alias Formmethod =
    { get : Supported
    , post : Supported
    }


{-| The `Formtarget` type row for Button (generated).
-}
type alias Formtarget =
    { blank_ : Supported
    , parent_ : Supported
    , self_ : Supported
    , top_ : Supported
    }


{-| The `Size` type row for Button (generated).
-}
type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Target` type row for Button (generated).
-}
type alias Target =
    { blank_ : Supported
    , parent_ : Supported
    , self_ : Supported
    , top_ : Supported
    }


{-| The `Type` type row for Button (generated).
-}
type alias Type =
    { button : Supported
    , reset : Supported
    , submit : Supported
    }


{-| The `Variant` type row for Button (generated).
-}
type alias Variant =
    { danger : Supported
    , default : Supported
    , neutral : Supported
    , primary : Supported
    , success : Supported
    , text : Supported
    , warning : Supported
    }


{-| The `Builder` type row for Button (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Button (generated).
-}
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
