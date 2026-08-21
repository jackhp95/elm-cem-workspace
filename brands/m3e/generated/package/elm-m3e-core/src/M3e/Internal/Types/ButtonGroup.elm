module M3e.Internal.Types.ButtonGroup exposing (Is, Attrs, Content, ChildAdmittedBy, Size, Variant, Builder, AttrCaps)

{-| Type definitions for ButtonGroup. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.ButtonGroup` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Size, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ButtonGroup (generated).
-}
type alias Is s =
    { s | buttonGroup : Brand }


{-| The `Attrs` type row for ButtonGroup (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , multi : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


{-| The `Content` type row for ButtonGroup (generated).
-}
type alias Content =
    { button : Brand
    , iconButton : Brand
    }


{-| The `ChildAdmittedBy` type row for ButtonGroup (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | buttonGroup : Ctx }


{-| The `Size` type row for ButtonGroup (generated).
-}
type alias Size =
    { extraLarge : Supported
    , extraSmall : Supported
    , large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Variant` type row for ButtonGroup (generated).
-}
type alias Variant =
    { connected : Supported
    , standard : Supported
    }


{-| The `Builder` type row for ButtonGroup (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ButtonGroup (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , multi : Available
    , size : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
