module M3e.Internal.Types.ButtonSegment exposing (Is, Attrs, Content, IconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for ButtonSegment. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.ButtonSegment` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, IconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ButtonSegment (generated).
-}
type alias Is s =
    { s | buttonSegment : Brand }


{-| The `Attrs` type row for ButtonSegment (generated).
-}
type alias Attrs =
    { checked : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


{-| The `Content` type row for ButtonSegment (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `IconSlot` type row for ButtonSegment (generated).
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for ButtonSegment (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | buttonSegment : Ctx }


{-| The `Builder` type row for ButtonSegment (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ButtonSegment (generated).
-}
type alias AttrCaps =
    { checked : Available
    , class : Available
    , disabled : Available
    , id : Available
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , slot : Available
    , style : Available
    , value : Available
    }


{-| The `SlotCaps` type row for ButtonSegment (generated).
-}
type alias SlotCaps =
    { icon : Available
    }
