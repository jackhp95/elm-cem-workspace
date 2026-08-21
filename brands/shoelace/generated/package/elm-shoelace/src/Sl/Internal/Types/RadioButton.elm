module Sl.Internal.Types.RadioButton exposing (Is, Attrs, ChildAdmittedBy, Size, Builder, AttrCaps)

{-| Type definitions for RadioButton. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.RadioButton` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Size, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for RadioButton (generated).
-}
type alias Is s =
    { s | radioButton : Brand }


{-| The `Attrs` type row for RadioButton (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , onBlur : Supported
    , onFocus : Supported
    , pill : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


{-| The `ChildAdmittedBy` type row for RadioButton (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | radioButton : Ctx }


{-| The `Size` type row for RadioButton (generated).
-}
type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Builder` type row for RadioButton (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for RadioButton (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , onBlur : Available
    , onFocus : Available
    , pill : Available
    , size : Available
    , slot : Available
    , style : Available
    , value : Available
    }
