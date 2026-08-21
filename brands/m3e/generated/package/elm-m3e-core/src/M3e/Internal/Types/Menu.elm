module M3e.Internal.Types.Menu exposing (Is, Attrs, Content, ChildAdmittedBy, PositionX, PositionY, Variant, Builder, AttrCaps)

{-| Type definitions for Menu. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Menu` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, PositionX, PositionY, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Menu (generated).
-}
type alias Is s =
    { s | menu : Brand }


{-| The `Attrs` type row for Menu (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , onBeforetoggle : Supported
    , onToggle : Supported
    , positionX : Supported
    , positionY : Supported
    , slot : Supported
    , style : Supported
    , submenu : Supported
    , variant : Supported
    }


{-| The `Content` type row for Menu (generated).
-}
type alias Content =
    { divider : Brand
    , menuItem : Brand
    , menuItemCheckbox : Brand
    , menuItemGroup : Brand
    , menuItemRadio : Brand
    }


{-| The `ChildAdmittedBy` type row for Menu (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | menu : Ctx }


{-| The `PositionX` type row for Menu (generated).
-}
type alias PositionX =
    { after : Supported
    , before : Supported
    }


{-| The `PositionY` type row for Menu (generated).
-}
type alias PositionY =
    { above : Supported
    , below : Supported
    }


{-| The `Variant` type row for Menu (generated).
-}
type alias Variant =
    { standard : Supported
    , vibrant : Supported
    }


{-| The `Builder` type row for Menu (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Menu (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , onBeforetoggle : Available
    , onToggle : Available
    , positionX : Available
    , positionY : Available
    , slot : Available
    , style : Available
    , submenu : Available
    , variant : Available
    }
