module Sl.Internal.Types.TabGroup exposing (Is, Attrs, ChildAdmittedBy, Activation, Placement, Builder, AttrCaps)

{-| Type definitions for TabGroup. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.TabGroup` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Activation, Placement, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for TabGroup (generated).
-}
type alias Is s =
    { s | tabGroup : Brand }


{-| The `Attrs` type row for TabGroup (generated).
-}
type alias Attrs =
    { activation : Supported
    , class : Supported
    , fixedScrollControls : Supported
    , id : Supported
    , noScrollControls : Supported
    , onTabHide : Supported
    , onTabShow : Supported
    , placement : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for TabGroup (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | tabGroup : Ctx }


{-| The `Activation` type row for TabGroup (generated).
-}
type alias Activation =
    { auto : Supported
    , manual : Supported
    }


{-| The `Placement` type row for TabGroup (generated).
-}
type alias Placement =
    { bottom : Supported
    , end : Supported
    , start : Supported
    , top : Supported
    }


{-| The `Builder` type row for TabGroup (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for TabGroup (generated).
-}
type alias AttrCaps =
    { activation : Available
    , class : Available
    , fixedScrollControls : Available
    , id : Available
    , noScrollControls : Available
    , onTabHide : Available
    , onTabShow : Available
    , placement : Available
    , slot : Available
    , style : Available
    }
