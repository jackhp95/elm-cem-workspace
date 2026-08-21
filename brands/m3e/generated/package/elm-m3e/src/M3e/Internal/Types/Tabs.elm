module M3e.Internal.Types.Tabs exposing (Is, Attrs, Content, NextIconSlot, PanelSlot, PrevIconSlot, ChildAdmittedBy, DisablePagination, HeaderPosition, Variant, Builder, AttrCaps, SlotCaps)

{-| Type definitions for Tabs. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Tabs` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, NextIconSlot, PanelSlot, PrevIconSlot, ChildAdmittedBy, DisablePagination, HeaderPosition, Variant, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Tabs (generated).
-}
type alias Is s =
    { s | tabs : Brand }


{-| The `Attrs` type row for Tabs (generated).
-}
type alias Attrs =
    { class : Supported
    , disablePagination : Supported
    , headerPosition : Supported
    , id : Supported
    , nextPageLabel : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onInput : Supported
    , previousPageLabel : Supported
    , slot : Supported
    , stretch : Supported
    , style : Supported
    , variant : Supported
    }


{-| The `Content` type row for Tabs (generated).
-}
type alias Content =
    { tab : Brand }


{-| The `NextIconSlot` type row for Tabs (generated).
-}
type alias NextIconSlot =
    { sharedIcon : Shared }


{-| The `PanelSlot` type row for Tabs (generated).
-}
type alias PanelSlot =
    { tabPanel : Brand }


{-| The `PrevIconSlot` type row for Tabs (generated).
-}
type alias PrevIconSlot =
    { sharedIcon : Shared }


{-| The `ChildAdmittedBy` type row for Tabs (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | tabs : Ctx }


{-| The `DisablePagination` type row for Tabs (generated).
-}
type alias DisablePagination =
    { auto : Supported
    , false : Supported
    , true : Supported
    }


{-| The `HeaderPosition` type row for Tabs (generated).
-}
type alias HeaderPosition =
    { after : Supported
    , before : Supported
    }


{-| The `Variant` type row for Tabs (generated).
-}
type alias Variant =
    { primary : Supported
    , secondary : Supported
    }


{-| The `Builder` type row for Tabs (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Tabs (generated).
-}
type alias AttrCaps =
    { class : Available
    , disablePagination : Available
    , headerPosition : Available
    , id : Available
    , nextPageLabel : Available
    , onBeforeinput : Available
    , onChange : Available
    , onInput : Available
    , previousPageLabel : Available
    , slot : Available
    , stretch : Available
    , style : Available
    , variant : Available
    }


{-| The `SlotCaps` type row for Tabs (generated).
-}
type alias SlotCaps =
    { nextIcon : Available
    , prevIcon : Available
    }
