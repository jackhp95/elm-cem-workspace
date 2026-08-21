module M3e.Internal.Types.SegmentedButton exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for SegmentedButton. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.SegmentedButton` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for SegmentedButton (generated).
-}
type alias Is s =
    { s | segmentedButton : Brand }


{-| The `Attrs` type row for SegmentedButton (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , hideSelectionIndicator : Supported
    , id : Supported
    , multi : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onInput : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for SegmentedButton (generated).
-}
type alias Content =
    { buttonSegment : Brand }


{-| The `ChildAdmittedBy` type row for SegmentedButton (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | segmentedButton : Ctx }


{-| The `Builder` type row for SegmentedButton (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for SegmentedButton (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , hideSelectionIndicator : Available
    , id : Available
    , multi : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onInput : Available
    , slot : Available
    , style : Available
    }
