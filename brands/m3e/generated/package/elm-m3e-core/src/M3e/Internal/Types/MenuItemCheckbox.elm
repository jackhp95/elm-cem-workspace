module M3e.Internal.Types.MenuItemCheckbox exposing (Is, Attrs, Content, IconSlot, TrailingIconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for MenuItemCheckbox. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.MenuItemCheckbox` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, IconSlot, TrailingIconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for MenuItemCheckbox (generated).
-}
type alias Is s =
    { s | menuItemCheckbox : Brand }


{-| The `Attrs` type row for MenuItemCheckbox (generated).
-}
type alias Attrs =
    { checked : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , onClick : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for MenuItemCheckbox (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `IconSlot` type row for MenuItemCheckbox (generated).
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The `TrailingIconSlot` type row for MenuItemCheckbox (generated).
-}
type alias TrailingIconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for MenuItemCheckbox (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | menuItemCheckbox : Ctx }


{-| The `Builder` type row for MenuItemCheckbox (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for MenuItemCheckbox (generated).
-}
type alias AttrCaps =
    { checked : Available
    , class : Available
    , disabled : Available
    , id : Available
    , onClick : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for MenuItemCheckbox (generated).
-}
type alias SlotCaps =
    { icon : Available
    , trailingIcon : Available
    }
