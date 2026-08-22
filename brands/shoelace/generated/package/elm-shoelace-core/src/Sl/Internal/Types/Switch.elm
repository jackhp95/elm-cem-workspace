module Sl.Internal.Types.Switch exposing (Is, Attrs, Content, ChildAdmittedBy, Size, Builder, AttrCaps)

{-| Type definitions for Switch. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Switch` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Size, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Switch (generated).
-}
type alias Is s =
    { s | switch : Brand }


{-| The `Attrs` type row for Switch (generated).
-}
type alias Attrs =
    { checked : Supported
    , class : Supported
    , disabled : Supported
    , form : Supported
    , helpText : Supported
    , id : Supported
    , name : Supported
    , onBlur : Supported
    , onChange : Supported
    , onFocus : Supported
    , onInput : Supported
    , onInvalid : Supported
    , required : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , title : Supported
    , value : Supported
    }


{-| The `Content` type row for Switch (generated).
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


{-| The `ChildAdmittedBy` type row for Switch (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | switch : Ctx }


{-| The `Size` type row for Switch (generated).
-}
type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Builder` type row for Switch (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Switch (generated).
-}
type alias AttrCaps =
    { checked : Available
    , class : Available
    , disabled : Available
    , form : Available
    , helpText : Available
    , id : Available
    , name : Available
    , onBlur : Available
    , onChange : Available
    , onFocus : Available
    , onInput : Available
    , onInvalid : Available
    , required : Available
    , size : Available
    , slot : Available
    , style : Available
    , title : Available
    , value : Available
    }
