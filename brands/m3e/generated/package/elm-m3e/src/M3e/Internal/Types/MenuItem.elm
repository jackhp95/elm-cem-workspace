module M3e.Internal.Types.MenuItem exposing (Is, Attrs, Content, IconSlot, TrailingIconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for MenuItem. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.MenuItem` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, IconSlot, TrailingIconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for MenuItem (generated).
-}
type alias Is s =
    { s | menuItem : Brand }


{-| The `Attrs` type row for MenuItem (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , download : Supported
    , href : Supported
    , id : Supported
    , onClick : Supported
    , rel : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    }


{-| The `Content` type row for MenuItem (generated).
-}
type alias Content =
    { bottomSheetAction : Brand
    , bottomSheetTrigger : Brand
    , datepickerToggle : Brand
    , dialogAction : Brand
    , dialogTrigger : Brand
    , drawerToggle : Brand
    , fabMenuTrigger : Brand
    , heading : Brand
    , menuTrigger : Brand
    , navRailToggle : Brand
    , richTooltipAction : Brand
    , sharedText : Shared
    , stepperPrevious : Brand
    , stepperReset : Brand
    , timepickerToggle : Brand
    }


{-| The `IconSlot` type row for MenuItem (generated).
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The `TrailingIconSlot` type row for MenuItem (generated).
-}
type alias TrailingIconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for MenuItem (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | menuItem : Ctx }


{-| The `Builder` type row for MenuItem (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for MenuItem (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , download : Available
    , href : Available
    , id : Available
    , onClick : Available
    , rel : Available
    , slot : Available
    , style : Available
    , target : Available
    }


{-| The `SlotCaps` type row for MenuItem (generated).
-}
type alias SlotCaps =
    { icon : Available
    , trailingIcon : Available
    }
