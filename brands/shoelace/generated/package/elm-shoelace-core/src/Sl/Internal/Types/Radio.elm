module Sl.Internal.Types.Radio exposing (Is, Attrs, ChildAdmittedBy, Size, Builder, AttrCaps)

{-| Type definitions for Radio. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Radio` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Size, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Radio (generated).
-}
type alias Is s =
    { s | radio : Brand }


{-| The `Attrs` type row for Radio (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , onBlur : Supported
    , onFocus : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


{-| The `ChildAdmittedBy` type row for Radio (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | radio : Ctx }


{-| The `Size` type row for Radio (generated).
-}
type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Builder` type row for Radio (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Radio (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , onBlur : Available
    , onFocus : Available
    , size : Available
    , slot : Available
    , style : Available
    , value : Available
    }
