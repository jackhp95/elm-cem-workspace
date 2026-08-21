module M3e.Internal.Types.NavMenuItem exposing (Is, Attrs, Content, BadgeSlot, IconSlot, LabelSlot, SelectedIconSlot, ToggleIconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for NavMenuItem. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.NavMenuItem` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, BadgeSlot, IconSlot, LabelSlot, SelectedIconSlot, ToggleIconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for NavMenuItem (generated).
-}
type alias Is s =
    { s | navMenuItem : Brand }


{-| The `Attrs` type row for NavMenuItem (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , onClick : Supported
    , onClosed : Supported
    , onClosing : Supported
    , onOpened : Supported
    , onOpening : Supported
    , open : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for NavMenuItem (generated).
-}
type alias Content =
    { navMenuItem : Brand }


{-| The `BadgeSlot` type row for NavMenuItem (generated).
-}
type alias BadgeSlot =
    { badge : Brand
    , heading : Brand
    , sharedText : Shared
    }


{-| The `IconSlot` type row for NavMenuItem (generated).
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The `LabelSlot` type row for NavMenuItem (generated).
-}
type alias LabelSlot =
    { heading : Brand
    , sharedLink : Shared
    , sharedText : Shared
    }


{-| The `SelectedIconSlot` type row for NavMenuItem (generated).
-}
type alias SelectedIconSlot =
    { sharedIcon : Shared }


{-| The `ToggleIconSlot` type row for NavMenuItem (generated).
-}
type alias ToggleIconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for NavMenuItem (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | navMenuItem : Ctx }


{-| The `Builder` type row for NavMenuItem (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for NavMenuItem (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , onClick : Available
    , onClosed : Available
    , onClosing : Available
    , onOpened : Available
    , onOpening : Available
    , open : Available
    , selected : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for NavMenuItem (generated).
-}
type alias SlotCaps =
    { badge : Available
    , icon : Available
    , label : Available
    , selectedIcon : Available
    , toggleIcon : Available
    }
