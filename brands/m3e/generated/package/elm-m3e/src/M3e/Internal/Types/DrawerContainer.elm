module M3e.Internal.Types.DrawerContainer exposing (Is, Attrs, ChildAdmittedBy, EndMode, StartMode, Builder, AttrCaps, SlotCaps)

{-| Type definitions for DrawerContainer. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.DrawerContainer` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, EndMode, StartMode, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for DrawerContainer (generated).
-}
type alias Is s =
    { s | drawerContainer : Brand }


{-| The `Attrs` type row for DrawerContainer (generated).
-}
type alias Attrs =
    { class : Supported
    , end : Supported
    , endDivider : Supported
    , endMode : Supported
    , id : Supported
    , onChange : Supported
    , slot : Supported
    , start : Supported
    , startDivider : Supported
    , startMode : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for DrawerContainer (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | drawerContainer : Ctx }


{-| The `EndMode` type row for DrawerContainer (generated).
-}
type alias EndMode =
    { auto : Supported
    , over : Supported
    , push : Supported
    , side : Supported
    }


{-| The `StartMode` type row for DrawerContainer (generated).
-}
type alias StartMode =
    { auto : Supported
    , over : Supported
    , push : Supported
    , side : Supported
    }


{-| The `Builder` type row for DrawerContainer (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for DrawerContainer (generated).
-}
type alias AttrCaps =
    { class : Available
    , end : Available
    , endDivider : Available
    , endMode : Available
    , id : Available
    , onChange : Available
    , slot : Available
    , start : Available
    , startDivider : Available
    , startMode : Available
    , style : Available
    }


{-| The `SlotCaps` type row for DrawerContainer (generated).
-}
type alias SlotCaps =
    { end : Available
    , start : Available
    }
