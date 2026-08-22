module Sl.Internal.Types.Dialog exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Dialog. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Dialog` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Dialog (generated).
-}
type alias Is s =
    { s | dialog : Brand }


{-| The `Attrs` type row for Dialog (generated).
-}
type alias Attrs =
    { class : Supported
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
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Dialog (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | dialog : Ctx }


{-| The `Builder` type row for Dialog (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Dialog (generated).
-}
type alias AttrCaps =
    { class : Available
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
    , slot : Available
    , style : Available
    }
