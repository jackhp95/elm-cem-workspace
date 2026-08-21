module M3e.Internal.Types.Fab exposing (Is, Attrs, Content, CloseIconSlot, LabelSlot, ChildAdmittedBy, Size, Type, Variant, ActionCaps, Builder, AttrCaps, SlotCaps)

{-| Type definitions for Fab. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Fab` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, CloseIconSlot, LabelSlot, ChildAdmittedBy, Size, Type, Variant, ActionCaps, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Fab (generated).
-}
type alias Is s =
    { s | fab : Brand }


{-| The `Attrs` type row for Fab (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , disabledInteractive : Supported
    , download : Supported
    , extended : Supported
    , href : Supported
    , id : Supported
    , lowered : Supported
    , name : Supported
    , onClick : Supported
    , rel : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    , type_ : Supported
    , value : Supported
    , variant : Supported
    }


{-| The `Content` type row for Fab (generated).
-}
type alias Content =
    { sharedIcon : Shared }


{-| The `CloseIconSlot` type row for Fab (generated).
-}
type alias CloseIconSlot =
    { sharedIcon : Shared }


{-| The `LabelSlot` type row for Fab (generated).
-}
type alias LabelSlot =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `ChildAdmittedBy` type row for Fab (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | fab : Ctx }


{-| The `Size` type row for Fab (generated).
-}
type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Type` type row for Fab (generated).
-}
type alias Type =
    { button : Supported
    , reset : Supported
    , submit : Supported
    }


{-| The `Variant` type row for Fab (generated).
-}
type alias Variant =
    { primary : Supported
    , primaryContainer : Supported
    , secondary : Supported
    , secondaryContainer : Supported
    , surface : Supported
    , tertiary : Supported
    , tertiaryContainer : Supported
    }


{-| The `ActionCaps` type row for Fab (generated).
-}
type alias ActionCaps =
    { bottomSheetAction : Supported
    , bottomSheetTrigger : Supported
    , click : Supported
    , datepickerToggle : Supported
    , dialogAction : Supported
    , dialogTrigger : Supported
    , drawerToggle : Supported
    , fabMenuTrigger : Supported
    , link : Supported
    , menuTrigger : Supported
    , navRailToggle : Supported
    , richTooltipAction : Supported
    , stepperPrevious : Supported
    , stepperReset : Supported
    , timepickerToggle : Supported
    }


{-| The `Builder` type row for Fab (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Fab (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , disabledInteractive : Available
    , download : Available
    , extended : Available
    , href : Available
    , id : Available
    , lowered : Available
    , name : Available
    , onClick : Available
    , rel : Available
    , size : Available
    , slot : Available
    , style : Available
    , target : Available
    , type_ : Available
    , value : Available
    , variant : Available
    }


{-| The `SlotCaps` type row for Fab (generated).
-}
type alias SlotCaps =
    { closeIcon : Available
    , label : Available
    }
