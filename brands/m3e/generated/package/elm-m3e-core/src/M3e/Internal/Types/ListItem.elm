module M3e.Internal.Types.ListItem exposing (Is, Attrs, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, TrailingSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for ListItem. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.ListItem` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, TrailingSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ListItem (generated).
-}
type alias Is s =
    { s | listItem : Brand }


{-| The `Attrs` type row for ListItem (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for ListItem (generated).
-}
type alias Content =
    { heading : Brand
    , sharedFlow : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    }


{-| The `LeadingSlot` type row for ListItem (generated).
-}
type alias LeadingSlot =
    { avatar : Brand
    , heading : Brand
    , sharedFlow : Shared
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    }


{-| The `OverlineSlot` type row for ListItem (generated).
-}
type alias OverlineSlot =
    { heading : Brand
    , sharedFlow : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    }


{-| The `SupportingTextSlot` type row for ListItem (generated).
-}
type alias SupportingTextSlot =
    { heading : Brand
    , sharedFlow : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    }


{-| The `TrailingSlot` type row for ListItem (generated).
-}
type alias TrailingSlot =
    { avatar : Brand
    , checkbox : Brand
    , heading : Brand
    , radio : Brand
    , sharedFlow : Shared
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , switch : Brand
    }


{-| The `ChildAdmittedBy` type row for ListItem (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | listItem : Ctx }


{-| The `Builder` type row for ListItem (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ListItem (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for ListItem (generated).
-}
type alias SlotCaps =
    { leading : Available
    , overline : Available
    , supportingText : Available
    , trailing : Available
    }
