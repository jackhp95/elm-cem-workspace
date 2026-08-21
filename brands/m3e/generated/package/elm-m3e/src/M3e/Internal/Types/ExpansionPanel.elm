module M3e.Internal.Types.ExpansionPanel exposing (Is, Attrs, HeaderSlot, ToggleIconSlot, ChildAdmittedBy, ToggleDirection, TogglePosition, Builder, AttrCaps, SlotCaps)

{-| Type definitions for ExpansionPanel. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.ExpansionPanel` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, HeaderSlot, ToggleIconSlot, ChildAdmittedBy, ToggleDirection, TogglePosition, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ExpansionPanel (generated).
-}
type alias Is s =
    { s | expansionPanel : Brand }


{-| The `Attrs` type row for ExpansionPanel (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , hideToggle : Supported
    , id : Supported
    , onClosed : Supported
    , onClosing : Supported
    , onOpened : Supported
    , onOpening : Supported
    , open : Supported
    , slot : Supported
    , style : Supported
    , toggleDirection : Supported
    , togglePosition : Supported
    }


{-| The `HeaderSlot` type row for ExpansionPanel (generated).
-}
type alias HeaderSlot =
    { expansionHeader : Brand }


{-| The `ToggleIconSlot` type row for ExpansionPanel (generated).
-}
type alias ToggleIconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for ExpansionPanel (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | expansionPanel : Ctx }


{-| The `ToggleDirection` type row for ExpansionPanel (generated).
-}
type alias ToggleDirection =
    { horizontal : Supported
    , vertical : Supported
    }


{-| The `TogglePosition` type row for ExpansionPanel (generated).
-}
type alias TogglePosition =
    { after : Supported
    , before : Supported
    }


{-| The `Builder` type row for ExpansionPanel (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ExpansionPanel (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , hideToggle : Available
    , id : Available
    , onClosed : Available
    , onClosing : Available
    , onOpened : Available
    , onOpening : Available
    , open : Available
    , slot : Available
    , style : Available
    , toggleDirection : Available
    , togglePosition : Available
    }


{-| The `SlotCaps` type row for ExpansionPanel (generated).
-}
type alias SlotCaps =
    { header : Available
    , toggleIcon : Available
    }
