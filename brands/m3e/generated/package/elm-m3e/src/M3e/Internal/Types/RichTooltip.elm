module M3e.Internal.Types.RichTooltip exposing (Is, Attrs, Content, SubheadSlot, ChildAdmittedBy, Position, TouchGestures, Builder, AttrCaps, SlotCaps)

{-| Type definitions for RichTooltip. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.RichTooltip` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, SubheadSlot, ChildAdmittedBy, Position, TouchGestures, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for RichTooltip (generated).
-}
type alias Is s =
    { s | richTooltip : Brand }


{-| The `Attrs` type row for RichTooltip (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , for : Supported
    , hideDelay : Supported
    , id : Supported
    , onBeforetoggle : Supported
    , onToggle : Supported
    , position : Supported
    , showDelay : Supported
    , slot : Supported
    , style : Supported
    , touchGestures : Supported
    }


{-| The `Content` type row for RichTooltip (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `SubheadSlot` type row for RichTooltip (generated).
-}
type alias SubheadSlot =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `ChildAdmittedBy` type row for RichTooltip (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | richTooltip : Ctx }


{-| The `Position` type row for RichTooltip (generated).
-}
type alias Position =
    { above : Supported
    , aboveAfter : Supported
    , aboveBefore : Supported
    , after : Supported
    , before : Supported
    , below : Supported
    , belowAfter : Supported
    , belowBefore : Supported
    }


{-| The `TouchGestures` type row for RichTooltip (generated).
-}
type alias TouchGestures =
    { auto : Supported
    , off : Supported
    , on : Supported
    }


{-| The `Builder` type row for RichTooltip (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for RichTooltip (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , for : Available
    , hideDelay : Available
    , id : Available
    , onBeforetoggle : Available
    , onToggle : Available
    , position : Available
    , showDelay : Available
    , slot : Available
    , style : Available
    , touchGestures : Available
    }


{-| The `SlotCaps` type row for RichTooltip (generated).
-}
type alias SlotCaps =
    { actions : Available
    , subhead : Available
    }
