module M3e.Internal.Types.ExpandableListItem exposing (Is, Attrs, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, ToggleIconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for ExpandableListItem. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.ExpandableListItem` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, ToggleIconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ExpandableListItem (generated).
-}
type alias Is s =
    { s | expandableListItem : Brand }


{-| The `Attrs` type row for ExpandableListItem (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , onClosed : Supported
    , onClosing : Supported
    , onOpened : Supported
    , onOpening : Supported
    , open : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for ExpandableListItem (generated).
-}
type alias Content =
    { heading : Brand
    , sharedFlow : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    }


{-| The `LeadingSlot` type row for ExpandableListItem (generated).
-}
type alias LeadingSlot =
    { avatar : Brand
    , heading : Brand
    , sharedFlow : Shared
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    }


{-| The `OverlineSlot` type row for ExpandableListItem (generated).
-}
type alias OverlineSlot =
    { heading : Brand
    , sharedFlow : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    }


{-| The `SupportingTextSlot` type row for ExpandableListItem (generated).
-}
type alias SupportingTextSlot =
    { heading : Brand
    , sharedFlow : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    }


{-| The `ToggleIconSlot` type row for ExpandableListItem (generated).
-}
type alias ToggleIconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for ExpandableListItem (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | expandableListItem : Ctx }


{-| The `Builder` type row for ExpandableListItem (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ExpandableListItem (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , onClosed : Available
    , onClosing : Available
    , onOpened : Available
    , onOpening : Available
    , open : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for ExpandableListItem (generated).
-}
type alias SlotCaps =
    { items : Available
    , leading : Available
    , overline : Available
    , supportingText : Available
    , toggleIcon : Available
    }
