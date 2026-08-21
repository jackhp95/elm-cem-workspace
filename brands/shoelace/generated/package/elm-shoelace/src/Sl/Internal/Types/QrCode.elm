module Sl.Internal.Types.QrCode exposing (Is, Attrs, ChildAdmittedBy, ErrorCorrection, Builder, AttrCaps)

{-| Type definitions for QrCode. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.QrCode` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, ErrorCorrection, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for QrCode (generated).
-}
type alias Is s =
    { s | qrCode : Brand }


{-| The `Attrs` type row for QrCode (generated).
-}
type alias Attrs =
    { background : Supported
    , class : Supported
    , errorCorrection : Supported
    , fill : Supported
    , id : Supported
    , label : Supported
    , radius : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


{-| The `ChildAdmittedBy` type row for QrCode (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | qrCode : Ctx }


{-| The `ErrorCorrection` type row for QrCode (generated).
-}
type alias ErrorCorrection =
    { h : Supported
    , l : Supported
    , m : Supported
    , q : Supported
    }


{-| The `Builder` type row for QrCode (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for QrCode (generated).
-}
type alias AttrCaps =
    { background : Available
    , class : Available
    , errorCorrection : Available
    , fill : Available
    , id : Available
    , label : Available
    , radius : Available
    , size : Available
    , slot : Available
    , style : Available
    , value : Available
    }
