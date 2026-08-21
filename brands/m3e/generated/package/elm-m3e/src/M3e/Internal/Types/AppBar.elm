module M3e.Internal.Types.AppBar exposing (Is, Attrs, LeadingSlot, SubtitleSlot, TitleSlot, TrailingSlot, ChildAdmittedBy, Size, Builder, AttrCaps, SlotCaps)

{-| Type definitions for AppBar. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.AppBar` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, LeadingSlot, SubtitleSlot, TitleSlot, TrailingSlot, ChildAdmittedBy, Size, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for AppBar (generated).
-}
type alias Is s =
    { s | appBar : Brand }


{-| The `Attrs` type row for AppBar (generated).
-}
type alias Attrs =
    { centered : Supported
    , class : Supported
    , for : Supported
    , id : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `LeadingSlot` type row for AppBar (generated).
-}
type alias LeadingSlot =
    { button : Brand
    , iconButton : Brand
    , sharedIcon : Shared
    }


{-| The `SubtitleSlot` type row for AppBar (generated).
-}
type alias SubtitleSlot =
    { heading : Brand
    , sharedFlow : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    }


{-| The `TitleSlot` type row for AppBar (generated).
-}
type alias TitleSlot =
    { heading : Brand
    , sharedFlow : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    }


{-| The `TrailingSlot` type row for AppBar (generated).
-}
type alias TrailingSlot =
    { button : Brand
    , iconButton : Brand
    , searchBar : Brand
    , sharedFlow : Shared
    , sharedPhrasing : Shared
    }


{-| The `ChildAdmittedBy` type row for AppBar (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | appBar : Ctx }


{-| The `Size` type row for AppBar (generated).
-}
type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Builder` type row for AppBar (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for AppBar (generated).
-}
type alias AttrCaps =
    { centered : Available
    , class : Available
    , for : Available
    , id : Available
    , size : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for AppBar (generated).
-}
type alias SlotCaps =
    { leadingIcon : Available
    , subtitle : Available
    , title : Available
    , trailingIcon : Available
    }
