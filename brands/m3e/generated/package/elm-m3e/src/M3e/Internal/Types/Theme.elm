module M3e.Internal.Types.Theme exposing (Is, Attrs, ChildAdmittedBy, Contrast, Motion, Scheme, Variant, Builder, AttrCaps)

{-| Type definitions for Theme. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Theme` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Contrast, Motion, Scheme, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Theme (generated).
-}
type alias Is s =
    { s | theme : Brand }


{-| The `Attrs` type row for Theme (generated).
-}
type alias Attrs =
    { class : Supported
    , color : Supported
    , contrast : Supported
    , density : Supported
    , id : Supported
    , motion : Supported
    , onChange : Supported
    , scheme : Supported
    , slot : Supported
    , strongFocus : Supported
    , style : Supported
    , variant : Supported
    }


{-| The `ChildAdmittedBy` type row for Theme (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | theme : Ctx }


{-| The `Contrast` type row for Theme (generated).
-}
type alias Contrast =
    { high : Supported
    , medium : Supported
    , standard : Supported
    }


{-| The `Motion` type row for Theme (generated).
-}
type alias Motion =
    { expressive : Supported
    , standard : Supported
    }


{-| The `Scheme` type row for Theme (generated).
-}
type alias Scheme =
    { auto : Supported
    , dark : Supported
    , light : Supported
    }


{-| The `Variant` type row for Theme (generated).
-}
type alias Variant =
    { content : Supported
    , expressive : Supported
    , fidelity : Supported
    , fruitSalad : Supported
    , monochrome : Supported
    , neutral : Supported
    , rainbow : Supported
    , tonalSpot : Supported
    , vibrant : Supported
    }


{-| The `Builder` type row for Theme (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Theme (generated).
-}
type alias AttrCaps =
    { class : Available
    , color : Available
    , contrast : Available
    , density : Available
    , id : Available
    , motion : Available
    , onChange : Available
    , scheme : Available
    , slot : Available
    , strongFocus : Available
    , style : Available
    , variant : Available
    }
