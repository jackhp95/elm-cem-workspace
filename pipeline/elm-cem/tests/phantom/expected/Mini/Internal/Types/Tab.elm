module Mini.Internal.Types.Tab exposing (Is, Attrs, Content, ChildAdmittedBy, AdmittedBy, Builder, AttrCaps)

{-| Type definitions for Tab. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Mini` barrel and the strict
`Mini.Element.Tab` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, AdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Mini.Forge.Internal as B
import Mini.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Tab (generated).
-}
type alias Is s =
    { s | tab : Brand }


{-| The `Attrs` type row for Tab (generated).
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


{-| The `Content` type row for Tab (generated).
-}
type alias Content =
    { sharedText : Shared }


{-| The `ChildAdmittedBy` type row for Tab (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | tab : Ctx }


{-| The `AdmittedBy` type row for Tab (generated).
-}
type alias AdmittedBy =
    { tabs : Ctx }


{-| The `Builder` type row for Tab (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Tab (generated).
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
