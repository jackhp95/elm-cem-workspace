module M3e.Internal.Types.TextareaAutosize exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for TextareaAutosize. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.TextareaAutosize` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for TextareaAutosize (generated).
-}
type alias Is s =
    { s | textareaAutosize : Brand }


{-| The `Attrs` type row for TextareaAutosize (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , for : Supported
    , id : Supported
    , maxRows : Supported
    , minRows : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for TextareaAutosize (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | textareaAutosize : Ctx }


{-| The `Builder` type row for TextareaAutosize (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for TextareaAutosize (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , for : Available
    , id : Available
    , maxRows : Available
    , minRows : Available
    , slot : Available
    , style : Available
    }
