module M3e.Internal.Types.Badge exposing (Is, Attrs, Content, ChildAdmittedBy, Position, Size, Builder, AttrCaps)

{-| Type definitions for Badge. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Badge` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Position, Size, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Badge (generated).
-}
type alias Is s =
    { s | badge : Brand }


{-| The `Attrs` type row for Badge (generated).
-}
type alias Attrs =
    { class : Supported
    , for : Supported
    , id : Supported
    , position : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for Badge (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `ChildAdmittedBy` type row for Badge (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | badge : Ctx }


{-| The `Position` type row for Badge (generated).
-}
type alias Position =
    { above : Supported
    , aboveAfter : Supported
    , aboveBefore : Supported
    , after : Supported
    , before : Supported
    , below : Supported
    , belowAfter : Supported
    , belowBefore : Supported
    }


{-| The `Size` type row for Badge (generated).
-}
type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Builder` type row for Badge (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Badge (generated).
-}
type alias AttrCaps =
    { class : Available
    , for : Available
    , id : Available
    , position : Available
    , size : Available
    , slot : Available
    , style : Available
    }
