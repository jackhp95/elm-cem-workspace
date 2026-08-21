module M3e.Internal.Types.SplitPane exposing (Is, Attrs, ChildAdmittedBy, Orientation, Builder, AttrCaps, SlotCaps)

{-| Type definitions for SplitPane. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.SplitPane` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Orientation, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for SplitPane (generated).
-}
type alias Is s =
    { s | splitPane : Brand }


{-| The `Attrs` type row for SplitPane (generated).
-}
type alias Attrs =
    { class : Supported
    , detents : Supported
    , disabled : Supported
    , id : Supported
    , label : Supported
    , max : Supported
    , min : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onInput : Supported
    , orientation : Supported
    , overshootLimit : Supported
    , slot : Supported
    , step : Supported
    , style : Supported
    , value : Supported
    , wrapDetents : Supported
    }


{-| The `ChildAdmittedBy` type row for SplitPane (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | splitPane : Ctx }


{-| The `Orientation` type row for SplitPane (generated).
-}
type alias Orientation =
    { auto : Supported
    , horizontal : Supported
    , vertical : Supported
    }


{-| The `Builder` type row for SplitPane (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for SplitPane (generated).
-}
type alias AttrCaps =
    { class : Available
    , detents : Available
    , disabled : Available
    , id : Available
    , label : Available
    , max : Available
    , min : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onInput : Available
    , orientation : Available
    , overshootLimit : Available
    , slot : Available
    , step : Available
    , style : Available
    , value : Available
    , wrapDetents : Available
    }


{-| The `SlotCaps` type row for SplitPane (generated).
-}
type alias SlotCaps =
    { end : Available
    , start : Available
    }
