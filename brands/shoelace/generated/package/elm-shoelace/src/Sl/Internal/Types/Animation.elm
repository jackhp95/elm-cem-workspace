module Sl.Internal.Types.Animation exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Animation. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.Animation` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Animation (generated).
-}
type alias Is s =
    { s | animation : Brand }


{-| The `Attrs` type row for Animation (generated).
-}
type alias Attrs =
    { class : Supported
    , delay : Supported
    , direction : Supported
    , duration : Supported
    , easing : Supported
    , endDelay : Supported
    , fill : Supported
    , id : Supported
    , iterationStart : Supported
    , iterations : Supported
    , name : Supported
    , onCancel : Supported
    , onFinish : Supported
    , onStart : Supported
    , play : Supported
    , playbackRate : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Animation (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | animation : Ctx }


{-| The `Builder` type row for Animation (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Animation (generated).
-}
type alias AttrCaps =
    { class : Available
    , delay : Available
    , direction : Available
    , duration : Available
    , easing : Available
    , endDelay : Available
    , fill : Available
    , id : Available
    , iterationStart : Available
    , iterations : Available
    , name : Available
    , onCancel : Available
    , onFinish : Available
    , onStart : Available
    , play : Available
    , playbackRate : Available
    , slot : Available
    , style : Available
    }
