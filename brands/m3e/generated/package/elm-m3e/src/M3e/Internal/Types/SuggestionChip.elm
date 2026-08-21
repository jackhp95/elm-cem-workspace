module M3e.Internal.Types.SuggestionChip exposing (Is, Attrs, Content, IconSlot, ChildAdmittedBy, Type, Variant, ActionCaps, Builder, AttrCaps, SlotCaps)

{-| Type definitions for SuggestionChip. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.SuggestionChip` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, IconSlot, ChildAdmittedBy, Type, Variant, ActionCaps, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for SuggestionChip (generated).
-}
type alias Is s =
    { s | suggestionChip : Brand }


{-| The `Attrs` type row for SuggestionChip (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , disabledInteractive : Supported
    , download : Supported
    , href : Supported
    , id : Supported
    , name : Supported
    , onClick : Supported
    , rel : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    , type_ : Supported
    , value : Supported
    , variant : Supported
    }


{-| The `Content` type row for SuggestionChip (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `IconSlot` type row for SuggestionChip (generated).
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for SuggestionChip (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | suggestionChip : Ctx }


{-| The `Type` type row for SuggestionChip (generated).
-}
type alias Type =
    { button : Supported
    , reset : Supported
    , submit : Supported
    }


{-| The `Variant` type row for SuggestionChip (generated).
-}
type alias Variant =
    { elevated : Supported
    , outlined : Supported
    }


{-| The `ActionCaps` type row for SuggestionChip (generated).
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


{-| The `Builder` type row for SuggestionChip (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for SuggestionChip (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , disabledInteractive : Available
    , download : Available
    , href : Available
    , id : Available
    , name : Available
    , onClick : Available
    , rel : Available
    , slot : Available
    , style : Available
    , target : Available
    , type_ : Available
    , value : Available
    , variant : Available
    }


{-| The `SlotCaps` type row for SuggestionChip (generated).
-}
type alias SlotCaps =
    { icon : Available
    }
