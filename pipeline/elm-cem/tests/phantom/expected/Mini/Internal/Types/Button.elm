module Mini.Internal.Types.Button exposing (Is, Attrs, Content, IconSlot, ChildAdmittedBy, Variant, Builder, AttrCaps, SlotCaps)

{-| Type definitions for Button. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Mini` barrel and the strict
`Mini.Element.Button` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, IconSlot, ChildAdmittedBy, Variant, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Mini.Forge.Internal as B
import Mini.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Button (generated).
-}
type alias Is s =
    { s | button : Brand }


{-| The `Attrs` type row for Button (generated).
-}
type alias Attrs =
    { class : Supported
    , dir : Supported
    , disabled : Supported
    , id : Supported
    , inert : Supported
    , onClick : Supported
    , slot : Supported
    , style : Supported
    , tabindex : Supported
    , variant : Supported
    , weight : Supported
    }


{-| The `Content` type row for Button (generated).
-}
type alias Content =
    { sharedIcon : Shared
    , sharedText : Shared
    }


{-| The `IconSlot` type row for Button (generated).
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for Button (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | button : Ctx }


{-| The `Variant` type row for Button (generated).
-}
type alias Variant =
    { filled : Supported
    , tonal : Supported
    }


{-| The `Builder` type row for Button (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Button (generated).
-}
type alias AttrCaps =
    { class : Available
    , dir : Available
    , disabled : Available
    , id : Available
    , inert : Available
    , onClick : Available
    , slot : Available
    , style : Available
    , tabindex : Available
    , variant : Available
    , weight : Available
    }


{-| The `SlotCaps` type row for Button (generated).
-}
type alias SlotCaps =
    { icon : Available
    }
