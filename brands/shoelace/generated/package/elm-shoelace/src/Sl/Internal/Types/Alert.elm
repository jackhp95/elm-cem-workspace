module Sl.Internal.Types.Alert exposing (Is, Attrs, ChildAdmittedBy, Countdown, Variant, Builder, AttrCaps)

{-| Type definitions for Alert. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.Alert` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Countdown, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Alert (generated).
-}
type alias Is s =
    { s | alert : Brand }


{-| The `Attrs` type row for Alert (generated).
-}
type alias Attrs =
    { class : Supported
    , closable : Supported
    , countdown : Supported
    , duration : Supported
    , id : Supported
    , onAfterHide : Supported
    , onAfterShow : Supported
    , onHide : Supported
    , onShow : Supported
    , open : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


{-| The `ChildAdmittedBy` type row for Alert (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | alert : Ctx }


{-| The `Countdown` type row for Alert (generated).
-}
type alias Countdown =
    { ltr : Supported
    , rtl : Supported
    }


{-| The `Variant` type row for Alert (generated).
-}
type alias Variant =
    { danger : Supported
    , neutral : Supported
    , primary : Supported
    , success : Supported
    , warning : Supported
    }


{-| The `Builder` type row for Alert (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Alert (generated).
-}
type alias AttrCaps =
    { class : Available
    , closable : Available
    , countdown : Available
    , duration : Available
    , id : Available
    , onAfterHide : Available
    , onAfterShow : Available
    , onHide : Available
    , onShow : Available
    , open : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
