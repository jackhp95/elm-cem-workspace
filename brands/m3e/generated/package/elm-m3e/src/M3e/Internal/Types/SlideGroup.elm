module M3e.Internal.Types.SlideGroup exposing (Is, Attrs, NextIconSlot, PrevIconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for SlideGroup. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.SlideGroup` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, NextIconSlot, PrevIconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for SlideGroup (generated).
-}
type alias Is s =
    { s | slideGroup : Brand }


{-| The `Attrs` type row for SlideGroup (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , nextPageLabel : Supported
    , previousPageLabel : Supported
    , slot : Supported
    , style : Supported
    , threshold : Supported
    , vertical : Supported
    }


{-| The `NextIconSlot` type row for SlideGroup (generated).
-}
type alias NextIconSlot =
    { sharedIcon : Shared }


{-| The `PrevIconSlot` type row for SlideGroup (generated).
-}
type alias PrevIconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for SlideGroup (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | slideGroup : Ctx }


{-| The `Builder` type row for SlideGroup (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for SlideGroup (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , nextPageLabel : Available
    , previousPageLabel : Available
    , slot : Available
    , style : Available
    , threshold : Available
    , vertical : Available
    }


{-| The `SlotCaps` type row for SlideGroup (generated).
-}
type alias SlotCaps =
    { nextIcon : Available
    , prevIcon : Available
    }
