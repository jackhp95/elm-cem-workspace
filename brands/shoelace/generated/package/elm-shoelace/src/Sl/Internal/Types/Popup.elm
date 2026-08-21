module Sl.Internal.Types.Popup exposing (Is, Attrs, ChildAdmittedBy, ArrowPlacement, AutoSize, FlipFallbackStrategy, Placement, Strategy, Sync, Builder, AttrCaps)

{-| Type definitions for Popup. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.Popup` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, ArrowPlacement, AutoSize, FlipFallbackStrategy, Placement, Strategy, Sync, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Popup (generated).
-}
type alias Is s =
    { s | popup : Brand }


{-| The `Attrs` type row for Popup (generated).
-}
type alias Attrs =
    { active : Supported
    , anchor : Supported
    , arrow : Supported
    , arrowPadding : Supported
    , arrowPlacement : Supported
    , autoSize : Supported
    , autoSizePadding : Supported
    , autosizeboundary : Supported
    , class : Supported
    , distance : Supported
    , flip : Supported
    , flipFallbackPlacements : Supported
    , flipFallbackStrategy : Supported
    , flipPadding : Supported
    , flipboundary : Supported
    , hoverBridge : Supported
    , id : Supported
    , onReposition : Supported
    , placement : Supported
    , shift : Supported
    , shiftPadding : Supported
    , shiftboundary : Supported
    , skidding : Supported
    , slot : Supported
    , strategy : Supported
    , style : Supported
    , sync : Supported
    }


{-| The `ChildAdmittedBy` type row for Popup (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | popup : Ctx }


{-| The `ArrowPlacement` type row for Popup (generated).
-}
type alias ArrowPlacement =
    { anchor : Supported
    , center : Supported
    , end : Supported
    , start : Supported
    }


{-| The `AutoSize` type row for Popup (generated).
-}
type alias AutoSize =
    { both : Supported
    , horizontal : Supported
    , vertical : Supported
    }


{-| The `FlipFallbackStrategy` type row for Popup (generated).
-}
type alias FlipFallbackStrategy =
    { bestFit : Supported
    , initial : Supported
    }


{-| The `Placement` type row for Popup (generated).
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


{-| The `Strategy` type row for Popup (generated).
-}
type alias Strategy =
    { absolute : Supported
    , fixed : Supported
    }


{-| The `Sync` type row for Popup (generated).
-}
type alias Sync =
    { both : Supported
    , height : Supported
    , width : Supported
    }


{-| The `Builder` type row for Popup (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Popup (generated).
-}
type alias AttrCaps =
    { active : Available
    , anchor : Available
    , arrow : Available
    , arrowPadding : Available
    , arrowPlacement : Available
    , autoSize : Available
    , autoSizePadding : Available
    , autosizeboundary : Available
    , class : Available
    , distance : Available
    , flip : Available
    , flipFallbackPlacements : Available
    , flipFallbackStrategy : Available
    , flipPadding : Available
    , flipboundary : Available
    , hoverBridge : Available
    , id : Available
    , onReposition : Available
    , placement : Available
    , shift : Available
    , shiftPadding : Available
    , shiftboundary : Available
    , skidding : Available
    , slot : Available
    , strategy : Available
    , style : Available
    , sync : Available
    }
