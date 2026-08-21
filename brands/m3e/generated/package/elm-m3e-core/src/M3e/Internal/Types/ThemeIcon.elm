module M3e.Internal.Types.ThemeIcon exposing (Is, Attrs, ChildAdmittedBy, Scheme, Variant, Builder, AttrCaps)

{-| Type definitions for ThemeIcon. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.ThemeIcon` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Scheme, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ThemeIcon (generated).
-}
type alias Is s =
    { s | themeIcon : Brand }


{-| The `Attrs` type row for ThemeIcon (generated).
-}
type alias Attrs =
    { class : Supported
    , color : Supported
    , id : Supported
    , scheme : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


{-| The `ChildAdmittedBy` type row for ThemeIcon (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | themeIcon : Ctx }


{-| The `Scheme` type row for ThemeIcon (generated).
-}
type alias Scheme =
    { auto : Supported
    , dark : Supported
    , light : Supported
    }


{-| The `Variant` type row for ThemeIcon (generated).
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


{-| The `Builder` type row for ThemeIcon (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ThemeIcon (generated).
-}
type alias AttrCaps =
    { class : Available
    , color : Available
    , id : Available
    , scheme : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
