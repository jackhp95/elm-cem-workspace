module M3e.Internal.Types.IconButton exposing (Is, Attrs, Content, SelectedSlot, ChildAdmittedBy, Shape, Size, Type, Variant, Width, ActionCaps, Builder, AttrCaps, SlotCaps)

{-| Type definitions for IconButton. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.IconButton` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, SelectedSlot, ChildAdmittedBy, Shape, Size, Type, Variant, Width, ActionCaps, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for IconButton (generated).
-}
type alias Is s =
    { s | iconButton : Brand }


{-| The `Attrs` type row for IconButton (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , disabledInteractive : Supported
    , download : Supported
    , href : Supported
    , id : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , rel : Supported
    , selected : Supported
    , shape : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    , toggle : Supported
    , type_ : Supported
    , value : Supported
    , variant : Supported
    , width : Supported
    }


{-| The `Content` type row for IconButton (generated).
-}
type alias Content =
    { bottomSheetAction : Brand
    , bottomSheetTrigger : Brand
    , datepickerToggle : Brand
    , dialogAction : Brand
    , dialogTrigger : Brand
    , drawerToggle : Brand
    , fabMenuTrigger : Brand
    , menuTrigger : Brand
    , navRailToggle : Brand
    , richTooltipAction : Brand
    , sharedIcon : Shared
    , stepperNext : Brand
    , stepperPrevious : Brand
    , stepperReset : Brand
    , timepickerToggle : Brand
    }


{-| The `SelectedSlot` type row for IconButton (generated).
-}
type alias SelectedSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for IconButton (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | iconButton : Ctx }


{-| The `Shape` type row for IconButton (generated).
-}
type alias Shape =
    { rounded : Supported
    , square : Supported
    }


{-| The `Size` type row for IconButton (generated).
-}
type alias Size =
    { extraLarge : Supported
    , extraSmall : Supported
    , large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Type` type row for IconButton (generated).
-}
type alias Type =
    { button : Supported
    , reset : Supported
    , submit : Supported
    }


{-| The `Variant` type row for IconButton (generated).
-}
type alias Variant =
    { elevated : Supported
    , filled : Supported
    , outlined : Supported
    , standard : Supported
    , tonal : Supported
    }


{-| The `Width` type row for IconButton (generated).
-}
type alias Width =
    { default : Supported
    , narrow : Supported
    , wide : Supported
    }


{-| The `ActionCaps` type row for IconButton (generated).
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
    , stepperNext : Supported
    , stepperPrevious : Supported
    , stepperReset : Supported
    , timepickerToggle : Supported
    }


{-| The `Builder` type row for IconButton (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for IconButton (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , disabledInteractive : Available
    , download : Available
    , href : Available
    , id : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , rel : Available
    , selected : Available
    , shape : Available
    , size : Available
    , slot : Available
    , style : Available
    , target : Available
    , toggle : Available
    , type_ : Available
    , value : Available
    , variant : Available
    , width : Available
    }


{-| The `SlotCaps` type row for IconButton (generated).
-}
type alias SlotCaps =
    { selected : Available
    }
