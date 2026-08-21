module M3e.Internal.Types.Tooltip exposing (Is, Attrs, Content, ChildAdmittedBy, Position, TouchGestures, Builder, AttrCaps)

{-| Type definitions for Tooltip. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Tooltip` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Position, TouchGestures, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Tooltip (generated).
-}
type alias Is s =
    { s | tooltip : Brand }


{-| The `Attrs` type row for Tooltip (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , for : Supported
    , hideDelay : Supported
    , id : Supported
    , position : Supported
    , showDelay : Supported
    , slot : Supported
    , style : Supported
    , touchGestures : Supported
    }


{-| The `Content` type row for Tooltip (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `ChildAdmittedBy` type row for Tooltip (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | tooltip : Ctx }


{-| The `Position` type row for Tooltip (generated).
-}
type alias Position =
    { above : Supported
    , after : Supported
    , before : Supported
    , below : Supported
    }


{-| The `TouchGestures` type row for Tooltip (generated).
-}
type alias TouchGestures =
    { auto : Supported
    , off : Supported
    , on : Supported
    }


{-| The `Builder` type row for Tooltip (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Tooltip (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , for : Available
    , hideDelay : Available
    , id : Available
    , position : Available
    , showDelay : Available
    , slot : Available
    , style : Available
    , touchGestures : Available
    }
