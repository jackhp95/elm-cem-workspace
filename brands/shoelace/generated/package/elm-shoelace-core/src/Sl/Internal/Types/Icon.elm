module Sl.Internal.Types.Icon exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Icon. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Icon` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Icon (generated).
-}
type alias Is s =
    { s | icon : Brand }


{-| The `Attrs` type row for Icon (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , label : Supported
    , library : Supported
    , name : Supported
    , onError : Supported
    , onLoad : Supported
    , slot : Supported
    , src : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Icon (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | icon : Ctx }


{-| The `Builder` type row for Icon (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Icon (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , label : Available
    , library : Available
    , name : Available
    , onError : Available
    , onLoad : Available
    , slot : Available
    , src : Available
    , style : Available
    }
