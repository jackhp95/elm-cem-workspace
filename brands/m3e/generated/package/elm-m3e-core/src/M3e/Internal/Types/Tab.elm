module M3e.Internal.Types.Tab exposing (Is, Attrs, Content, IconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for Tab. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Tab` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, IconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Tab (generated).
-}
type alias Is s =
    { s | tab : Brand }


{-| The `Attrs` type row for Tab (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , for : Supported
    , id : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for Tab (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `IconSlot` type row for Tab (generated).
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for Tab (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | tab : Ctx }


{-| The `Builder` type row for Tab (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Tab (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , for : Available
    , id : Available
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , selected : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for Tab (generated).
-}
type alias SlotCaps =
    { icon : Available
    }
