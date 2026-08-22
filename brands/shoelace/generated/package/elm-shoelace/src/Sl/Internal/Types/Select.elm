module Sl.Internal.Types.Select exposing (Is, Attrs, Content, ChildAdmittedBy, Placement, Size, Builder, AttrCaps)

{-| Type definitions for Select. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Select` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Placement, Size, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Select (generated).
-}
type alias Is s =
    { s | select : Brand }


{-| The `Attrs` type row for Select (generated).
-}
type alias Attrs =
    { class : Supported
    , clearable : Supported
    , disabled : Supported
    , filled : Supported
    , form : Supported
    , gettag : Supported
    , helpText : Supported
    , hoist : Supported
    , id : Supported
    , label : Supported
    , maxOptionsVisible : Supported
    , multiple : Supported
    , name : Supported
    , onAfterHide : Supported
    , onAfterShow : Supported
    , onBlur : Supported
    , onChange : Supported
    , onClear : Supported
    , onFocus : Supported
    , onHide : Supported
    , onInput : Supported
    , onInvalid : Supported
    , onShow : Supported
    , open : Supported
    , pill : Supported
    , placeholder : Supported
    , placement : Supported
    , required : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


{-| The `Content` type row for Select (generated).
-}
type alias Content =
    { divider : Brand
    , option : Brand
    }


{-| The `ChildAdmittedBy` type row for Select (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | select : Ctx }


{-| The `Placement` type row for Select (generated).
-}
type alias Placement =
    { bottom : Supported
    , top : Supported
    }


{-| The `Size` type row for Select (generated).
-}
type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Builder` type row for Select (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Select (generated).
-}
type alias AttrCaps =
    { class : Available
    , clearable : Available
    , disabled : Available
    , filled : Available
    , form : Available
    , gettag : Available
    , helpText : Available
    , hoist : Available
    , id : Available
    , label : Available
    , maxOptionsVisible : Available
    , multiple : Available
    , name : Available
    , onAfterHide : Available
    , onAfterShow : Available
    , onBlur : Available
    , onChange : Available
    , onClear : Available
    , onFocus : Available
    , onHide : Available
    , onInput : Available
    , onInvalid : Available
    , onShow : Available
    , open : Available
    , pill : Available
    , placeholder : Available
    , placement : Available
    , required : Available
    , size : Available
    , slot : Available
    , style : Available
    , value : Available
    }
