module Sl.Internal.Types.ButtonGroup exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for ButtonGroup. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.ButtonGroup` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ButtonGroup (generated).
-}
type alias Is s =
    { s | buttonGroup : Brand }


{-| The `Attrs` type row for ButtonGroup (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , label : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for ButtonGroup (generated).
-}
type alias Content =
    { button : Brand
    , dropdown : Brand
    , iconButton : Brand
    , radioButton : Brand
    , tooltip : Brand
    }


{-| The `ChildAdmittedBy` type row for ButtonGroup (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | buttonGroup : Ctx }


{-| The `Builder` type row for ButtonGroup (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ButtonGroup (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , label : Available
    , slot : Available
    , style : Available
    }
