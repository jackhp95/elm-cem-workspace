module M3e.Internal.Types.SliderThumb exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for SliderThumb. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.SliderThumb` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for SliderThumb (generated).
-}
type alias Is s =
    { s | sliderThumb : Brand }


{-| The `Attrs` type row for SliderThumb (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , id : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , onValueChange : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    }


{-| The `ChildAdmittedBy` type row for SliderThumb (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | sliderThumb : Ctx }


{-| The `Builder` type row for SliderThumb (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for SliderThumb (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , id : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , onValueChange : Available
    , slot : Available
    , style : Available
    , value : Available
    }
