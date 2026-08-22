module Sl.Internal.Types.IconButton exposing (Is, Attrs, ChildAdmittedBy, Target, Builder, AttrCaps)

{-| Type definitions for IconButton. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.IconButton` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Target, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for IconButton (generated).
-}
type alias Is s =
    { s | iconButton : Brand }


{-| The `Attrs` type row for IconButton (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , download : Supported
    , href : Supported
    , id : Supported
    , label : Supported
    , library : Supported
    , name : Supported
    , onBlur : Supported
    , onFocus : Supported
    , slot : Supported
    , src : Supported
    , style : Supported
    , target : Supported
    }


{-| The `ChildAdmittedBy` type row for IconButton (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | iconButton : Ctx }


{-| The `Target` type row for IconButton (generated).
-}
type alias Target =
    { blank_ : Supported
    , parent_ : Supported
    , self_ : Supported
    , top_ : Supported
    }


{-| The `Builder` type row for IconButton (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for IconButton (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , download : Available
    , href : Available
    , id : Available
    , label : Available
    , library : Available
    , name : Available
    , onBlur : Available
    , onFocus : Available
    , slot : Available
    , src : Available
    , style : Available
    , target : Available
    }
