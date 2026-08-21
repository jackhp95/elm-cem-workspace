module M3e.Internal.Types.ExpansionHeader exposing (Is, Attrs, Content, ToggleIconSlot, ChildAdmittedBy, ToggleDirection, TogglePosition, Builder, AttrCaps, SlotCaps)

{-| Type definitions for ExpansionHeader. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.ExpansionHeader` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ToggleIconSlot, ChildAdmittedBy, ToggleDirection, TogglePosition, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ExpansionHeader (generated).
-}
type alias Is s =
    { s | expansionHeader : Brand }


{-| The `Attrs` type row for ExpansionHeader (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , hideToggle : Supported
    , id : Supported
    , onClick : Supported
    , slot : Supported
    , style : Supported
    , toggleDirection : Supported
    , togglePosition : Supported
    }


{-| The `Content` type row for ExpansionHeader (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `ToggleIconSlot` type row for ExpansionHeader (generated).
-}
type alias ToggleIconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for ExpansionHeader (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | expansionHeader : Ctx }


{-| The `ToggleDirection` type row for ExpansionHeader (generated).
-}
type alias ToggleDirection =
    { horizontal : Supported
    , vertical : Supported
    }


{-| The `TogglePosition` type row for ExpansionHeader (generated).
-}
type alias TogglePosition =
    { after : Supported
    , before : Supported
    }


{-| The `Builder` type row for ExpansionHeader (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ExpansionHeader (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , hideToggle : Available
    , id : Available
    , onClick : Available
    , slot : Available
    , style : Available
    , toggleDirection : Available
    , togglePosition : Available
    }


{-| The `SlotCaps` type row for ExpansionHeader (generated).
-}
type alias SlotCaps =
    { toggleIcon : Available
    }
