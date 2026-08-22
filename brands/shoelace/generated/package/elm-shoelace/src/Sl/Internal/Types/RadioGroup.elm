module Sl.Internal.Types.RadioGroup exposing (Is, Attrs, Content, ChildAdmittedBy, Size, Builder, AttrCaps)

{-| Type definitions for RadioGroup. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.RadioGroup` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Size, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for RadioGroup (generated).
-}
type alias Is s =
    { s | radioGroup : Brand }


{-| The `Attrs` type row for RadioGroup (generated).
-}
type alias Attrs =
    { class : Supported
    , form : Supported
    , helpText : Supported
    , id : Supported
    , label : Supported
    , name : Supported
    , onChange : Supported
    , onInput : Supported
    , onInvalid : Supported
    , required : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


{-| The `Content` type row for RadioGroup (generated).
-}
type alias Content =
    { radio : Brand
    , radioButton : Brand
    }


{-| The `ChildAdmittedBy` type row for RadioGroup (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | radioGroup : Ctx }


{-| The `Size` type row for RadioGroup (generated).
-}
type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Builder` type row for RadioGroup (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for RadioGroup (generated).
-}
type alias AttrCaps =
    { class : Available
    , form : Available
    , helpText : Available
    , id : Available
    , label : Available
    , name : Available
    , onChange : Available
    , onInput : Available
    , onInvalid : Available
    , required : Available
    , size : Available
    , slot : Available
    , style : Available
    , value : Available
    }
