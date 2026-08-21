module M3e.Internal.Types.LoadingIndicator exposing (Is, Attrs, ChildAdmittedBy, Variant, Builder, AttrCaps)

{-| Type definitions for LoadingIndicator. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.LoadingIndicator` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for LoadingIndicator (generated).
-}
type alias Is s =
    { s | loadingIndicator : Brand }


{-| The `Attrs` type row for LoadingIndicator (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


{-| The `ChildAdmittedBy` type row for LoadingIndicator (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | loadingIndicator : Ctx }


{-| The `Variant` type row for LoadingIndicator (generated).
-}
type alias Variant =
    { contained : Supported
    , uncontained : Supported
    }


{-| The `Builder` type row for LoadingIndicator (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for LoadingIndicator (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
