module M3e.Internal.Types.NavItem exposing (Is, Attrs, Content, IconSlot, SelectedIconSlot, ChildAdmittedBy, Orientation, Builder, AttrCaps, SlotCaps)

{-| Type definitions for NavItem. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.NavItem` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, IconSlot, SelectedIconSlot, ChildAdmittedBy, Orientation, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for NavItem (generated).
-}
type alias Is s =
    { s | navItem : Brand }


{-| The `Attrs` type row for NavItem (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , disabledInteractive : Supported
    , download : Supported
    , href : Supported
    , id : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , orientation : Supported
    , rel : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    }


{-| The `Content` type row for NavItem (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `IconSlot` type row for NavItem (generated).
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The `SelectedIconSlot` type row for NavItem (generated).
-}
type alias SelectedIconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for NavItem (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | navItem : Ctx }


{-| The `Orientation` type row for NavItem (generated).
-}
type alias Orientation =
    { horizontal : Supported
    , vertical : Supported
    }


{-| The `Builder` type row for NavItem (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for NavItem (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , disabledInteractive : Available
    , download : Available
    , href : Available
    , id : Available
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , orientation : Available
    , rel : Available
    , selected : Available
    , slot : Available
    , style : Available
    , target : Available
    }


{-| The `SlotCaps` type row for NavItem (generated).
-}
type alias SlotCaps =
    { icon : Available
    , selectedIcon : Available
    }
