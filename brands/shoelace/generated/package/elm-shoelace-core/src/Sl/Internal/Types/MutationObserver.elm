module Sl.Internal.Types.MutationObserver exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for MutationObserver. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.MutationObserver` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for MutationObserver (generated).
-}
type alias Is s =
    { s | mutationObserver : Brand }


{-| The `Attrs` type row for MutationObserver (generated).
-}
type alias Attrs =
    { attr : Supported
    , attrOldValue : Supported
    , charData : Supported
    , charDataOldValue : Supported
    , childList : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , onMutation : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for MutationObserver (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | mutationObserver : Ctx }


{-| The `Builder` type row for MutationObserver (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for MutationObserver (generated).
-}
type alias AttrCaps =
    { attr : Available
    , attrOldValue : Available
    , charData : Available
    , charDataOldValue : Available
    , childList : Available
    , class : Available
    , disabled : Available
    , id : Available
    , onMutation : Available
    , slot : Available
    , style : Available
    }
