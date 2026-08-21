module M3e.Internal.Types.Collapsible exposing (Is, Attrs, ChildAdmittedBy, Orientation, Builder, AttrCaps)

{-| Type definitions for Collapsible. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Collapsible` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Orientation, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Collapsible (generated).
-}
type alias Is s =
    { s | collapsible : Brand }


{-| The `Attrs` type row for Collapsible (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , noAnimate : Supported
    , onClosed : Supported
    , onClosing : Supported
    , onOpened : Supported
    , onOpening : Supported
    , open : Supported
    , orientation : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Collapsible (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | collapsible : Ctx }


{-| The `Orientation` type row for Collapsible (generated).
-}
type alias Orientation =
    { both : Supported
    , horizontal : Supported
    , vertical : Supported
    }


{-| The `Builder` type row for Collapsible (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Collapsible (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , noAnimate : Available
    , onClosed : Available
    , onClosing : Available
    , onOpened : Available
    , onOpening : Available
    , open : Available
    , orientation : Available
    , slot : Available
    , style : Available
    }
