module M3e.Internal.Types.FilterChip exposing (Is, Attrs, Content, IconSlot, TrailingIconSlot, ChildAdmittedBy, Variant, Builder, AttrCaps, SlotCaps)

{-| Type definitions for FilterChip. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.FilterChip` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, IconSlot, TrailingIconSlot, ChildAdmittedBy, Variant, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for FilterChip (generated).
-}
type alias Is s =
    { s | filterChip : Brand }


{-| The `Attrs` type row for FilterChip (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , disabledInteractive : Supported
    , id : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    , variant : Supported
    }


{-| The `Content` type row for FilterChip (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `IconSlot` type row for FilterChip (generated).
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The `TrailingIconSlot` type row for FilterChip (generated).
-}
type alias TrailingIconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for FilterChip (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | filterChip : Ctx }


{-| The `Variant` type row for FilterChip (generated).
-}
type alias Variant =
    { elevated : Supported
    , outlined : Supported
    }


{-| The `Builder` type row for FilterChip (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for FilterChip (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , disabledInteractive : Available
    , id : Available
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , selected : Available
    , slot : Available
    , style : Available
    , value : Available
    , variant : Available
    }


{-| The `SlotCaps` type row for FilterChip (generated).
-}
type alias SlotCaps =
    { icon : Available
    , trailingIcon : Available
    }
