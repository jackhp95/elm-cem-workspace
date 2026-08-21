module M3e.Internal.Types.NavRail exposing (Is, Attrs, Content, ChildAdmittedBy, Mode, Builder, AttrCaps)

{-| Type definitions for NavRail. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.NavRail` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Mode, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for NavRail (generated).
-}
type alias Is s =
    { s | navRail : Brand }


{-| The `Attrs` type row for NavRail (generated).
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


{-| The `Content` type row for NavRail (generated).
-}
type alias Content =
    { fab : Brand
    , iconButton : Brand
    , navItem : Brand
    }


{-| The `ChildAdmittedBy` type row for NavRail (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | navRail : Ctx }


{-| The `Mode` type row for NavRail (generated).
-}
type alias Mode =
    { auto : Supported
    , compact : Supported
    , expanded : Supported
    }


{-| The `Builder` type row for NavRail (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for NavRail (generated).
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
