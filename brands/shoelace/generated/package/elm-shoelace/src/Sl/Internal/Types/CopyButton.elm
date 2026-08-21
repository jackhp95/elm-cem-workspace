module Sl.Internal.Types.CopyButton exposing (Is, Attrs, ChildAdmittedBy, TooltipPlacement, Builder, AttrCaps)

{-| Type definitions for CopyButton. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.CopyButton` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, TooltipPlacement, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for CopyButton (generated).
-}
type alias Is s =
    { s | copyButton : Brand }


{-| The `Attrs` type row for CopyButton (generated).
-}
type alias Attrs =
    { class : Supported
    , copyLabel : Supported
    , disabled : Supported
    , errorLabel : Supported
    , feedbackDuration : Supported
    , from : Supported
    , hoist : Supported
    , id : Supported
    , onCopy : Supported
    , onError : Supported
    , slot : Supported
    , style : Supported
    , successLabel : Supported
    , tooltipPlacement : Supported
    , value : Supported
    }


{-| The `ChildAdmittedBy` type row for CopyButton (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | copyButton : Ctx }


{-| The `TooltipPlacement` type row for CopyButton (generated).
-}
type alias TooltipPlacement =
    { bottom : Supported
    , left : Supported
    , right : Supported
    , top : Supported
    }


{-| The `Builder` type row for CopyButton (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for CopyButton (generated).
-}
type alias AttrCaps =
    { class : Available
    , copyLabel : Available
    , disabled : Available
    , errorLabel : Available
    , feedbackDuration : Available
    , from : Available
    , hoist : Available
    , id : Available
    , onCopy : Available
    , onError : Available
    , slot : Available
    , style : Available
    , successLabel : Available
    , tooltipPlacement : Available
    , value : Available
    }
