module M3e.Internal.Types.AssistChip exposing (Is, Attrs, Content, IconSlot, ChildAdmittedBy, Type, Variant, Builder, AttrCaps, SlotCaps)

{-| Type definitions for AssistChip. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.AssistChip` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, IconSlot, ChildAdmittedBy, Type, Variant, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for AssistChip (generated).
-}
type alias Is s =
    { s | assistChip : Brand }


{-| The `Attrs` type row for AssistChip (generated).
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


{-| The `Content` type row for AssistChip (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `IconSlot` type row for AssistChip (generated).
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for AssistChip (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | assistChip : Ctx }


{-| The `Type` type row for AssistChip (generated).
-}
type alias Type =
    { button : Supported
    , reset : Supported
    , submit : Supported
    }


{-| The `Variant` type row for AssistChip (generated).
-}
type alias Variant =
    { elevated : Supported
    , outlined : Supported
    }


{-| The `Builder` type row for AssistChip (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for AssistChip (generated).
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


{-| The `SlotCaps` type row for AssistChip (generated).
-}
type alias SlotCaps =
    { icon : Available
    }
