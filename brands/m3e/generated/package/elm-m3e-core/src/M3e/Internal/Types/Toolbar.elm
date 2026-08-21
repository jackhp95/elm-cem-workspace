module M3e.Internal.Types.Toolbar exposing (Is, Attrs, ChildAdmittedBy, Shape, Variant, Builder, AttrCaps)

{-| Type definitions for Toolbar. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Toolbar` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Shape, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Toolbar (generated).
-}
type alias Is s =
    { s | toolbar : Brand }


{-| The `Attrs` type row for Toolbar (generated).
-}
type alias Attrs =
    { class : Supported
    , elevated : Supported
    , id : Supported
    , shape : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    , vertical : Supported
    }


{-| The `ChildAdmittedBy` type row for Toolbar (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | toolbar : Ctx }


{-| The `Shape` type row for Toolbar (generated).
-}
type alias Shape =
    { rounded : Supported
    , square : Supported
    }


{-| The `Variant` type row for Toolbar (generated).
-}
type alias Variant =
    { standard : Supported
    , vibrant : Supported
    }


{-| The `Builder` type row for Toolbar (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Toolbar (generated).
-}
type alias AttrCaps =
    { class : Available
    , elevated : Available
    , id : Available
    , shape : Available
    , slot : Available
    , style : Available
    , variant : Available
    , vertical : Available
    }
