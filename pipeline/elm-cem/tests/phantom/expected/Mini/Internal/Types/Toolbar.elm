module Mini.Internal.Types.Toolbar exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Toolbar. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Mini` barrel and the strict
`Mini.Element.Toolbar` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Mini.Forge.Internal as B
import Mini.Kind exposing (Actions, Available, Brand, Ctx, Used)


{-| The `Is` type row for Toolbar (generated).
-}
type alias Is s =
    { s | toolbar : Brand }


{-| The `Attrs` type row for Toolbar (generated).
-}
type alias Attrs =
    { class : Supported
    , dir : Supported
    , id : Supported
    , inert : Supported
    , slot : Supported
    , style : Supported
    , tabindex : Supported
    }


{-| The `ChildAdmittedBy` type row for Toolbar (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | toolbar : Ctx }


{-| The `Builder` type row for Toolbar (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Toolbar (generated).
-}
type alias AttrCaps =
    { class : Available
    , dir : Available
    , id : Available
    , inert : Available
    , slot : Available
    , style : Available
    , tabindex : Available
    }
