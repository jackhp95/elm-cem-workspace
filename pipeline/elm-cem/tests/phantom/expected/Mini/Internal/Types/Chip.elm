module Mini.Internal.Types.Chip exposing (Is, Attrs, Content, ChildAdmittedBy, Size, Builder, AttrCaps)

{-| Type definitions for Chip. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Mini` barrel and the strict
`Mini.Element.Chip` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Size, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Mini.Forge.Internal as B
import Mini.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Chip (generated).
-}
type alias Is s =
    { s | chip : Brand }


{-| The `Attrs` type row for Chip (generated).
-}
type alias Attrs =
    { class : Supported
    , dir : Supported
    , disabled : Supported
    , id : Supported
    , inert : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , tabindex : Supported
    }


{-| The `Content` type row for Chip (generated).
-}
type alias Content =
    { sharedText : Shared }


{-| The `ChildAdmittedBy` type row for Chip (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | chip : Ctx }


{-| The `Size` type row for Chip (generated).
-}
type alias Size =
    { big : Supported
    , small : Supported
    }


{-| The `Builder` type row for Chip (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Chip (generated).
-}
type alias AttrCaps =
    { class : Available
    , dir : Available
    , disabled : Available
    , id : Available
    , inert : Available
    , size : Available
    , slot : Available
    , style : Available
    , tabindex : Available
    }
