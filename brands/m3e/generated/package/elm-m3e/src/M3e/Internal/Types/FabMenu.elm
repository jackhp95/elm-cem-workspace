module M3e.Internal.Types.FabMenu exposing (Is, Attrs, Content, ChildAdmittedBy, Variant, Builder, AttrCaps)

{-| Type definitions for FabMenu. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.FabMenu` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for FabMenu (generated).
-}
type alias Is s =
    { s | fabMenu : Brand }


{-| The `Attrs` type row for FabMenu (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , onBeforetoggle : Supported
    , onToggle : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


{-| The `Content` type row for FabMenu (generated).
-}
type alias Content =
    { fabMenuItem : Brand
    , menuItem : Brand
    }


{-| The `ChildAdmittedBy` type row for FabMenu (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | fabMenu : Ctx }


{-| The `Variant` type row for FabMenu (generated).
-}
type alias Variant =
    { primary : Supported
    , secondary : Supported
    , tertiary : Supported
    }


{-| The `Builder` type row for FabMenu (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for FabMenu (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , onBeforetoggle : Available
    , onToggle : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
