module Sl.Internal.Types.Drawer exposing (Is, Attrs, ChildAdmittedBy, Placement, Builder, AttrCaps)

{-| Type definitions for Drawer. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Drawer` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Placement, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Drawer (generated).
-}
type alias Is s =
    { s | drawer : Brand }


{-| The `Attrs` type row for Drawer (generated).
-}
type alias Attrs =
    { class : Supported
    , contained : Supported
    , id : Supported
    , label : Supported
    , noHeader : Supported
    , onAfterHide : Supported
    , onAfterShow : Supported
    , onHide : Supported
    , onInitialFocus : Supported
    , onRequestClose : Supported
    , onShow : Supported
    , open : Supported
    , placement : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Drawer (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | drawer : Ctx }


{-| The `Placement` type row for Drawer (generated).
-}
type alias Placement =
    { bottom : Supported
    , end : Supported
    , start : Supported
    , top : Supported
    }


{-| The `Builder` type row for Drawer (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Drawer (generated).
-}
type alias AttrCaps =
    { class : Available
    , contained : Available
    , id : Available
    , label : Available
    , noHeader : Available
    , onAfterHide : Available
    , onAfterShow : Available
    , onHide : Available
    , onInitialFocus : Available
    , onRequestClose : Available
    , onShow : Available
    , open : Available
    , placement : Available
    , slot : Available
    , style : Available
    }
