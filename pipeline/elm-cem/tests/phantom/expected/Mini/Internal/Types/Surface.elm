module Mini.Internal.Types.Surface exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Surface. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Mini` barrel and the strict
`Mini.Element.Surface` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Mini.Forge.Internal as B
import Mini.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Surface (generated).
-}
type alias Is s =
    { s | surface : Brand }


{-| The `Attrs` type row for Surface (generated).
-}
type alias Attrs =
    { class : Supported
    , dir : Supported
    , grid : Supported
    , id : Supported
    , inert : Supported
    , slot : Supported
    , style : Supported
    , tabindex : Supported
    }


{-| The `ChildAdmittedBy` type row for Surface (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | surface : Ctx }


{-| The `Builder` type row for Surface (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Surface (generated).
-}
type alias AttrCaps =
    { class : Available
    , dir : Available
    , grid : Available
    , id : Available
    , inert : Available
    , slot : Available
    , style : Available
    , tabindex : Available
    }
