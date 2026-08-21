module M3e.Internal.Types.TreeItem exposing (Is, Attrs, Content, IconSlot, LabelSlot, OpenToggleIconSlot, SelectedIconSlot, ToggleIconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for TreeItem. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.TreeItem` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, IconSlot, LabelSlot, OpenToggleIconSlot, SelectedIconSlot, ToggleIconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for TreeItem (generated).
-}
type alias Is s =
    { s | treeItem : Brand }


{-| The `Attrs` type row for TreeItem (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , indeterminate : Supported
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


{-| The `Content` type row for TreeItem (generated).
-}
type alias Content =
    { treeItem : Brand }


{-| The `IconSlot` type row for TreeItem (generated).
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The `LabelSlot` type row for TreeItem (generated).
-}
type alias LabelSlot =
    { heading : Brand
    , sharedLink : Shared
    , sharedText : Shared
    }


{-| The `OpenToggleIconSlot` type row for TreeItem (generated).
-}
type alias OpenToggleIconSlot =
    { sharedIcon : Shared }


{-| The `SelectedIconSlot` type row for TreeItem (generated).
-}
type alias SelectedIconSlot =
    { sharedIcon : Shared }


{-| The `ToggleIconSlot` type row for TreeItem (generated).
-}
type alias ToggleIconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for TreeItem (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | treeItem : Ctx }


{-| The `Builder` type row for TreeItem (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for TreeItem (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , indeterminate : Available
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


{-| The `SlotCaps` type row for TreeItem (generated).
-}
type alias SlotCaps =
    { icon : Available
    , label : Available
    , openToggleIcon : Available
    , selectedIcon : Available
    , toggleIcon : Available
    }
