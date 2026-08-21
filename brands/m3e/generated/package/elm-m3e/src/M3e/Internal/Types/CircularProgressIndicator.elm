module M3e.Internal.Types.CircularProgressIndicator exposing (Is, Attrs, ChildAdmittedBy, Variant, Builder, AttrCaps)

{-| Type definitions for CircularProgressIndicator. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.CircularProgressIndicator` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for CircularProgressIndicator (generated).
-}
type alias Is s =
    { s | circularProgressIndicator : Brand }


{-| The `Attrs` type row for CircularProgressIndicator (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , indeterminate : Supported
    , max : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    , variant : Supported
    }


{-| The `ChildAdmittedBy` type row for CircularProgressIndicator (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | circularProgressIndicator : Ctx }


{-| The `Variant` type row for CircularProgressIndicator (generated).
-}
type alias Variant =
    { flat : Supported
    , wavy : Supported
    }


{-| The `Builder` type row for CircularProgressIndicator (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for CircularProgressIndicator (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , indeterminate : Available
    , max : Available
    , slot : Available
    , style : Available
    , value : Available
    , variant : Available
    }
