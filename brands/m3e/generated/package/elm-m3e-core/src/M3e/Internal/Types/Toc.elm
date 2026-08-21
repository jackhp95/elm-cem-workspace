module M3e.Internal.Types.Toc exposing (Is, Attrs, OverlineSlot, TitleSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for Toc. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Toc` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, OverlineSlot, TitleSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Toc (generated).
-}
type alias Is s =
    { s | toc : Brand }


{-| The `Attrs` type row for Toc (generated).
-}
type alias Attrs =
    { class : Supported
    , for : Supported
    , id : Supported
    , maxDepth : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `OverlineSlot` type row for Toc (generated).
-}
type alias OverlineSlot =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `TitleSlot` type row for Toc (generated).
-}
type alias TitleSlot =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `ChildAdmittedBy` type row for Toc (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | toc : Ctx }


{-| The `Builder` type row for Toc (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Toc (generated).
-}
type alias AttrCaps =
    { class : Available
    , for : Available
    , id : Available
    , maxDepth : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for Toc (generated).
-}
type alias SlotCaps =
    { overline : Available
    , title : Available
    }
