module M3e.Internal.Types.List exposing (Is, Attrs, Content, ChildAdmittedBy, Variant, Builder, AttrCaps)

{-| Type definitions for List. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.List` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for List (generated).
-}
type alias Is s =
    { s | list : Brand }


{-| The `Attrs` type row for List (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


{-| The `Content` type row for List (generated).
-}
type alias Content =
    { divider : Brand
    , expandableListItem : Brand
    , listAction : Brand
    , listItem : Brand
    , listOption : Brand
    }


{-| The `ChildAdmittedBy` type row for List (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | list : Ctx }


{-| The `Variant` type row for List (generated).
-}
type alias Variant =
    { segmented : Supported
    , standard : Supported
    }


{-| The `Builder` type row for List (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for List (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
