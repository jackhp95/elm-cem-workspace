module Sl.Internal.Types.Tooltip exposing (Is, Attrs, ChildAdmittedBy, Placement, Builder, AttrCaps)

{-| Type definitions for Tooltip. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Tooltip` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Placement, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Tooltip (generated).
-}
type alias Is s =
    { s | tooltip : Brand }


{-| The `Attrs` type row for Tooltip (generated).
-}
type alias Attrs =
    { class : Supported
    , content : Supported
    , disabled : Supported
    , distance : Supported
    , hoist : Supported
    , id : Supported
    , onAfterHide : Supported
    , onAfterShow : Supported
    , onHide : Supported
    , onShow : Supported
    , open : Supported
    , placement : Supported
    , skidding : Supported
    , slot : Supported
    , style : Supported
    , trigger : Supported
    }


{-| The `ChildAdmittedBy` type row for Tooltip (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | tooltip : Ctx }


{-| The `Placement` type row for Tooltip (generated).
-}
type alias Placement =
    { bottom : Supported
    , bottomEnd : Supported
    , bottomStart : Supported
    , left : Supported
    , leftEnd : Supported
    , leftStart : Supported
    , right : Supported
    , rightEnd : Supported
    , rightStart : Supported
    , top : Supported
    , topEnd : Supported
    , topStart : Supported
    }


{-| The `Builder` type row for Tooltip (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Tooltip (generated).
-}
type alias AttrCaps =
    { class : Available
    , content : Available
    , disabled : Available
    , distance : Available
    , hoist : Available
    , id : Available
    , onAfterHide : Available
    , onAfterShow : Available
    , onHide : Available
    , onShow : Available
    , open : Available
    , placement : Available
    , skidding : Available
    , slot : Available
    , style : Available
    , trigger : Available
    }
