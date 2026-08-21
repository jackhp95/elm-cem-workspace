module M3e.Internal.Types.Card exposing (Is, Attrs, ChildAdmittedBy, Orientation, Type, Variant, Builder, AttrCaps, SlotCaps)

{-| Type definitions for Card. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Card` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Orientation, Type, Variant, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Card (generated).
-}
type alias Is s =
    { s | card : Brand }


{-| The `Attrs` type row for Card (generated).
-}
type alias Attrs =
    { actionable : Supported
    , class : Supported
    , disabled : Supported
    , disabledInteractive : Supported
    , download : Supported
    , href : Supported
    , id : Supported
    , inline : Supported
    , name : Supported
    , onClick : Supported
    , orientation : Supported
    , rel : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    , type_ : Supported
    , value : Supported
    , variant : Supported
    }


{-| The `ChildAdmittedBy` type row for Card (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | card : Ctx }


{-| The `Orientation` type row for Card (generated).
-}
type alias Orientation =
    { horizontal : Supported
    , vertical : Supported
    }


{-| The `Type` type row for Card (generated).
-}
type alias Type =
    { button : Supported
    , reset : Supported
    , submit : Supported
    }


{-| The `Variant` type row for Card (generated).
-}
type alias Variant =
    { elevated : Supported
    , filled : Supported
    , outlined : Supported
    }


{-| The `Builder` type row for Card (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Card (generated).
-}
type alias AttrCaps =
    { actionable : Available
    , class : Available
    , disabled : Available
    , disabledInteractive : Available
    , download : Available
    , href : Available
    , id : Available
    , inline : Available
    , name : Available
    , onClick : Available
    , orientation : Available
    , rel : Available
    , slot : Available
    , style : Available
    , target : Available
    , type_ : Available
    , value : Available
    , variant : Available
    }


{-| The `SlotCaps` type row for Card (generated).
-}
type alias SlotCaps =
    { actions : Available
    , content : Available
    , footer : Available
    , header : Available
    }
