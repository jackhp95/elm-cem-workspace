module M3e.Internal.Types.Menu exposing (..)

{-| Internal type definitions for Menu — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | menu : Brand }


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


type alias Content =
    { divider : Brand
    , menuItem : Brand
    , menuItemCheckbox : Brand
    , menuItemGroup : Brand
    , menuItemRadio : Brand
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | menu : Ctx }


type alias PositionX =
    { after : Supported
    , before : Supported
    }


type alias PositionY =
    { above : Supported
    , below : Supported
    }


type alias Variant =
    { standard : Supported
    , vibrant : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


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
