module M3e.Internal.Types.NavBar exposing (Is, Attrs, Content, ChildAdmittedBy, Mode, Builder, AttrCaps)

{-| Type definitions for NavBar. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.NavBar` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Mode, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for NavBar (generated).
-}
type alias Is s =
    { s | navBar : Brand }


{-| The `Attrs` type row for NavBar (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , mode : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onInput : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for NavBar (generated).
-}
type alias Content =
    { navItem : Brand }


{-| The `ChildAdmittedBy` type row for NavBar (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | navBar : Ctx }


{-| The `Mode` type row for NavBar (generated).
-}
type alias Mode =
    { auto : Supported
    , compact : Supported
    , expanded : Supported
    }


{-| The `Builder` type row for NavBar (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for NavBar (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , mode : Available
    , onBeforeinput : Available
    , onChange : Available
    , onInput : Available
    , slot : Available
    , style : Available
    }
