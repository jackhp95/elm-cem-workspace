module M3e.Internal.Types.RichTooltipAction exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for RichTooltipAction. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.RichTooltipAction` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for RichTooltipAction (generated).
-}
type alias Is s =
    { s | richTooltipAction : Brand }


{-| The `Attrs` type row for RichTooltipAction (generated).
-}
type alias Attrs =
    { class : Supported
    , disableRestoreFocus : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for RichTooltipAction (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `ChildAdmittedBy` type row for RichTooltipAction (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | richTooltipAction : Ctx }


{-| The `Builder` type row for RichTooltipAction (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for RichTooltipAction (generated).
-}
type alias AttrCaps =
    { class : Available
    , disableRestoreFocus : Available
    , id : Available
    , slot : Available
    , style : Available
    }
