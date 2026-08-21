module M3e.Internal.Types.Breadcrumb exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for Breadcrumb. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Breadcrumb` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Breadcrumb (generated).
-}
type alias Is s =
    { s | breadcrumb : Brand }


{-| The `Attrs` type row for Breadcrumb (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , wrap : Supported
    }


{-| The `Content` type row for Breadcrumb (generated).
-}
type alias Content =
    { breadcrumbItem : Brand }


{-| The `ChildAdmittedBy` type row for Breadcrumb (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | breadcrumb : Ctx }


{-| The `Builder` type row for Breadcrumb (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Breadcrumb (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    , wrap : Available
    }


{-| The `SlotCaps` type row for Breadcrumb (generated).
-}
type alias SlotCaps =
    { separator : Available
    }
