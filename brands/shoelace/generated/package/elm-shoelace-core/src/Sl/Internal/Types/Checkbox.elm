module Sl.Internal.Types.Checkbox exposing (Is, Attrs, ChildAdmittedBy, Size, Builder, AttrCaps)

{-| Type definitions for Checkbox. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Checkbox` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Size, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Checkbox (generated).
-}
type alias Is s =
    { s | checkbox : Brand }


{-| The `Attrs` type row for Checkbox (generated).
-}
type alias Attrs =
    { checked : Supported
    , class : Supported
    , disabled : Supported
    , form : Supported
    , helpText : Supported
    , id : Supported
    , indeterminate : Supported
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


{-| The `ChildAdmittedBy` type row for Checkbox (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | checkbox : Ctx }


{-| The `Size` type row for Checkbox (generated).
-}
type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Builder` type row for Checkbox (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Checkbox (generated).
-}
type alias AttrCaps =
    { checked : Available
    , class : Available
    , disabled : Available
    , form : Available
    , helpText : Available
    , id : Available
    , indeterminate : Available
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
