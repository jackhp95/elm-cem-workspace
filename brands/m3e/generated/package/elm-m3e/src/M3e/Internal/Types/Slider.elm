module M3e.Internal.Types.Slider exposing (Is, Attrs, ChildAdmittedBy, Size, Builder, AttrCaps)

{-| Type definitions for Slider. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Slider` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Size, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Slider (generated).
-}
type alias Is s =
    { s | slider : Brand }


{-| The `Attrs` type row for Slider (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , discrete : Supported
    , id : Supported
    , labelled : Supported
    , max : Supported
    , min : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onInput : Supported
    , size : Supported
    , slot : Supported
    , step : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Slider (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | slider : Ctx }


{-| The `Size` type row for Slider (generated).
-}
type alias Size =
    { extraLarge : Supported
    , extraSmall : Supported
    , large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Builder` type row for Slider (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Slider (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , discrete : Available
    , id : Available
    , labelled : Available
    , max : Available
    , min : Available
    , onBeforeinput : Available
    , onChange : Available
    , onInput : Available
    , size : Available
    , slot : Available
    , step : Available
    , style : Available
    }
