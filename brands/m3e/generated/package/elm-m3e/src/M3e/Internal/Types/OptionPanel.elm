module M3e.Internal.Types.OptionPanel exposing (Is, Attrs, Content, LoadingSlot, ChildAdmittedBy, ScrollStrategy, Builder, AttrCaps, SlotCaps)

{-| Type definitions for OptionPanel. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.OptionPanel` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, LoadingSlot, ChildAdmittedBy, ScrollStrategy, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for OptionPanel (generated).
-}
type alias Is s =
    { s | optionPanel : Brand }


{-| The `Attrs` type row for OptionPanel (generated).
-}
type alias Attrs =
    { anchorOffset : Supported
    , class : Supported
    , fitAnchorWidth : Supported
    , id : Supported
    , onBeforetoggle : Supported
    , onToggle : Supported
    , scrollStrategy : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for OptionPanel (generated).
-}
type alias Content =
    { divider : Brand
    , optgroup : Brand
    , option : Brand
    }


{-| The `LoadingSlot` type row for OptionPanel (generated).
-}
type alias LoadingSlot =
    { circularProgressIndicator : Brand
    , heading : Brand
    , loadingIndicator : Brand
    , sharedText : Shared
    }


{-| The `ChildAdmittedBy` type row for OptionPanel (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | optionPanel : Ctx }


{-| The `ScrollStrategy` type row for OptionPanel (generated).
-}
type alias ScrollStrategy =
    { hide : Supported
    , reposition : Supported
    }


{-| The `Builder` type row for OptionPanel (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for OptionPanel (generated).
-}
type alias AttrCaps =
    { anchorOffset : Available
    , class : Available
    , fitAnchorWidth : Available
    , id : Available
    , onBeforetoggle : Available
    , onToggle : Available
    , scrollStrategy : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for OptionPanel (generated).
-}
type alias SlotCaps =
    { noData : Available
    }
